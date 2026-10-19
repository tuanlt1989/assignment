import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_state.dart';
import 'demo.dart';
import 'models.dart';
import 'monetization.dart';
import 'progress.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = await AppConfig.load();
  final bank = await Bank.load(config.bank);
  final progress = Progress(
    await SharedPreferences.getInstance(),
    config.primary,
  );
  final money = Monetization(config, progress);
  final app = AppState(config, bank, progress, money);
  final demo = kIsWeb ? Uri.base.queryParameters['demo'] : null;
  if (demo != null) DemoScene.seed(app, demo);
  runApp(ExamApp(app: app, demo: demo));
  await money.init();
  // Refresh the reminder text/time (language or goal may have changed).
  await app.syncReminder();
}

class ExamApp extends StatelessWidget {
  const ExamApp({super.key, required this.app, this.demo});
  final AppState app;
  final String? demo;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      app: app,
      child: ListenableBuilder(
        listenable: app.progress,
        builder: (context, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: app.config.titleFor(app.progress.uiLang),
          theme: _theme(app.config.color, Brightness.light),
          darkTheme: _theme(app.config.color, Brightness.dark),
          home: demo != null
              ? DemoScene(scene: demo!)
              : app.progress.onboarded
              ? const HomeScreen()
              : const OnboardingScreen(),
        ),
      ),
    );
  }

  ThemeData _theme(Color seed, Brightness b) {
    final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: b);
    return ThemeData(
      colorScheme: scheme,
      fontFamily: 'Roboto',
      useMaterial3: true,
      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
    );
  }
}
