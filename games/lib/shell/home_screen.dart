import 'package:flutter/material.dart';

import '../main.dart';
import '../meta.dart';
import '../progress.dart';
import 'archive_screen.dart';
import 'paywall_screen.dart';
import 'play_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';
import 'themes_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = GameApp.of(context);
    final t = app.t;
    final p = app.progress;
    final scheme = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: Listenable.merge([p, app.money]),
      builder: (context, _) => Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [scheme.primaryContainer, scheme.surface],
              stops: const [0, 0.45],
            ),
          ),
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                Row(
                  children: [
                    _Pill(
                      icon: Icons.local_fire_department,
                      color: Colors.deepOrange,
                      text: '${p.currentStreak}',
                    ),
                    const SizedBox(width: 8),
                    _Pill(
                      icon: Icons.star_rounded,
                      color: Colors.amber.shade700,
                      text: '${p.starsTotal}',
                    ),
                    const SizedBox(width: 8),
                    _Pill(
                      icon: Icons.lightbulb,
                      color: Colors.amber,
                      text: p.premium ? '∞' : '${p.hints}',
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () => _push(context, const SettingsScreen()),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GameBadge(
                      color: scheme.primary,
                      game: app.config.game,
                      size: 64,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        app.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _DailyCard(app: app),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.25,
                  children: [
                    for (var d = 0; d < GameProgress.difficulties; d++)
                      _DifficultyCard(app: app, difficulty: d),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _MenuButton(
                        icon: Icons.emoji_events_outlined,
                        label: t.t('stats'),
                        onTap: () => _push(context, const StatsScreen()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MenuButton(
                        icon: Icons.palette_outlined,
                        label: t.t('themes'),
                        onTap: () => _push(context, const ThemesScreen()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (!p.premium)
                  FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    icon: const Icon(Icons.all_inclusive),
                    label: Text(t.t('unlimited')),
                    onPressed: () => _push(context, const PaywallScreen()),
                  )
                else
                  Center(
                    child: Chip(
                      avatar: const Icon(Icons.all_inclusive, size: 18),
                      label: Text(t.t('unlimitedOn')),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _push(BuildContext context, Widget screen) =>
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

/// Opens the next puzzle of [difficulty], or explains the free daily limit.
void startPuzzle(BuildContext context, int difficulty, {int? level}) {
  final app = GameApp.of(context);
  final p = app.progress;
  final n = level ?? p.next[difficulty];
  if (!p.canStart(difficulty, n)) {
    showQuotaDialog(context, difficulty);
    return;
  }
  p.markStarted(difficulty, n);
  _push(context, PlayScreen(difficulty: difficulty, level: n));
}

void showQuotaDialog(BuildContext context, int difficulty) {
  final t = GameApp.of(context).t;
  showDialog<void>(
    context: context,
    builder: (c) => AlertDialog(
      icon: const Icon(Icons.hourglass_bottom, size: 40),
      title: Text(t.t('quotaTitle')),
      content: Text(t.t('quotaBody', {'d': t.diff(difficulty)})),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(c),
          child: Text(t.t('later')),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(c);
            _push(context, const PaywallScreen());
          },
          child: Text(t.t('unlimited')),
        ),
      ],
    ),
  );
}

class _DailyCard extends StatelessWidget {
  const _DailyCard({required this.app});
  final GameApp app;

  @override
  Widget build(BuildContext context) {
    final t = app.t;
    final p = app.progress;
    final spec = DailySpec(DateTime.now());
    final done = p.dailyDone;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: scheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, color: scheme.onPrimary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t.t('daily'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: scheme.onPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  t.diff(spec.difficulty),
                  style: TextStyle(
                    color: scheme.onPrimary.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              t.t('streak', {'n': p.currentStreak}),
              style: TextStyle(color: scheme.onPrimary.withValues(alpha: 0.85)),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: done
                      ? Row(
                          children: [
                            Stars(
                              n: p.starsOf('day:${spec.key}'),
                              color: Colors.amber.shade300,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                t.t('dailyDone'),
                                style: TextStyle(
                                  color: scheme.onPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        )
                      : FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: scheme.onPrimary,
                            foregroundColor: scheme.primary,
                            minimumSize: const Size.fromHeight(48),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          onPressed: () => _push(
                            context,
                            PlayScreen(
                              difficulty: spec.difficulty,
                              level: spec.level,
                              daily: spec,
                            ),
                          ),
                          child: Text(t.t('play')),
                        ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: t.t('archive'),
                  icon: const Icon(Icons.history),
                  onPressed: () => _push(context, const ArchiveScreen()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  const _DifficultyCard({required this.app, required this.difficulty});
  final GameApp app;
  final int difficulty;

  @override
  Widget build(BuildContext context) {
    final t = app.t;
    final p = app.progress;
    final scheme = Theme.of(context).colorScheme;
    final left = p.leftToday(difficulty);
    final locked = !p.canStart(difficulty, p.next[difficulty]);
    const dots = [1, 2, 3, 4];
    return Material(
      color: scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => startPuzzle(context, difficulty),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  for (final i in dots)
                    Padding(
                      padding: const EdgeInsets.only(right: 3),
                      child: Icon(
                        Icons.circle,
                        size: 9,
                        color: i <= difficulty + 1
                            ? scheme.primary
                            : scheme.outlineVariant,
                      ),
                    ),
                  const Spacer(),
                  if (locked)
                    Icon(Icons.lock, size: 18, color: scheme.outline)
                  else if (left != null)
                    Text(
                      '$left',
                      style: TextStyle(
                        color: scheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                ],
              ),
              const Spacer(),
              Text(
                t.diff(difficulty),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                t.t('puzzleN', {'n': p.next[difficulty]}),
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 2),
              Text(
                left != null
                    ? t.t('leftToday', {'n': left})
                    : t.t('solvedN', {'n': p.solved[difficulty]}),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: left != null ? scheme.primary : scheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      icon: Icon(icon),
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      onPressed: onTap,
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.color, required this.text});
  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

/// 1–3 stars.
class Stars extends StatelessWidget {
  const Stars({super.key, required this.n, this.size = 20, this.color});
  final int n;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final on = color ?? Colors.amber.shade600;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 3; i++)
          Icon(
            i < n ? Icons.star_rounded : Icons.star_outline_rounded,
            size: size,
            color: i < n ? on : on.withValues(alpha: 0.45),
          ),
      ],
    );
  }
}

/// Rounded logo for the game.
class GameBadge extends StatelessWidget {
  const GameBadge({
    super.key,
    required this.color,
    required this.game,
    this.size = 140,
  });
  final Color color;
  final String game;
  final double size;

  @override
  Widget build(BuildContext context) {
    final icon = switch (game) {
      'queens' => Icons.pets,
      'pips' => Icons.casino_outlined,
      'patches' => Icons.dashboard_outlined,
      'weave' => Icons.gesture,
      'putt' => Icons.golf_course,
      'tango' => Icons.brightness_6,
      'culprit' => Icons.search,
      _ => Icons.extension,
    };
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size / 4),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: size / 6,
            offset: Offset(0, size / 14),
          ),
        ],
      ),
      child: Icon(icon, size: size * 0.6, color: Colors.white),
    );
  }
}
