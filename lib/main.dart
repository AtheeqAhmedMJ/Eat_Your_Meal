import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/app_state.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  await NotificationService.instance.init();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState()..init(),
      child: const EatYourMealApp(),
    ),
  );
}

class EatYourMealApp extends StatelessWidget {
  const EatYourMealApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eat Your Meal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      builder: (context, child) => Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: child!,
      ),
      home: const _AppGate(),
    );
  }
}

class _AppGate extends StatefulWidget {
  const _AppGate();
  @override
  State<_AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<_AppGate> {
  bool _permAsked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.watch<AppState>();
    if (!state.loading && !_permAsked) {
      _permAsked = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await NotificationService.instance.requestPermission();
        for (final r in state.reminders) {
          if (r.enabled) await NotificationService.instance.scheduleReminder(r);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (state.loading) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🍽️', style: TextStyle(fontSize: 64)),
              SizedBox(height: 16),
              Text('Eat Your Meal',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  )),
            ],
          ),
        ),
      );
    }
    return const HomeScreen();
  }
}
