import 'package:flutter/material.dart';

import '../main.dart';
import '../meta.dart';
import '../progress.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = GameApp.of(context);
    final t = app.t;
    final p = app.progress;
    final scheme = Theme.of(context).colorScheme;
    final hours = p.totalPlayMs ~/ 3600000;
    final minutes = (p.totalPlayMs ~/ 60000) % 60;
    final tiles = [
      (Icons.extension, t.t('solvedTotal'), '${p.solvedTotal}'),
      (Icons.star_rounded, t.t('starsTotal'), '${p.starsTotal}'),
      (Icons.local_fire_department, t.t('curStreak'), '${p.currentStreak}'),
      (Icons.whatshot, t.t('bestStreak'), '${p.bestStreak}'),
      (Icons.timer_outlined, t.t('playTime'), '${hours}h ${minutes}m'),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(t.t('stats'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final (icon, label, value) in tiles)
                SizedBox(
                  width: (MediaQuery.sizeOf(context).width - 42) / 2,
                  child: Card(
                    elevation: 0,
                    color: scheme.surfaceContainerHigh,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(icon, color: scheme.primary),
                          const SizedBox(height: 6),
                          Text(
                            value,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            t.t('trophies'),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 8),
          for (final a in achievements)
            Card(
              elevation: 0,
              color: a.done(p)
                  ? scheme.primaryContainer
                  : scheme.surfaceContainerLow,
              child: ListTile(
                leading: Icon(
                  a.icon,
                  color: a.done(p) ? Colors.amber.shade700 : scheme.outline,
                  size: 30,
                ),
                title: Text(
                  t.t(a.key, {'n': a.goal}),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: LinearProgressIndicator(
                    value: a.current(p) / a.goal,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                trailing: Text('${a.current(p)}/${a.goal}'),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            t.t('bestTime'),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          for (var d = 0; d < GameProgress.difficulties; d++)
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(t.diff(d)),
              subtitle: Text(t.t('solvedN', {'n': p.solved[d]})),
              trailing: Text(
                p.bestMs[d] == 0 ? '–' : fmtTime(p.bestMs[d]),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
