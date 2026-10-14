import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import 'paywall_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = GameApp.of(context);
    final t = app.t;
    return Scaffold(
      appBar: AppBar(title: Text(t.t('settings'))),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              t.t('howTo'),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(t.t('rules_${app.config.game}')),
          ),
          const Divider(),
          if (!app.progress.premium)
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: Text(t.t('unlimited')),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PaywallScreen()),
              ),
            ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: Text(t.t('restore')),
            onTap: app.money.restore,
          ),
          ListTile(
            leading: const Icon(Icons.star_outline),
            title: Text(t.t('rate')),
            onTap: app.money.openStoreListing,
          ),
          ListTile(
            leading: const Icon(Icons.mail_outline),
            title: Text(t.t('support')),
            subtitle: Text(app.config.supportEmail),
            onTap: () => launchUrl(
              Uri(
                scheme: 'mailto',
                path: app.config.supportEmail,
                queryParameters: {'subject': app.title},
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(t.t('privacy')),
            onTap: () => launchUrl(
              Uri.parse(app.config.privacyPolicyUrl),
              mode: LaunchMode.externalApplication,
            ),
          ),
        ],
      ),
    );
  }
}
