import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

const List<String> kMealEmojis = [
  '🍳', '🥣', '🥪', '🍛', '🍜', '🍝', '🥗', '🍲', '🥩', '🍱',
  '🍔', '🌮', '🍕', '🥙', '🍣', '🍤', '🥘', '🍚', '🍞', '🥞',
  '🧆', '🍗', '🥦', '🫕', '🥚', '🧀', '🍎', '🫐', '🥑', '🍜',
];

class EmojiPicker extends StatefulWidget {
  final String selected;

  const EmojiPicker({
    super.key,
    required this.selected,
  });

  @override
  State<EmojiPicker> createState() => _EmojiPickerState();
}

class _EmojiPickerState extends State<EmojiPicker> {
  late String _current;

  @override
  void initState() {
    super.initState();
    _current = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bgTop.withAlphaPercent(0.97),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textLight.withAlphaPercent(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text('Pick an icon',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: kMealEmojis.map((e) {
              final isSelected = e == _current;
              return GestureDetector(
                onTap: () {
                  setState(() => _current = e);
                  Navigator.pop(context, e);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primary.withAlphaPercent(0.15)
                        : Colors.white.withAlphaPercent(0.6),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primary
                          : Colors.white.withAlphaPercent(0.8),
                      width: isSelected ? 2 : 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(e, style: const TextStyle(fontSize: 24)),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

Future<String?> showEmojiPicker(BuildContext context, String current) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => EmojiPicker(selected: current),
  );
}
