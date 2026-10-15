import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config.dart';
import 'i18n.dart';
import 'meta.dart';
import 'monetization.dart';
import 'progress.dart';
import 'shell/home_screen.dart';
import 'shell/play_screen.dart';
import 'shell/stats_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = await GameConfig.load();
  final progress = GameProgress(await SharedPreferences.getInstance());
  final money = Monetization(config, progress);
  final app = GameApp(config, progress, money, deviceLang());
  final demo = kIsWeb ? Uri.base.queryParameters['demo'] : null;
  if (demo != null) progress.loadDemo();
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

  /// Web-only store screenshot scenes: `?demo=home|play|play2|stats`.
  final String? demo;

  @override
  Widget build(BuildContext context) {
    return GameScope(
      app: app,
      child: ListenableBuilder(
        listenable: app.progress,
        builder: (context, _) {
          final i = app.progress.themeIndex.clamp(0, gameThemes.length - 1);
          final th = gameThemes[themeUnlocked(app.progress, i) ? i : 0];
          final scheme = ColorScheme.fromSeed(
            seedColor: th.seed ?? app.config.color,
            brightness: th.dark ? Brightness.dark : Brightness.light,
          );
          return MaterialApp(
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
              'play' => const PlayScreen(difficulty: 1, level: 8, demo: true),
              'play2' => const PlayScreen(difficulty: 2, level: 3, demo: true),
              'stats' => const StatsScreen(),
              _ => const HomeScreen(),
            },
          );
        },
      ),
    );
  }
}
