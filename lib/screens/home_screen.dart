import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_theme.dart';
import 'reminders_tab.dart';
import 'diary_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _tab = 0;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _tab = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth >= 760;
      final navHeight = isWide ? 90.0 : 72.0;
      final iconSize = isWide ? 26.0 : 22.0;

      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.white.withAlphaPercent(0.4),
          title: Row(children: [
            Container(
              width: isWide ? 40 : 34,
              height: isWide ? 40 : 34,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                  child: Text('🍽️', style: TextStyle(fontSize: 18))),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Eat Your Meal',
                style: TextStyle(
                  fontSize: isWide ? 24 : 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.24,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ]),
        ),
        bottomNavigationBar: SizedBox(
          height: navHeight,
          child: _BottomNav(
            tab: _tab,
            iconSize: iconSize,
            isWide: isWide,
            onTap: (i) {
              _tabController.animateTo(i);
              setState(() => _tab = i);
            },
          ),
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 420),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInOutCubic,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.03),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: SizedBox(
            key: ValueKey<int>(_tab),
            child: TabBarView(
              controller: _tabController,
              children: const [RemindersTab(), DiaryTab()],
            ),
          ),
        ),
      );
    });
  }
}

class _BottomNav extends StatelessWidget {
  final int tab;
  final bool isWide;
  final double iconSize;
  final ValueChanged<int> onTap;
  const _BottomNav({
    required this.tab,
    required this.onTap,
    required this.iconSize,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlphaPercent(0.5),
        border: Border(
            top: BorderSide(
                color: Colors.white.withAlphaPercent(0.6), width: 1.5)),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: isWide
              ? MainAxisAlignment.spaceAround
              : MainAxisAlignment.spaceEvenly,
          children: [
            _item(context, 0, Icons.notifications_rounded,
                Icons.notifications_outlined, 'Reminders'),
            _item(context, 1, Icons.menu_book_rounded, Icons.menu_book_outlined,
                'Food Diary'),
          ],
        ),
      ),
    );
  }

  Widget _item(BuildContext ctx, int i, IconData active, IconData inactive,
      String label) {
    final sel = tab == i;
    return GestureDetector(
      onTap: () => onTap(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: isWide ? 12 : 0),
        padding: EdgeInsets.symmetric(
          horizontal: isWide ? 20 : 18,
          vertical: isWide ? 12 : 8,
        ),
        decoration: BoxDecoration(
          color: sel
              ? AppTheme.primary.withAlphaPercent(0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(sel ? active : inactive,
              color: sel ? AppTheme.primary : AppTheme.textLight,
              size: iconSize),
          if (sel) ...[
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13)),
          ],
        ]),
      ).animate().fadeIn(duration: 250.ms),
    );
  }
}
