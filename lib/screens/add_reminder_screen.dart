import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/meal_reminder.dart';
import '../services/app_state.dart';
import '../utils/app_theme.dart';
import '../widgets/gradient_scaffold.dart';
import '../widgets/glass_card.dart';
import '../widgets/emoji_picker.dart';

class AddReminderScreen extends StatefulWidget {
  final MealReminder? existing;
  const AddReminderScreen({super.key, this.existing});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late String _emoji;
  late TimeOfDay _time;
  late RepeatMode _repeat;
  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _emoji = e?.emoji ?? '🍳';
    _repeat = e?.repeat ?? RepeatMode.daily;
    if (e != null) {
      final parts = e.timeStr.split(':');
      _time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } else {
      final now = TimeOfDay.now();
      _time = TimeOfDay(hour: (now.hour + 1) % 24, minute: 0);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  String get _timeStr =>
      '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}';

  String _fmt12() {
    final h = _time.hour;
    final m = _time.minute;
    final ampm = h < 12 ? 'AM' : 'PM';
    final hh = h % 12 == 0 ? 12 : h % 12;
    return '$hh:${m.toString().padLeft(2, '0')} $ampm';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (mounted) setState(() => _saving = true);
    final state = context.read<AppState>();

    if (_isEdit) {
      final updated = widget.existing!.copyWith(
        name: _nameCtrl.text.trim(),
        emoji: _emoji,
        timeStr: _timeStr,
        repeat: _repeat,
      );
      await state.updateReminder(updated);
    } else {
      final reminder = MealReminder(
        id: state.newId(),
        name: _nameCtrl.text.trim(),
        emoji: _emoji,
        timeStr: _timeStr,
        repeat: _repeat,
        enabled: true,
        createdAt: DateTime.now(),
      );
      await state.addReminder(reminder);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Reminder' : 'New Reminder'),
        leading: const BackButton(),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Emoji + Name row
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Meal Details',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: AppTheme.textLight)),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Emoji button
                        GestureDetector(
                          onTap: _pickEmoji,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withAlphaPercent(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color:
                                      AppTheme.primary.withAlphaPercent(0.25),
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

              // Time picker
              GlassCard(
                onTap: _pickTime,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withAlphaPercent(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.access_time_rounded,
                          color: AppTheme.primary, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Reminder Time',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(color: AppTheme.textLight)),
                          const SizedBox(height: 2),
                          Text(_fmt12(),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(color: AppTheme.primary)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppTheme.textLight),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Repeat mode
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Repeat',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: AppTheme.textLight)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: RepeatMode.values.map((mode) {
                        final selected = _repeat == mode;
                        return ChoiceChip(
                          label: Text(mode.label),
                          selected: selected,
                          onSelected: (_) => setState(() => _repeat = mode),
                          selectedColor: AppTheme.primary,
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : AppTheme.textMid,
                            fontWeight: FontWeight.w600,
                          ),
                          backgroundColor: Colors.white.withAlphaPercent(0.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          side: BorderSide(
                            color: selected
                                ? AppTheme.primary
                                : Colors.white.withAlphaPercent(0.7),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _repeatHint(_repeat),
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppTheme.textLight, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Save button
              Container(
                height: 54,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withAlphaPercent(0.35),
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
                              _isEdit ? 'Save Changes' : 'Set Reminder',
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

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _pickEmoji() async {
    final result = await showEmojiPicker(context, _emoji);
    if (result != null) setState(() => _emoji = result);
  }

  String _repeatHint(RepeatMode mode) {
    switch (mode) {
      case RepeatMode.daily:
        return 'You\'ll be reminded every single day at this time.';
      case RepeatMode.weekdays:
        return 'Reminders fire Monday through Friday only.';
      case RepeatMode.weekends:
        return 'Reminders fire on Saturday and Sunday only.';
      case RepeatMode.once:
        return 'You\'ll be reminded once at the next occurrence of this time.';
    }
  }
}
