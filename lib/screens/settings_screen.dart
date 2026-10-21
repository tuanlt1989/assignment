import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_state.dart';
import '../i18n.dart';
import '../reminders.dart';
import 'paywall_screen.dart';
import 'sources_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _privacyOptions = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AppState.of(context).money.privacyOptionsRequired().then((v) {
      if (mounted) setState(() => _privacyOptions = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = AppState.of(context);
    return ListenableBuilder(
      listenable: app.progress,
      builder: (context, _) {
        final s = app.s;
        final p = app.progress;
        final uiChoices = {app.config.primary, 'en'}.toList();
        final helper = app.helperLang;
        return Scaffold(
          appBar: AppBar(title: Text(s.t('settings'))),
          body: ListView(
            children: [
              if (uiChoices.length > 1)
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(s.t('appLanguage')),
                  trailing: SegmentedButton<String>(
                    showSelectedIcon: false,
                    segments: [
                      for (final l in uiChoices)
                        ButtonSegment(value: l, label: Text(l.toUpperCase())),
                    ],
                    selected: {p.uiLang},
                    onSelectionChanged: (v) => p.setUiLang(v.first),
                  ),
                ),
              if (helper != null)
                SwitchListTile(
                  secondary: const Icon(Icons.translate),
                  title: Text(
                    s.t('helperDefault', {
                      'lang': S.languageNames[helper] ?? helper,
                    }),
                  ),
                  value: p.showHelperLang,
                  onChanged: p.setShowHelperLang,
                ),
              ..._planTiles(context, app),
              const Divider(),
              if (!app.premium)
                ListTile(
                  leading: const Icon(Icons.workspace_premium),
                  title: Text(s.t('unlockAll')),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PaywallScreen()),
                  ),
                )
              else
                ListTile(
                  leading: const Icon(Icons.verified, color: Colors.green),
                  title: Text(s.t('premiumActive')),
                ),
              ListTile(
                leading: const Icon(Icons.restore),
                title: Text(s.t('restore')),
                onTap: app.money.restore,
              ),
              ListTile(
                leading: const Icon(Icons.star_outline),
                title: Text(s.t('rate')),
                onTap: app.money.openStoreListing,
              ),
              ListTile(
                leading: const Icon(Icons.mail_outline),
                title: Text(s.t('support')),
                subtitle: Text(app.config.supportEmail),
                onTap: () => launchUrl(
                  Uri(
                    scheme: 'mailto',
                    path: app.config.supportEmail,
                    queryParameters: {'subject': app.config.titleFor('en')},
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: Text(s.t('privacy')),
                onTap: () => launchUrl(
                  Uri.parse(app.config.privacyPolicyUrl),
                  mode: LaunchMode.externalApplication,
                ),
              ),
              if (_privacyOptions)
                ListTile(
                  leading: const Icon(Icons.tune),
                  title: Text(s.t('adChoices')),
                  onTap: app.money.showPrivacyOptions,
                ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(s.t('resetProgress')),
                onTap: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (c) => AlertDialog(
                      content: Text(s.t('resetConfirm')),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(c, false),
                          child: Text(s.t('cancel')),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(c, true),
                          child: Text(s.t('reset')),
                        ),
                      ],
                    ),
                  );
                  if (ok == true) await p.reset();
                },
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: SourcesCard(app: app),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text(
                  s.t('disclaimerTitle'),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  s.t('disclaimer', {
                    'orgs': app.config.examBodiesFor(p.uiLang),
                  }),
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Text(
                  s.t('version', {'v': app.bank.version}),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _planTiles(BuildContext context, AppState app) {
    final s = app.s;
    final p = app.progress;
    final loc = MaterialLocalizations.of(context);
    final date = p.examDate.isEmpty ? null : DateTime.tryParse(p.examDate);
    final time = TimeOfDay(
      hour: p.reminderMinutes ~/ 60,
      minute: p.reminderMinutes % 60,
    );
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Text(
          s.t('studyPlan'),
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      ListTile(
        leading: const Icon(Icons.event),
        title: Text(s.t('examDateLabel')),
        subtitle: Text(
          date == null ? s.t('notSet') : loc.formatMediumDate(date),
        ),
        trailing: date == null
            ? null
            : TextButton(
                onPressed: () => p.setPlan(examDate: ''),
                child: Text(s.t('clear')),
              ),
        onTap: () async {
          final now = DateTime.now();
          final picked = await showDatePicker(
            context: context,
            initialDate: date != null && date.isAfter(now)
                ? date
                : now.add(const Duration(days: 30)),
            firstDate: now,
            lastDate: now.add(const Duration(days: 730)),
          );
          if (picked != null) {
            p.setPlan(examDate: picked.toIso8601String().substring(0, 10));
          }
        },
      ),
      ListTile(
        leading: const Icon(Icons.flag_outlined),
        title: Text(s.t('dailyGoalLabel')),
        subtitle: Text(s.t('obGoalOpt', {'n': p.dailyGoal})),
        onTap: () async {
          final goal = await showDialog<int>(
            context: context,
            builder: (c) => SimpleDialog(
              title: Text(s.t('dailyGoalLabel')),
              children: [
                for (final g in const [10, 20, 30, 50])
                  SimpleDialogOption(
                    onPressed: () => Navigator.pop(c, g),
                    child: Text(s.t('obGoalOpt', {'n': g})),
                  ),
              ],
            ),
          );
          if (goal != null) {
            p.setPlan(dailyGoal: goal);
            await app.syncReminder();
          }
        },
      ),
      if (Reminders.supported) ...[
        SwitchListTile(
          secondary: const Icon(Icons.notifications_active_outlined),
          title: Text(s.t('reminderLabel')),
          value: p.reminderOn,
          onChanged: (v) async {
            final ok = !v || await Reminders.requestPermission();
            p.setReminder(on: v && ok);
            await app.syncReminder();
          },
        ),
        if (p.reminderOn)
          ListTile(
            leading: const Icon(Icons.schedule),
            title: Text(s.t('reminderTime')),
            subtitle: Text(loc.formatTimeOfDay(time)),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: time,
              );
              if (picked != null) {
                p.setReminder(
                  on: true,
                  minutes: picked.hour * 60 + picked.minute,
                );
                await app.syncReminder();
              }
            },
          ),
      ],
    ];
  }
}
