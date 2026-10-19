import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_state.dart';
import '../i18n.dart';
import '../models.dart';
import '../monetization.dart';
import '../speech.dart';
import 'result_screen.dart';

/// Practice mode: answer, see the explanation right away.
/// Exam mode: timed, no feedback until you submit.
class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    required this.title,
    required this.questions,
    this.exam = false,
    this.lockedLeft = 0,
    this.initialPick,
    this.spec,
  });

  /// Timing and pass mark of an exam; null means the full mock exam.
  final ExamSpec? spec;

  /// Pre-selected answer for the first question (store screenshots only).
  final int? initialPick;

  final String title;
  final List<Question> questions;
  final bool exam;

  /// Premium questions left in this topic, for the upsell at the end.
  final int lockedLeft;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _index = 0;
  final Map<int, int> _picked = {};
  final _rng = Random();
  late final List<List<int>> _orders = [
    for (final q in widget.questions)
      List.generate(q.text('en').options.length, (i) => i)..shuffle(_rng),
  ];
  late bool _showHelper;
  Timer? _timer;
  late int _secondsLeft;
  bool _done = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_timer != null || _done) return;
    final app = AppState.of(context);
    _showHelper = app.progress.showHelperLang;
    if (widget.initialPick != null) _picked[0] = widget.initialPick!;
    _secondsLeft = (widget.spec ?? app.fullExam).minutes * 60;
    if (widget.exam) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => _secondsLeft--);
        if (_secondsLeft <= 0) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(app.s.t('timeUp'))));
          _finish(app);
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    Speech.instance.stop();
    super.dispose();
  }

  /// Reads the question and its options (in display order) aloud: in the
  /// helper language while it is shown (to learn the terms), else the main one.
  Future<void> _readAloud(AppState app) async {
    final lang =
        _showHelper && app.helperLang != null && _q.hasLang(app.helperLang!)
        ? app.helperLang!
        : app.questionLang;
    final t = _q.text(lang);
    final options = [
      for (final (pos, i) in _orders[_index].indexed)
        if (i < t.options.length)
          '${String.fromCharCode(65 + pos)}. ${t.options[i]}',
    ];
    final ok = await Speech.instance.speak(
      [t.question, ...options].join('\n'),
      lang,
    );
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            app.s.t('noVoice', {'lang': S.languageNames[lang] ?? lang}),
          ),
        ),
      );
    }
  }

  /// Emails support about the current question (wrong answer, typo...).
  void _report(AppState app) {
    final t = _q.text(app.questionLang);
    launchUrl(
      Uri(
        scheme: 'mailto',
        path: app.config.supportEmail,
        queryParameters: {
          'subject': '${app.config.titleFor('en')} – question ${_q.id}',
          'body': app.s.t('reportBody', {'id': _q.id, 'q': t.question}),
        },
      ),
    );
  }

  Question get _q => widget.questions[_index];
  bool get _last => _index == widget.questions.length - 1;

  void _pick(AppState app, int option) {
    if (widget.exam) {
      setState(() => _picked[_index] = option);
      return;
    }
    if (_picked.containsKey(_index)) return;
    setState(() => _picked[_index] = option);
    app.progress.recordAnswer(_q.id, option == _q.answer);
  }

  void _finish(AppState app) {
    if (_done) return;
    _done = true;
    _timer?.cancel();
    if (widget.exam) {
      for (final e in _picked.entries) {
        final q = widget.questions[e.key];
        app.progress.recordAnswer(q.id, e.value == q.answer);
      }
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          title: widget.title,
          questions: widget.questions,
          picked: Map.of(_picked),
          exam: widget.exam,
          lockedLeft: widget.lockedLeft,
          spec: widget.spec,
        ),
      ),
    );
  }

  Future<void> _submit(AppState app) async {
    final s = app.s;
    final unanswered = widget.questions.length - _picked.length;
    if (unanswered > 0) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text(s.t('submitTitle')),
          content: Text(s.t('submitBody', {'n': unanswered})),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: Text(s.t('cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: Text(s.t('submit')),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }
    _finish(app);
  }

  Future<bool> _confirmLeave(AppState app) async {
    if (_picked.isEmpty) return true;
    final s = app.s;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(s.t('leaveTitle')),
        content: widget.exam ? null : Text(s.t('leaveBody')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(s.t('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(s.t('leave')),
          ),
        ],
      ),
    );
    return ok == true;
  }

  @override
  Widget build(BuildContext context) {
    final app = AppState.of(context);
    final s = app.s;
    final scheme = Theme.of(context).colorScheme;
    final picked = _picked[_index];
    final answered = picked != null;
    final n = widget.questions.length;
    final saved = app.progress.bookmarks.contains(_q.id);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final nav = Navigator.of(context);
        if (await _confirmLeave(app)) nav.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title, overflow: TextOverflow.ellipsis),
          actions: [
            if (widget.exam)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Chip(
                  avatar: const Icon(Icons.timer_outlined, size: 18),
                  label: Text(_clock(_secondsLeft)),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            IconButton(
              tooltip: s.t('reportQuestion'),
              icon: const Icon(Icons.outlined_flag),
              onPressed: () => _report(app),
            ),
            IconButton(
              tooltip: s.t('saved'),
              icon: Icon(saved ? Icons.bookmark : Icons.bookmark_outline),
              onPressed: () =>
                  setState(() => app.progress.toggleBookmark(_q.id)),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: LinearProgressIndicator(value: (_index + 1) / n),
          ),
        ),
        bottomNavigationBar: widget.exam ? null : BannerSlot(money: app.money),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  children: [
                    Row(
                      children: [
                        Text(
                          s.t('question', {'i': _index + 1, 'n': n}),
                          style: TextStyle(
                            color: scheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          tooltip: s.t('readAloud'),
                          icon: const Icon(Icons.volume_up_outlined),
                          visualDensity: VisualDensity.compact,
                          onPressed: () => _readAloud(app),
                        ),
                        if (app.helperLang != null &&
                            _q.hasLang(app.helperLang!))
                          FilterChip(
                            label: Text(
                              s.t('showHelper', {
                                'lang':
                                    S.languageNames[app.helperLang] ??
                                    app.helperLang!,
                              }),
                            ),
                            selected: _showHelper,
                            onSelected: (v) => setState(() => _showHelper = v),
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    QuestionView(
                      question: _q,
                      lang: app.questionLang,
                      helperLang: _showHelper ? app.helperLang : null,
                      picked: picked,
                      order: _orders[_index],
                      reveal: !widget.exam && answered,
                      onPick: (o) => _pick(app, o),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Row(
                  children: [
                    if (widget.exam && _index > 0)
                      OutlinedButton(
                        onPressed: () {
                          Speech.instance.stop();
                          setState(() => _index--);
                        },
                        child: Text(s.t('previous')),
                      ),
                    const Spacer(),
                    if (widget.exam && !_last)
                      TextButton(
                        onPressed: () => _submit(app),
                        child: Text(s.t('submit')),
                      ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: (!widget.exam && !answered)
                          ? null
                          : () {
                              if (_last) {
                                widget.exam ? _submit(app) : _finish(app);
                              } else {
                                Speech.instance.stop();
                                setState(() => _index++);
                              }
                            },
                      child: Text(
                        _last
                            ? (widget.exam ? s.t('submit') : s.t('finish'))
                            : s.t('next'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _clock(int secs) {
    final v = secs < 0 ? 0 : secs;
    final m = (v ~/ 60).toString().padLeft(2, '0');
    final sec = (v % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }
}

/// A question with its options. Used by the quiz and the review list.
class QuestionView extends StatelessWidget {
  const QuestionView({
    super.key,
    required this.question,
    required this.lang,
    this.helperLang,
    this.picked,
    this.order,
    this.reveal = false,
    this.onPick,
  });

  final Question question;
  final String lang;
  final String? helperLang;

  /// Original option indexes, in display order. Null shows the bank order.
  final List<int>? order;

  /// [picked] and [onPick] always use original option indexes.
  final int? picked;
  final bool reveal;
  final ValueChanged<int>? onPick;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t = question.text(lang);
    final h =
        helperLang != null &&
            helperLang != lang &&
            question.hasLang(helperLang!)
        ? question.text(helperLang!)
        : null;
    final s = AppState.of(context).s;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          t.question,
          style: const TextStyle(
            fontSize: 18,
            height: 1.35,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (h != null) ...[
          const SizedBox(height: 6),
          Text(
            h.question,
            style: TextStyle(
              fontSize: 15,
              height: 1.3,
              fontStyle: FontStyle.italic,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 16),
        for (final (pos, i) in _order(t.options.length).indexed) ...[
          _OptionTile(
            letter: String.fromCharCode(65 + pos),
            text: t.options[i],
            helper: h != null && i < h.options.length ? h.options[i] : null,
            state: _state(i),
            onTap: onPick == null ? null : () => onPick!(i),
          ),
          const SizedBox(height: 10),
        ],
        if (reveal) ...[
          const SizedBox(height: 6),
          Card(
            color: picked == question.answer
                ? Colors.green.withValues(alpha: 0.12)
                : Colors.red.withValues(alpha: 0.10),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    picked == question.answer
                        ? s.t('correct')
                        : (picked == null
                              ? s.t('correctAnswer', {
                                  'a': String.fromCharCode(
                                    65 +
                                        _order(
                                          t.options.length,
                                        ).indexOf(question.answer),
                                  ),
                                })
                              : s.t('incorrect')),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: picked == question.answer
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(t.explanation, style: const TextStyle(height: 1.35)),
                  if (h != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      h.explanation,
                      style: TextStyle(
                        height: 1.3,
                        fontStyle: FontStyle.italic,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  List<int> _order(int n) =>
      order != null && order!.length == n ? order! : List.generate(n, (i) => i);

  _OptState _state(int i) {
    if (!reveal) return i == picked ? _OptState.selected : _OptState.idle;
    if (i == question.answer) return _OptState.correct;
    if (i == picked) return _OptState.wrong;
    return _OptState.idle;
  }
}

enum _OptState { idle, selected, correct, wrong }

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.letter,
    required this.text,
    required this.helper,
    required this.state,
    required this.onTap,
  });

  final String letter;
  final String text;
  final String? helper;
  final _OptState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (border, fill, badge) = switch (state) {
      _OptState.idle => (
        scheme.outlineVariant,
        Colors.transparent,
        scheme.surfaceContainerHighest,
      ),
      _OptState.selected => (
        scheme.primary,
        scheme.primary.withValues(alpha: 0.08),
        scheme.primary,
      ),
      _OptState.correct => (
        Colors.green.shade600,
        Colors.green.withValues(alpha: 0.10),
        Colors.green.shade600,
      ),
      _OptState.wrong => (
        Colors.red.shade600,
        Colors.red.withValues(alpha: 0.08),
        Colors.red.shade600,
      ),
    };
    final badgeText = state == _OptState.idle
        ? scheme.onSurfaceVariant
        : Colors.white;
    return Material(
      color: fill,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: border, width: state == _OptState.idle ? 1 : 2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: badge,
                child: switch (state) {
                  _OptState.correct => const Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.white,
                  ),
                  _OptState.wrong => const Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.white,
                  ),
                  _ => Text(
                    letter,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: badgeText,
                    ),
                  ),
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        text,
                        style: const TextStyle(fontSize: 16, height: 1.3),
                      ),
                    ),
                    if (helper != null)
                      Text(
                        helper!,
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
