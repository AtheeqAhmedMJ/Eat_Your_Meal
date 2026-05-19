import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../utils/app_theme.dart';
import '../widgets/food_log_tile.dart';
import '../widgets/glass_card.dart';
import 'add_log_screen.dart';
import '../models/food_log_entry.dart';

class DiaryTab extends StatefulWidget {
  const DiaryTab({super.key});

  @override
  State<DiaryTab> createState() => _DiaryTabState();
}

class _DiaryTabState extends State<DiaryTab> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final logs = state.logsForDate(_selectedDate);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: _buildFab(context),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _dateStrip()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: _dayHeader(context, logs),
            ),
          ),
          if (logs.isEmpty)
            SliverToBoxAdapter(child: _emptyState(context))
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final entry = logs[i];
                  return FoodLogTile(
                    entry: entry,
                    onEdit: () => _openEdit(context, entry),
                    onDelete: () => state.deleteLog(entry.id),
                  );
                },
                childCount: logs.length,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _dateStrip() {
    final today = DateTime.now();
    final days =
        List.generate(14, (i) => today.subtract(Duration(days: 13 - i)));

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        itemCount: days.length,
        itemBuilder: (ctx, i) {
          final d = days[i];
          final isSelected = d.year == _selectedDate.year &&
              d.month == _selectedDate.month &&
              d.day == _selectedDate.day;
          final isToday = d.year == today.year &&
              d.month == today.month &&
              d.day == today.day;

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = d),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                gradient: isSelected ? AppTheme.primaryGradient : null,
                color: isSelected ? null : Colors.white.withAlphaPercent(0.55),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primary
                      : isToday
                          ? AppTheme.primary.withAlphaPercent(0.4)
                          : Colors.white.withAlphaPercent(0.7),
                  width: isSelected ? 0 : 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.primary.withAlphaPercent(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE').format(d).substring(0, 2),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white70 : AppTheme.textLight,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${d.day}',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : AppTheme.textDark,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _dayHeader(BuildContext context, List<FoodLogEntry> logs) {
    final isToday = _selectedDate.day == DateTime.now().day &&
        _selectedDate.month == DateTime.now().month &&
        _selectedDate.year == DateTime.now().year;

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isToday
                      ? 'Today'
                      : DateFormat('EEEE, MMMM d').format(_selectedDate),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${logs.length} meal${logs.length == 1 ? '' : 's'} logged',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppTheme.textLight, fontSize: 12),
                ),
              ],
            ),
          ),
          if (logs.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.secondary.withAlphaPercent(0.15),
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: AppTheme.secondary.withAlphaPercent(0.3)),
              ),
              child: Text(
                logs.map((l) => l.emoji).join(' '),
                style: const TextStyle(fontSize: 14),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _emptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          const Text('📓', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 14),
          Text('Nothing logged yet',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Tap + to log what you ate today',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppTheme.textLight),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Widget _buildFab(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.accent,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accent.withAlphaPercent(0.4),
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
            MaterialPageRoute(
              builder: (_) => AddLogScreen(date: _selectedDate),
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, color: Colors.white, size: 22),
                SizedBox(width: 6),
                Text('Log Meal',
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

  void _openEdit(BuildContext context, FoodLogEntry entry) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => AddLogScreen(date: _selectedDate, existing: entry)),
    );
  }
}
