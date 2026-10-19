import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import 'paywall_screen.dart';

/// Key facts to memorise, one card per rule or table, grouped by topic.
/// Free users see the first [freePerTopic] cards of every topic.
class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  static const freePerTopic = 2;

  @override
  Widget build(BuildContext context) {
    final app = AppState.of(context);
    final s = app.s;
    final lang = app.progress.uiLang;
    final topics = [
      for (final c in app.bank.categories)
        if (app.bank.guide.any((g) => g.category == c.id)) c,
    ];
    return DefaultTabController(
      length: topics.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(s.t('studyGuide')),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [for (final c in topics) Tab(text: c.name(lang))],
          ),
        ),
        body: ListenableBuilder(
          listenable: app.progress,
          builder: (context, _) => TabBarView(
            children: [
              for (final c in topics)
                _TopicCards(
                  app: app,
                  cards: [
                    for (final g in app.bank.guide)
                      if (g.category == c.id) g,
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicCards extends StatelessWidget {
  const _TopicCards({required this.app, required this.cards});
  final AppState app;
  final List<GuideCard> cards;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: cards.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final card = cards[i];
        final locked = !app.premium && i >= GuideScreen.freePerTopic;
        return Card(
          color: scheme.surfaceContainerLow,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      locked ? Icons.lock_outline : Icons.lightbulb_outline,
                      size: 20,
                      color: scheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        card.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (locked)
                  FilledButton.tonalIcon(
                    icon: const Icon(Icons.lock_open),
                    label: Text(app.s.t('guideLocked')),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PaywallScreen()),
                    ),
                  )
                else
                  for (final item in card.items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 7, right: 10),
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: scheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
              ],
            ),
          ),
        );
      },
    );
  }
}
