import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import 'paywall_screen.dart';

/// Question on the front, correct answer + explanation on the back. "I know
/// it" / "Not yet" feed the same mastery data as the quizzes.
class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key, required this.cards});
  final List<Question> cards;

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  int _index = 0;
  bool _flipped = false;
  int _known = 0;

  void _answer(AppState app, bool known) {
    app.progress.recordAnswer(widget.cards[_index].id, known);
    setState(() {
      if (known) _known++;
      _index++;
      _flipped = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = AppState.of(context);
    final s = app.s;
    final scheme = Theme.of(context).colorScheme;
    final n = widget.cards.length;

    if (_index >= n) {
      return Scaffold(
        appBar: AppBar(title: Text(s.t('flashcards'))),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.celebration_outlined,
                  size: 72,
                  color: scheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  s.t('fcDone', {'n': n}),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  '$_known / $n · ${s.t('fcKnow')}',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () {
                    final nav = Navigator.of(context);
                    final upsell = app.money.onSessionFinished();
                    nav.pop();
                    if (upsell) {
                      nav.push(
                        MaterialPageRoute(
                          builder: (_) => const PaywallScreen(),
                        ),
                      );
                    }
                  },
                  child: Text(s.t('home')),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final q = widget.cards[_index];
    final t = q.text(app.questionLang);
    final helper =
        app.progress.showHelperLang &&
            app.helperLang != null &&
            q.hasLang(app.helperLang!)
        ? q.text(app.helperLang!)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.t('flashcards')),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: (_index + 1) / n),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _flipped = !_flipped),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Card(
                      key: ValueKey('$_index-$_flipped'),
                      color: _flipped
                          ? scheme.primaryContainer
                          : scheme.surfaceContainerHighest,
                      child: SizedBox.expand(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _flipped
                                ? [
                                    Text(
                                      t.options[q.answer],
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    if (helper != null &&
                                        q.answer < helper.options.length)
                                      Text(
                                        helper.options[q.answer],
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: scheme.onSurfaceVariant,
                                        ),
                                      ),
                                    const SizedBox(height: 16),
                                    Text(
                                      t.explanation,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        height: 1.4,
                                      ),
                                    ),
                                  ]
                                : [
                                    Text(
                                      s.t('question', {
                                        'i': _index + 1,
                                        'n': n,
                                      }),
                                      style: TextStyle(
                                        color: scheme.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      t.question,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        height: 1.35,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (helper != null) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        helper.question,
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: scheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 24),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.touch_app_outlined,
                                          color: scheme.onSurfaceVariant,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          s.t('fcTap'),
                                          style: TextStyle(
                                            color: scheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                      icon: const Icon(Icons.replay),
                      label: Text(s.t('fcAgain')),
                      onPressed: () => _answer(app, false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                      icon: const Icon(Icons.check),
                      label: Text(s.t('fcKnow')),
                      onPressed: () => _answer(app, true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
