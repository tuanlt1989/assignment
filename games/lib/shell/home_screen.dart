import 'dart:async';

import 'package:flutter/material.dart';

import '../main.dart';
import 'paywall_screen.dart';
import 'play_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    // Refresh the life timer once a second.
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = GameApp.of(context);
    final t = app.t;
    final p = app.progress;
    final scheme = Theme.of(context).colorScheme;
    final endless = app.config.game == 'blocks';
    return ListenableBuilder(
      listenable: Listenable.merge([p, app.money]),
      builder: (context, _) => Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [scheme.primaryContainer, scheme.surface],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      if (!endless) LivesChip(app: app),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.settings_outlined),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SettingsScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GameBadge(color: app.config.color, game: app.config.game),
                  const SizedBox(height: 20),
                  Text(
                    app.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    endless
                        ? '${t.t('best')}: ${p.bestScore}'
                        : t.t('level', {'n': p.level}),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(64),
                      textStyle: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    onPressed: () => startGame(context, daily: false),
                    child: Text(
                      endless
                          ? t.t('play')
                          : '${t.t('play')} · ${t.t('level', {'n': p.level})}',
                    ),
                  ),
                  if (!endless) ...[
                    const SizedBox(height: 12),
                    FilledButton.tonalIcon(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                      icon: Icon(
                        p.dailyDone ? Icons.check_circle : Icons.calendar_today,
                      ),
                      label: Text(
                        p.dailyDone ? t.t('dailyDone') : t.t('daily'),
                      ),
                      onPressed: p.dailyDone
                          ? null
                          : () => startGame(context, daily: true),
                    ),
                  ],
                  const SizedBox(height: 12),
                  if (!p.premium)
                    TextButton.icon(
                      icon: const Icon(Icons.all_inclusive),
                      label: Text(t.t('unlimited')),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PaywallScreen(),
                        ),
                      ),
                    )
                  else
                    Chip(
                      avatar: const Icon(Icons.all_inclusive, size: 18),
                      label: Text(t.t('unlimitedOn')),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Opens a level, or explains how to get lives back.
void startGame(BuildContext context, {required bool daily}) {
  final app = GameApp.of(context);
  if (app.config.game != 'blocks' && app.progress.lives <= 0) {
    showOutOfLives(context);
    return;
  }
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => PlayScreen(daily: daily)),
  );
}

void showOutOfLives(BuildContext context) {
  final app = GameApp.of(context);
  final t = app.t;
  final wait = app.progress.nextLifeIn ?? Duration.zero;
  showDialog<void>(
    context: context,
    builder: (c) => AlertDialog(
      icon: const Icon(Icons.heart_broken, color: Colors.red, size: 40),
      title: Text(t.t('noLives')),
      content: Text(
        '${t.t('noLivesBody')}\n\n${t.t('nextLife', {'t': fmtDuration(wait)})}',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(c),
          child: Text(t.t('later')),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(c);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PaywallScreen()),
            );
          },
          child: Text(t.t('unlimited')),
        ),
      ],
    ),
  );
}

String fmtDuration(Duration d) {
  final m = d.inMinutes.toString().padLeft(2, '0');
  final s = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

class LivesChip extends StatelessWidget {
  const LivesChip({super.key, required this.app});
  final GameApp app;

  @override
  Widget build(BuildContext context) {
    final p = app.progress;
    final wait = p.nextLifeIn;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.favorite, color: Colors.red, size: 20),
          const SizedBox(width: 4),
          Text(
            p.premium ? '∞' : '${p.lives}',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          if (wait != null) ...[
            const SizedBox(width: 8),
            Text(fmtDuration(wait), style: const TextStyle(fontSize: 13)),
          ],
          const SizedBox(width: 12),
          const Icon(Icons.lightbulb, color: Colors.amber, size: 20),
          const SizedBox(width: 4),
          Text(
            p.premium ? '∞' : '${p.hints}',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

/// Big round logo for the home screen.
class GameBadge extends StatelessWidget {
  const GameBadge({super.key, required this.color, required this.game});
  final Color color;
  final String game;

  @override
  Widget build(BuildContext context) {
    final icon = switch (game) {
      'arrow' => Icons.north_east,
      'queens' => Icons.pets,
      'blocks' => Icons.grid_view_rounded,
      'munch' => Icons.blur_on,
      'bus' => Icons.directions_bus,
      _ => Icons.extension,
    };
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(icon, size: 84, color: Colors.white),
    );
  }
}
