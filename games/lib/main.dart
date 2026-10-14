import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config.dart';
import 'i18n.dart';
import 'monetization.dart';
import 'progress.dart';
import 'shell/home_screen.dart';
import 'shell/play_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = await GameConfig.load();
  final progress = GameProgress(await SharedPreferences.getInstance());
  final money = Monetization(config, progress);
  final app = GameApp(config, progress, money, deviceLang());
  final demo = kIsWeb ? Uri.base.queryParameters['demo'] : null;
  if (demo != null) {
    progress.level = 27;
    progress.bestScore = 2480;
  }
  runApp(PuzzleApp(app: app, demo: demo));
  await money.init();
}

class GameApp {
  GameApp(this.config, this.progress, this.money, this.lang);
  final GameConfig config;
  final GameProgress progress;
  final Monetization money;
  final String lang;

  T get t => T(lang);
  String get title => config.titleFor(lang);

  static GameApp of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<GameScope>()!.app;
}

class GameScope extends InheritedWidget {
  const GameScope({super.key, required this.app, required super.child});
  final GameApp app;

  @override
  bool updateShouldNotify(GameScope oldWidget) => app != oldWidget.app;
}

class PuzzleApp extends StatelessWidget {
  const PuzzleApp({super.key, required this.app, this.demo});
  final GameApp app;

  /// Web-only store screenshot scenes: `?demo=home|play|play2|play3`.
  final String? demo;

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(seedColor: app.config.color);
    return GameScope(
      app: app,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: app.title,
        theme: ThemeData(
          colorScheme: scheme,
          fontFamily: 'Roboto',
          useMaterial3: true,
          appBarTheme: AppBarTheme(
            backgroundColor: scheme.surface,
            surfaceTintColor: Colors.transparent,
          ),
        ),
        home: switch (demo) {
          'play' => const PlayScreen(daily: false, demoLevel: 8),
          'play2' => const PlayScreen(daily: false, demoLevel: 23),
          'play3' => const PlayScreen(daily: true, demoLevel: 15),
          _ => const HomeScreen(),
        },
      ),
    );
  }
}
