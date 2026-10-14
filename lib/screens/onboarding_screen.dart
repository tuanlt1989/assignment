import 'package:flutter/material.dart';

import '../app_state.dart';
import '../reminders.dart';
import 'home_screen.dart';
import 'paywall_screen.dart';

/// First launch: exam date -> daily goal -> plan (+ reminder), then a soft
/// paywall. Users who set a date and a goal convert and retain much better.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pages = PageController();
  int _page = 0;
  DateTime? _examDate;
  int _goal = 20;
  bool _reminder = true;

  static const goals = [10, 20, 30, 50];

  void _next() {
    _pages.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _examDate ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 730)),
    );
    if (picked != null) setState(() => _examDate = picked);
  }

  Future<void> _finish(AppState app) async {
    final p = app.progress;
    p.setPlan(
      examDate: _examDate?.toIso8601String().substring(0, 10) ?? '',
      dailyGoal: _goal,
    );
    if (_reminder && Reminders.supported) {
      final granted = await Reminders.requestPermission();
      p.setReminder(on: granted);
      await app.syncReminder();
    }
    p.finishOnboarding();
    if (!mounted) return;
    final nav = Navigator.of(context);
    nav.pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    if (!app.premium) {
      nav.push(MaterialPageRoute(builder: (_) => const PaywallScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppState.of(context);
    final s = app.s;
    final scheme = Theme.of(context).colorScheme;
    final total = app.bank.questions.length;
    final daysToExam = _examDate == null
        ? null
        : DateTime(_examDate!.year, _examDate!.month, _examDate!.day)
              .difference(
                DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                ),
              )
              .inDays;
    final needed = daysToExam != null && daysToExam > 0
        ? (total / daysToExam).ceil()
        : null;

    Widget page({
      required IconData icon,
      required String title,
      String? hint,
      required List<Widget> children,
    }) => ListView(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      children: [
        Icon(icon, size: 64, color: scheme.primary),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        if (hint != null) ...[
          const SizedBox(height: 8),
          Text(
            hint,
            textAlign: TextAlign.center,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ],
        const SizedBox(height: 28),
        ...children,
      ],
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pages,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  page(
                    icon: Icons.event_outlined,
                    title: s.t('obDateQ'),
                    hint: s.t('obDateHint'),
                    children: [
                      FilledButton.tonalIcon(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(54),
                        ),
                        icon: const Icon(Icons.calendar_month),
                        label: Text(
                          _examDate == null
                              ? s.t('obPickDate')
                              : MaterialLocalizations.of(
                                  context,
                                ).formatMediumDate(_examDate!),
                        ),
                        onPressed: _pickDate,
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          setState(() => _examDate = null);
                          _next();
                        },
                        child: Text(s.t('obNoDate')),
                      ),
                    ],
                  ),
                  page(
                    icon: Icons.flag_outlined,
                    title: s.t('obGoalQ'),
                    children: [
                      for (final g in goals)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ChoiceTile(
                            selected: _goal == g,
                            title: s.t('obGoalOpt', {'n': g}),
                            subtitle: s.t('obGoalMin', {
                              'm': (g * 0.75).round(),
                            }),
                            onTap: () => setState(() => _goal = g),
                          ),
                        ),
                    ],
                  ),
                  page(
                    icon: Icons.route_outlined,
                    title: s.t('obPlanTitle'),
                    children: [
                      Card(
                        color: scheme.primaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _PlanLine(
                                icon: Icons.checklist,
                                text: s.t('obPlanDays', {
                                  'total': total,
                                  'd': (total / _goal).ceil(),
                                }),
                              ),
                              if (daysToExam != null)
                                _PlanLine(
                                  icon: Icons.event,
                                  text: s.t('obPlanExam', {'d': daysToExam}),
                                ),
                              if (needed != null && needed > _goal)
                                _PlanLine(
                                  icon: Icons.warning_amber_rounded,
                                  text: s.t('obPlanTight', {'n': needed}),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (Reminders.supported)
                        SwitchListTile(
                          value: _reminder,
                          onChanged: (v) => setState(() => _reminder = v),
                          title: Text(s.t('obReminder')),
                          secondary: const Icon(Icons.notifications_active),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Row(
                children: [
                  for (var i = 0; i < 3; i++)
                    Container(
                      margin: const EdgeInsets.only(right: 6),
                      width: i == _page ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _page
                            ? scheme.primary
                            : scheme.outlineVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _page < 2 ? _next : () => _finish(app),
                    child: Text(_page < 2 ? s.t('continue') : s.t('obStart')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final bool selected;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected ? scheme.primary.withValues(alpha: 0.08) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: selected ? scheme.primary : scheme.outlineVariant,
          width: selected ? 2 : 1,
        ),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        onTap: onTap,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_off,
          color: selected ? scheme.primary : scheme.outline,
        ),
      ),
    );
  }
}

class _PlanLine extends StatelessWidget {
  const _PlanLine({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onPrimaryContainer;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
