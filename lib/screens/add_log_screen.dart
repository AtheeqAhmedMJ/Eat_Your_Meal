import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food_log_entry.dart';
import '../services/app_state.dart';
import '../utils/app_theme.dart';
import '../widgets/gradient_scaffold.dart';
import '../widgets/glass_card.dart';
import '../widgets/emoji_picker.dart';

class AddLogScreen extends StatefulWidget {
  final DateTime date;
  final FoodLogEntry? existing;
  const AddLogScreen({super.key, required this.date, this.existing});

  @override
  State<AddLogScreen> createState() => _AddLogScreenState();
}

class _AddLogScreenState extends State<AddLogScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _notesCtrl;
  late String _emoji;
  String? _mood;
  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.mealName ?? '');
    _notesCtrl = TextEditingController(text: e?.notes ?? '');
    _emoji = e?.emoji ?? '🍽️';
    _mood = e?.mood;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (mounted) setState(() => _saving = true);
    final state = context.read<AppState>();

    if (_isEdit) {
      final updated = FoodLogEntry(
        id: widget.existing!.id,
        date: widget.existing!.date,
        mealName: _nameCtrl.text.trim(),
        emoji: _emoji,
        notes: _notesCtrl.text.trim(),
        mood: _mood,
        loggedAt: widget.existing!.loggedAt,
      );
      await state.updateLog(updated);
    } else {
      final entry = FoodLogEntry(
        id: state.newId(),
        date: widget.date,
        mealName: _nameCtrl.text.trim(),
        emoji: _emoji,
        notes: _notesCtrl.text.trim(),
        mood: _mood,
        loggedAt: DateTime.now(),
      );
      await state.addLog(entry);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Pre-fill from reminders as suggestions
    final reminders = context.read<AppState>().reminders;

    return GradientScaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Log' : 'Log a Meal'),
        leading: const BackButton(),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Quick-fill from reminders
              if (!_isEdit && reminders.isNotEmpty) ...[
                Text('Quick fill from reminders',
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: AppTheme.textLight)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 44,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: reminders.length,
                    itemBuilder: (ctx, i) {
                      final r = reminders[i];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          label: Text('${r.emoji} ${r.name}'),
                          onPressed: () {
                            setState(() {
                              _nameCtrl.text = r.name;
                              _emoji = r.emoji;
                            });
                          },
                          backgroundColor: Colors.white.withAlphaPercent(0.55),
                          side: BorderSide(
                              color: Colors.white.withAlphaPercent(0.7)),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Emoji + Meal name
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('What did you eat?',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: AppTheme.textLight)),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _pickEmoji,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppTheme.accent.withAlphaPercent(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: AppTheme.accent.withAlphaPercent(0.3),
                                  width: 1.5),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_emoji,
                                    style: const TextStyle(fontSize: 26)),
                                const Text('tap',
                                    style: TextStyle(
                                        fontSize: 9,
                                        color: AppTheme.textLight)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: TextFormField(
                            controller: _nameCtrl,
                            decoration:
                                const InputDecoration(labelText: 'Meal name'),
                            textCapitalization: TextCapitalization.words,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Enter a name'
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Notes
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Notes  (optional)',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: AppTheme.textLight)),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _notesCtrl,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Had oats with banana & honey…',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                      ),
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Mood
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('How do you feel?  (optional)',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: AppTheme.textLight)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: kMoodEmojis.map((e) {
                        final sel = _mood == e;
                        return GestureDetector(
                          onTap: () => setState(() => _mood = sel ? null : e),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: sel
                                  ? AppTheme.accent.withAlphaPercent(0.15)
                                  : Colors.white.withAlphaPercent(0.5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: sel
                                    ? AppTheme.accent
                                    : Colors.white.withAlphaPercent(0.7),
                                width: sel ? 2 : 1.5,
                              ),
                            ),
                            child: Center(
                              child:
                                  Text(e, style: const TextStyle(fontSize: 22)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Save
              Container(
                height: 54,
                decoration: BoxDecoration(
                  color: AppTheme.accent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accent.withAlphaPercent(0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _saving ? null : _save,
                    child: Center(
                      child: _saving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5))
                          : Text(
                              _isEdit ? 'Save Changes' : 'Log Meal',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16),
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickEmoji() async {
    final result = await showEmojiPicker(context, _emoji);
    if (result != null) setState(() => _emoji = result);
  }
}
