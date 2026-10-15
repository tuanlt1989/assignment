import 'package:flutter/material.dart';

import '../main.dart';
import '../meta.dart';
import 'paywall_screen.dart';

class ThemesScreen extends StatelessWidget {
  const ThemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = GameApp.of(context);
    final t = app.t;
    return ListenableBuilder(
      listenable: app.progress,
      builder: (context, _) {
        final p = app.progress;
        final scheme = Theme.of(context).colorScheme;
        return Scaffold(
          appBar: AppBar(title: Text(t.t('themes'))),
          body: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: gameThemes.length,
            itemBuilder: (context, i) {
              final th = gameThemes[i];
              final color = th.seed ?? app.config.color;
              final open = themeUnlocked(p, i);
              final selected = p.themeIndex == i;
              final preview = ColorScheme.fromSeed(
                seedColor: color,
                brightness: th.dark ? Brightness.dark : Brightness.light,
              );
              return Material(
                color: preview.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: selected ? scheme.primary : scheme.outlineVariant,
                    width: selected ? 3 : 1,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    if (open) {
                      p.setTheme(i);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PaywallScreen(),
                        ),
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            for (final c in [
                              preview.primary,
                              preview.secondaryContainer,
                              preview.tertiary,
                            ])
                              Container(
                                width: 22,
                                height: 22,
                                margin: const EdgeInsets.only(right: 4),
                                decoration: BoxDecoration(
                                  color: c,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            const Spacer(),
                            if (selected)
                              Icon(Icons.check_circle, color: preview.primary)
                            else if (!open)
                              Icon(Icons.lock, color: preview.outline),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          t.t(th.key),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: preview.onSurface,
                          ),
                        ),
                        if (!open)
                          Text(
                            t.t('needStars', {'n': th.stars}),
                            style: TextStyle(
                              fontSize: 12,
                              color: preview.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
