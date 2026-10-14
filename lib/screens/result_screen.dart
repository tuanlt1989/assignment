import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../progress.dart';
import 'paywall_screen.dart';
import 'quiz_screen.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({
    super.key,
    required this.title,
    required this.questions,
    required this.picked,
    required this.exam,
    this.lockedLeft = 0,
  });

  final String title;
  final List<Question> questions;
  final Map<int, int> picked;
  final bool exam;
  final int lockedLeft;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _recorded = false;

  int get _correct => [
    for (var i = 0; i < widget.questions.length; i++)
      if (widget.picked[i] == widget.questions[i].answer) i,
  ].length;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_recorded) return;
    _recorded = true;
    final app = AppState.of(context);
    final total = widget.questions.length;
    final passed = _correct * 100 >= app.config.passPercent * total;
    if (widget.exam) {
      app.progress.addExam(ExamRecord(DateTime.now(), _correct, total, passed));
    }
    // Let the result render first, then show the interstitial or review ask.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.exam && passed) {
        app.progress.finishSession();
        app.money.maybeAskReview();
      } else {
        app.money.onSessionFinished();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = AppState.of(context);
    final s = app.s;
    final scheme = Theme.of(context).colorScheme;
    final total = widget.questions.length;
    final percent = total == 0 ? 0 : (_correct * 100 / total).round();
    final passed = percent >= app.config.passPercent;
    final color = passed ? Colors.green.shade600 : Colors.orange.shade800;

    // Per-topic breakdown.
    final byCat = <String, (int, int)>{};
    for (var i = 0; i < total; i++) {
      final q = widget.questions[i];
      final (c, t) = byCat[q.category] ?? (0, 0);
      byCat[q.category] = (c + (widget.picked[i] == q.answer ? 1 : 0), t + 1);
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: color.withValues(alpha: 0.12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
              child: Column(
                children: [
                  Text(
                    '$percent%',
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                  if (widget.exam)
                    Text(
                      passed ? s.t('passed') : s.t('notYet'),
                      style: TextStyle(
                        fontSize: 20,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    s.t('scoreLine', {'c': _correct, 't': total}),
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    s.t('passLine', {'p': app.config.passPercent}),
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
          if (widget.lockedLeft > 0 && !app.premium) ...[
            const SizedBox(height: 16),
            Card(
              color: scheme.tertiaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      s.t('freeDone'),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    FilledButton.icon(
                      icon: const Icon(Icons.lock_open),
                      label: Text(s.t('unlockMore', {'n': widget.lockedLeft})),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PaywallScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (byCat.length > 1) ...[
            const SizedBox(height: 20),
            Text(
              s.t('byTopic'),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            for (final c in app.bank.categories)
              if (byCat[c.id] case (final ok, final t))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          c.name(app.progress.uiLang),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: ok / t,
                            minHeight: 8,
                            color: ok * 100 >= app.config.passPercent * t
                                ? Colors.green.shade600
                                : Colors.orange.shade800,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 52,
                        child: Text('$ok/$t', textAlign: TextAlign.end),
                      ),
                    ],
                  ),
                ),
          ],
          const SizedBox(height: 24),
          FilledButton.tonalIcon(
            icon: const Icon(Icons.fact_check_outlined),
            label: Text(s.t('reviewAnswers')),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReviewScreen(
                  questions: widget.questions,
                  picked: widget.picked,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.refresh),
            label: Text(s.t('tryAgain')),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => QuizScreen(
                  title: widget.title,
                  questions: widget.exam
                      ? app.pickExam()
                      : (List.of(widget.questions)..shuffle()),
                  exam: widget.exam,
                  lockedLeft: widget.lockedLeft,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(s.t('home')),
          ),
        ],
      ),
    );
  }
}

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({
    super.key,
    required this.questions,
    required this.picked,
  });
  final List<Question> questions;
  final Map<int, int> picked;

  @override
  Widget build(BuildContext context) {
    final app = AppState.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(app.s.t('reviewAnswers'))),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: questions.length,
        separatorBuilder: (_, _) => const Divider(height: 32),
        itemBuilder: (context, i) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              app.s.t('question', {'i': i + 1, 'n': questions.length}),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            QuestionView(
              question: questions[i],
              lang: app.questionLang,
              helperLang: app.progress.showHelperLang ? app.helperLang : null,
              picked: picked[i],
              reveal: true,
            ),
          ],
        ),
      ),
    );
  }
}
