import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/meal_reminder.dart';
import '../utils/app_theme.dart';
import 'glass_card.dart';

class ReminderTile extends StatelessWidget {
  final MealReminder reminder;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const ReminderTile({
    super.key,
    required this.reminder,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  String _fmt12(String timeStr) {
    final parts = timeStr.split(':');
    final h = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    final ampm = h < 12 ? 'AM' : 'PM';
    final hh = h % 12 == 0 ? 12 : h % 12;
    return '$hh:${m.toString().padLeft(2, '0')} $ampm';
  }

  String _countdown(String timeStr) {
    final parts = timeStr.split(':');
    final h = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    final now = DateTime.now();
    var target = DateTime(now.year, now.month, now.day, h, m);
    if (target.isBefore(now)) target = target.add(const Duration(days: 1));
    final diff = target.difference(now);
    if (diff.inMinutes < 1) return 'Any moment…';
    if (diff.inMinutes < 60) return 'In ${diff.inMinutes}m';
    final hrs = diff.inHours;
    final mins = diff.inMinutes % 60;
    return mins == 0 ? 'In ${hrs}h' : 'In ${hrs}h ${mins}m';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Slidable(
        key: ValueKey(reminder.id),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onEdit(),
              backgroundColor: AppTheme.primary.withAlphaPercent(0.15),
              foregroundColor: AppTheme.primary,
              icon: Icons.edit_rounded,
              label: 'Edit',
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(16)),
            ),
            SlidableAction(
              onPressed: (_) => onDelete(),
              backgroundColor: const Color(0xFFFFEEEE),
              foregroundColor: Colors.redAccent,
              icon: Icons.delete_rounded,
              label: 'Delete',
              borderRadius:
                  const BorderRadius.horizontal(right: Radius.circular(16)),
            ),
          ],
        ),
        child: GlassCard(
          onTap: onEdit,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Emoji bubble
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: reminder.enabled
                      ? AppTheme.primary.withAlphaPercent(0.12)
                      : Colors.grey.withAlphaPercent(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: reminder.enabled
                        ? AppTheme.primary.withAlphaPercent(0.25)
                        : Colors.grey.withAlphaPercent(0.2),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(reminder.emoji,
                      style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: reminder.enabled
                                ? AppTheme.textDark
                                : AppTheme.textLight,
                            decoration: reminder.enabled
                                ? null
                                : TextDecoration.lineThrough,
                          ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded,
                            size: 13, color: AppTheme.textLight),
                        const SizedBox(width: 4),
                        Text(
                          _fmt12(reminder.timeStr),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 10),
                        _chip(context, reminder.repeat.shortLabel),
                      ],
                    ),
                    if (reminder.enabled) ...[
                      const SizedBox(height: 3),
                      Text(
                        _countdown(reminder.timeStr),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                      ),
                    ],
                  ],
                ),
              ),

              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                tooltip: 'More options',
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit reminder'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'Delete reminder',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ],
              ),

              Transform.scale(
                scale: 0.85,
                child: Switch.adaptive(
                  value: reminder.enabled,
                  onChanged: (_) => onToggle(),
                  activeColor: AppTheme.primary,
                  activeTrackColor: AppTheme.primary.withAlphaPercent(0.3),
                  inactiveTrackColor: Colors.grey.withAlphaPercent(0.2),
                  inactiveThumbColor: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.05, end: 0),
    );
  }

  Widget _chip(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.secondary.withAlphaPercent(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppTheme.secondary.withAlphaPercent(0.3), width: 1),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.secondary.withAlphaPercent(1.0),
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
