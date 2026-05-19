import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../models/food_log_entry.dart';
import '../utils/app_theme.dart';
import 'glass_card.dart';

class FoodLogTile extends StatelessWidget {
  final FoodLogEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const FoodLogTile({
    super.key,
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Slidable(
        key: ValueKey(entry.id),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emoji
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.accent.withAlphaPercent(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppTheme.accent.withAlphaPercent(0.25),
                      width: 1.5),
                ),
                child: Center(
                  child:
                      Text(entry.emoji, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.mealName,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 20),
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
                              child: Text('Edit log'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text(
                                'Delete log',
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (entry.notes.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        entry.notes,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('h:mm a').format(entry.loggedAt),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.05, end: 0),
    );
  }
}
