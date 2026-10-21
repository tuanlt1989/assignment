import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_state.dart';

/// Links to the official government pages the questions are based on.
/// Empty when the app config has no `officialSources`.
class SourcesCard extends StatelessWidget {
  const SourcesCard({super.key, required this.app});
  final AppState app;

  @override
  Widget build(BuildContext context) {
    final sources = app.config.officialSources;
    if (sources.isEmpty) return const SizedBox.shrink();
    final s = app.s;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_balance_outlined, size: 20),
                const SizedBox(width: 8),
                Text(
                  s.t('officialSources'),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                s.t('officialSourcesNote'),
                style: TextStyle(fontSize: 13, color: muted),
              ),
            ),
            for (final (label, url) in sources)
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(
                  label,
                  style: const TextStyle(decoration: TextDecoration.underline),
                ),
                subtitle: Text(
                  url,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () => launchUrl(
                  Uri.parse(url),
                  mode: LaunchMode.externalApplication,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
