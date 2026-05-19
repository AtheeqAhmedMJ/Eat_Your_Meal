import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../utils/app_theme.dart';
import '../widgets/reminder_tile.dart';
import '../widgets/glass_card.dart';
import 'add_reminder_screen.dart';

class RemindersTab extends StatelessWidget {
  const RemindersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final reminders = state.reminders;
    final enabled = reminders.where((r) => r.enabled).length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: _buildFab(context),
      body: reminders.isEmpty
          ? _emptyState(context)
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                    child: _statsBar(context, enabled, reminders.length)),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final r = reminders[i];
                      return ReminderTile(
                        reminder: r,
                        onToggle: () => state.toggleReminder(r.id),
                        onDelete: () =>
                            _confirmDelete(context, state, r.id, r.name),
                        onEdit: () => _openEdit(context, r.id),
                      );
                    },
                    childCount: reminders.length,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
    );
  }

  Widget _statsBar(BuildContext context, int enabled, int total) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            _stat(context, '$enabled', 'Active', AppTheme.primary),
            _divider(),
            _stat(context, '${total - enabled}', 'Paused', AppTheme.textLight),
            _divider(),
            _stat(context, '$total', 'Total', AppTheme.accent),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Widget _stat(BuildContext ctx, String val, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(val,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: Theme.of(ctx)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: color.withAlphaPercent(0.7))),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 32,
        color: AppTheme.cardBorder,
        margin: const EdgeInsets.symmetric(horizontal: 8),
      );

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔔', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text('No reminders yet',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first meal reminder',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppTheme.textLight),
          ),
        ],
      ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.9, 0.9)),
    );
  }

  Widget _buildFab(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withAlphaPercent(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddReminderScreen()),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, color: Colors.white, size: 22),
                SizedBox(width: 6),
                Text('Add Reminder',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, AppState state, String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgTop,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Reminder?'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              state.deleteReminder(id);
              Navigator.pop(ctx);
            },
            child:
                const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _openEdit(BuildContext context, String id) {
    final state = context.read<AppState>();
    final reminder = state.reminders.firstWhere((r) => r.id == id);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddReminderScreen(existing: reminder)),
    );
  }
}
