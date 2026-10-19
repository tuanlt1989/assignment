import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../monetization.dart';
import 'flashcard_screen.dart';
import 'guide_screen.dart';
import 'paywall_screen.dart';
import 'quiz_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppState.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge([app.progress, app.money]),
      builder: (context, _) {
        final s = app.s;
        final p = app.progress;
        final scheme = Theme.of(context).colorScheme;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              app.config.titleFor(p.uiLang),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
            ],
          ),
          bottomNavigationBar: BannerSlot(money: app.money),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              _ReadinessCard(app: app),
              const SizedBox(height: 12),
              _TodayRow(app: app),
              if (app.bank.guide.isNotEmpty) ...[
                const SizedBox(height: 12),
                _GuideCard(app: app),
              ],
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.55,
                children: [
                  _ActionTile(
                    icon: Icons.timer_outlined,
                    color: scheme.primary,
                    title: s.t('mockExam'),
                    subtitle: app.config.hasSections
                        ? s.t('sectionsSub', {
                            'n': app.bank.categories.length,
                            'q': app.config.sectionQuestions!,
                          })
                        : s.t('mockExamSub', {
                            'q': app.examSize,
                            'm': app.config.examMinutes,
                            'p': app.config.passPercent,
                          }),
                    onTap: () => app.config.hasSections
                        ? _pickSection(context, app)
                        : _startExam(context, app, app.fullExam),
                  ),
                  _ActionTile(
                    icon: Icons.bolt_outlined,
                    color: Colors.orange.shade700,
                    title: s.t('quick10'),
                    subtitle: s.t('quick10Sub'),
                    onTap: () => _start(
                      context,
                      app,
                      app.pickRandom(10),
                      title: s.t('quick10'),
                    ),
                  ),
                  _ActionTile(
                    icon: Icons.style_outlined,
                    color: Colors.indigo.shade400,
                    title: s.t('flashcards'),
                    subtitle: s.t('flashcardsSub'),
                    onTap: () {
                      final cards = app.studyQueue(app.bank.questions, 20);
                      if (cards.isEmpty) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FlashcardScreen(cards: cards),
                        ),
                      );
                    },
                  ),
                  _ActionTile(
                    icon: Icons.trending_down,
                    color: Colors.deepPurple.shade400,
                    title: s.t('weakTopic'),
                    subtitle:
                        app.weakestCategory?.name(p.uiLang) ??
                        s.t('weakTopicSub'),
                    onTap: () {
                      final c = app.weakestCategory;
                      _start(
                        context,
                        app,
                        c == null
                            ? const []
                            : app.studyQueue(app.bank.inCategory(c.id), 15),
                        title: c?.name(p.uiLang) ?? s.t('weakTopic'),
                      );
                    },
                  ),
                  _ActionTile(
                    icon: Icons.replay_outlined,
                    color: Colors.red.shade600,
                    title: s.t('mistakes'),
                    subtitle: s.t('mistakesSub', {'n': p.mistakes.length}),
                    onTap: () => _start(
                      context,
                      app,
                      app.visible(
                        p.mistakes.map((id) => app.bank.byId[id]).nonNulls,
                      ),
                      title: s.t('mistakes'),
                    ),
                  ),
                  _ActionTile(
                    icon: Icons.bookmark_outline,
                    color: Colors.teal.shade600,
                    title: s.t('saved'),
                    subtitle: s.t('savedSub', {'n': p.bookmarks.length}),
                    onTap: () => _start(
                      context,
                      app,
                      app.visible(
                        p.bookmarks.map((id) => app.bank.byId[id]).nonNulls,
                      ),
                      title: s.t('saved'),
                    ),
                  ),
                ],
              ),
              if (!app.premium) ...[
                const SizedBox(height: 16),
                _UnlockCard(app: app),
              ],
              const SizedBox(height: 24),
              Text(
                s.t('topics'),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              for (final c in app.bank.categories) ...[
                _TopicTile(app: app, category: c),
                const SizedBox(height: 8),
              ],
            ],
          ),
        );
      },
    );
  }
}

void _start(
  BuildContext context,
  AppState app,
  List<Question> qs, {
  bool exam = false,
  required String title,
  int lockedLeft = 0,
}) {
  if (qs.isEmpty) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(app.s.t('nothingHere'))));
    return;
  }
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => QuizScreen(
        title: title,
        questions: qs,
        exam: exam,
        lockedLeft: lockedLeft,
      ),
    ),
  );
}

void _startExam(BuildContext context, AppState app, ExamSpec spec) {
  final qs = spec.pick();
  if (qs.isEmpty) return _start(context, app, qs, title: spec.title);
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) =>
          QuizScreen(title: spec.title, questions: qs, exam: true, spec: spec),
    ),
  );
}

/// Sectioned exams: take one section, or all of them like the real test.
void _pickSection(BuildContext context, AppState app) {
  final s = app.s;
  final c = app.config;
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheet) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: 12),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              s.t('examPick'),
              style: Theme.of(
                sheet,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.workspace_premium_outlined),
            title: Text(
              s.t('universal'),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              s.t('universalSub', {
                'q': c.sectionQuestions! * app.bank.categories.length,
                'p': c.sectionPass!,
              }),
            ),
            onTap: () {
              Navigator.pop(sheet);
              _startExam(context, app, app.allSectionsExam);
            },
          ),
          for (final cat in app.bank.categories)
            ListTile(
              leading: const Icon(Icons.assignment_outlined),
              title: Text(cat.name(app.progress.uiLang)),
              subtitle: Text(
                s.t('sectionSub', {
                  'q': c.sectionQuestions!,
                  'm': c.sectionMinutes!,
                  'p': c.sectionPass!,
                }),
              ),
              onTap: () {
                Navigator.pop(sheet);
                _startExam(context, app, app.sectionExam(cat));
              },
            ),
        ],
      ),
    ),
  );
}

class _GuideCard extends StatelessWidget {
  const _GuideCard({required this.app});
  final AppState app;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.secondaryContainer,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(Icons.menu_book_outlined, color: scheme.secondary),
        title: Text(
          app.s.t('studyGuide'),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(app.s.t('studyGuideSub', {'n': app.bank.guide.length})),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GuideScreen()),
        ),
      ),
    );
  }
}

class _ReadinessCard extends StatelessWidget {
  const _ReadinessCard({required this.app});
  final AppState app;

  @override
  Widget build(BuildContext context) {
    final s = app.s;
    final scheme = Theme.of(context).colorScheme;
    final value = app.progress.readiness(app.bank);
    final last = app.progress.exams.isEmpty ? null : app.progress.exams.first;
    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            SizedBox(
              width: 88,
              height: 88,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: value,
                    strokeWidth: 9,
                    strokeCap: StrokeCap.round,
                    backgroundColor: scheme.surface.withValues(alpha: 0.6),
                  ),
                  Center(
                    child: Text(
                      '${(value * 100).round()}%',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: DefaultTextStyle.merge(
                style: TextStyle(color: scheme.onPrimaryContainer),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.t('readiness'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.t('readinessHint', {
                        'n': app.progress.masteredIn(app.bank.questions),
                        'total': app.bank.questions.length,
                      }),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      last != null
                          ? s.t('lastExam', {'p': last.percent})
                          : s.t('studyDays', {'n': app.progress.studyDays}),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Streak, today's goal and exam countdown: small daily reasons to come back.
class _TodayRow extends StatelessWidget {
  const _TodayRow({required this.app});
  final AppState app;

  @override
  Widget build(BuildContext context) {
    final s = app.s;
    final p = app.progress;
    final days = p.daysToExam;
    final goalDone = p.answeredToday >= p.dailyGoal;
    // Equal-height pills even when one label wraps.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Pill(
            icon: Icons.local_fire_department,
            color: Colors.deepOrange,
            text: s.t('streakDays', {'n': p.currentStreak}),
          ),
          const SizedBox(width: 8),
          _Pill(
            icon: goalDone ? Icons.check_circle : Icons.flag_outlined,
            color: goalDone ? Colors.green.shade600 : Colors.blue.shade600,
            text: s.t('todayGoal', {'n': p.answeredToday, 'goal': p.dailyGoal}),
          ),
          if (days != null && days >= 0) ...[
            const SizedBox(width: 8),
            _Pill(
              icon: Icons.event,
              color: Colors.purple.shade400,
              text: days == 0 ? s.t('examToday') : s.t('examIn', {'d': days}),
            ),
          ],
        ],
      ),
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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
        ),
        // Icon above the text, so long labels ("Còn 23 ngày đến kỳ thi")
        // get two lines instead of being cut off.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 2),
            Text(
              text,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                height: 1.15,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 26),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
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

class _UnlockCard extends StatelessWidget {
  const _UnlockCard({required this.app});
  final AppState app;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.tertiaryContainer,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Icon(
          Icons.workspace_premium,
          color: scheme.tertiary,
          size: 32,
        ),
        title: Text(
          app.s.t('unlockAll'),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(app.s.t('unlockAllSub')),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PaywallScreen()),
        ),
      ),
    );
  }
}

class _TopicTile extends StatelessWidget {
  const _TopicTile({required this.app, required this.category});
  final AppState app;
  final Category category;

  @override
  Widget build(BuildContext context) {
    final s = app.s;
    final all = app.bank.inCategory(category.id);
    final open = app.visible(all);
    final done = app.progress.masteredIn(all);
    final scheme = Theme.of(context).colorScheme;
    final locked = open.length < all.length;
    final name = category.name(app.progress.uiLang);
    return Card(
      color: scheme.surfaceContainerLow,
      child: InkWell(
        onTap: () => _start(
          context,
          app,
          open,
          title: name,
          lockedLeft: all.length - open.length,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: all.isEmpty ? 0 : done / all.length,
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      locked
                          ? s.t('topicFree', {
                              'free': open.length,
                              'total': all.length,
                            })
                          : s.t('topicProgress', {
                              'done': done,
                              'total': all.length,
                            }),
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                locked ? Icons.lock_outline : Icons.chevron_right,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
