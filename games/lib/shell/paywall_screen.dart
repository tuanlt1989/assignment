import 'package:flutter/material.dart';

import '../main.dart';
import '../progress.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = GameApp.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge([app.money, app.progress]),
      builder: (context, _) {
        final t = app.t;
        final scheme = Theme.of(context).colorScheme;
        final money = app.money;
        const yes = '✓';
        final rows = [
          (t.t('rowEasy'), yes, yes),
          (
            t.t('rowHard'),
            t.t('perDay', {'n': GameProgress.freePerDay[2]!}),
            '∞',
          ),
          (
            t.t('rowExpert'),
            t.t('perDay', {'n': GameProgress.freePerDay[3]!}),
            '∞',
          ),
          (t.t('rowHints'), t.t('perDay', {'n': 1}), '∞'),
          (t.t('rowArchive'), '–', '${GameProgress.archiveDays}'),
          (t.t('rowThemes'), t.t('byStars'), t.t('all')),
        ];
        TextStyle head(Color c) =>
            TextStyle(fontWeight: FontWeight.w900, color: c);
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              children: [
                Icon(Icons.all_inclusive, size: 64, color: scheme.primary),
                const SizedBox(height: 8),
                Text(
                  t.t('pwTitle'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 20),
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(2.2),
                    1: FlexColumnWidth(1.2),
                    2: FlexColumnWidth(1.3),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    TableRow(
                      children: [
                        const SizedBox(),
                        _cell(t.t('pwFree'), head(scheme.outline)),
                        _cell(
                          t.t('pwFull'),
                          head(scheme.primary),
                          bg: scheme.primaryContainer,
                          top: true,
                        ),
                      ],
                    ),
                    for (final (i, (label, free, full)) in rows.indexed)
                      TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              label,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          _cell(
                            free,
                            TextStyle(color: scheme.onSurfaceVariant),
                          ),
                          _cell(
                            full,
                            TextStyle(
                              fontWeight: FontWeight.w800,
                              color: scheme.onPrimaryContainer,
                            ),
                            bg: scheme.primaryContainer,
                            bottom: i == rows.length - 1,
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  t.t('pwOnce'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                if (app.progress.premium)
                  Card(
                    color: Colors.green.withValues(alpha: 0.12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        t.t('thanks'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                else ...[
                  FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                    ),
                    onPressed: money.product == null ? null : money.buy,
                    child: Text(
                      money.product == null
                          ? t.t('unlimited')
                          : t.t('buyFor', {'price': money.product!.price}),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (money.product == null) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        t.t('storeUnavailable'),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: scheme.error),
                      ),
                    ),
                    TextButton(
                      onPressed: money.storeAvailable
                          ? money.loadProduct
                          : null,
                      child: Text(t.t('storeRetry')),
                    ),
                  ],
                  if (money.purchasePending)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(t.t('pending'), textAlign: TextAlign.center),
                    ),
                  if (money.purchaseError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        money.purchaseError!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: scheme.error),
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: money.storeAvailable ? money.restore : null,
                        child: Text(t.t('restore')),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(t.t('later')),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _cell(
    String text,
    TextStyle style, {
    Color? bg,
    bool top = false,
    bool bottom = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: bg == null
          ? null
          : BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.vertical(
                top: top ? const Radius.circular(12) : Radius.zero,
                bottom: bottom ? const Radius.circular(12) : Radius.zero,
              ),
            ),
      child: Text(text, textAlign: TextAlign.center, style: style),
    );
  }
}
