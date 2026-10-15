import 'package:flutter/material.dart';

import '../main.dart';
import '../meta.dart';
import '../progress.dart';
import 'home_screen.dart';
import 'paywall_screen.dart';
import 'play_screen.dart';

/// The last [GameProgress.archiveDays] daily puzzles. Today is free; older
/// days need Unlimited.
class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = GameApp.of(context);
    final t = app.t;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return ListenableBuilder(
      listenable: app.progress,
      builder: (context, _) {
        final p = app.progress;
        final scheme = Theme.of(context).colorScheme;
        return Scaffold(
          appBar: AppBar(title: Text(t.t('archive'))),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    Expanded(child: Text(t.t('archiveHint'))),
                    if (!p.premium) Icon(Icons.lock, color: scheme.outline),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: GameProgress.archiveDays,
                  itemBuilder: (context, i) {
                    final date = today.subtract(Duration(days: i));
                    final spec = DailySpec(date);
                    final stars = p.starsOf('day:${spec.key}');
                    final open = i == 0 || p.premium;
                    return Material(
                      color: stars > 0
                          ? scheme.primaryContainer
                          : scheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => open
                                ? PlayScreen(
                                    difficulty: spec.difficulty,
                                    level: spec.level,
                                    daily: spec,
                                  )
                                : const PaywallScreen(),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${date.day}/${date.month}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (stars > 0)
                              Stars(n: stars, size: 11)
                            else if (!open)
                              Icon(Icons.lock, size: 14, color: scheme.outline)
                            else
                              Icon(
                                Icons.play_arrow,
                                size: 16,
                                color: scheme.primary,
                              ),
                            Text(
                              t.diff(spec.difficulty),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 9,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
