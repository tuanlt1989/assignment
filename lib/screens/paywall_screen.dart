import 'package:flutter/material.dart';

import '../app_state.dart';

/// One-time unlock. Shows exactly what the free tier lacks (locked count,
/// full-length mock exam, flashcards on every question) next to the price.
class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppState.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge([app.money, app.progress]),
      builder: (context, _) {
        final s = app.s;
        final scheme = Theme.of(context).colorScheme;
        final money = app.money;
        final total = app.bank.questions.length;
        final free = app.freeIds.length;
        final fullExam = app.config.examQuestions.clamp(1, total);
        final freeExam = app.config.examQuestions.clamp(1, free);
        final rows = <(String, String, String)>[
          (s.t('pwRowQuestions'), '$free', '$total'),
          (
            s.t('pwRowExam'),
            s
                .t('mockExamSub', {
                  'q': freeExam,
                  'm': app.config.examMinutes,
                  'p': app.config.passPercent,
                })
                .split('·')
                .first
                .trim(),
            s
                .t('mockExamSub', {
                  'q': fullExam,
                  'm': app.config.examMinutes,
                  'p': app.config.passPercent,
                })
                .split('·')
                .first
                .trim(),
          ),
          (s.t('pwRowFlash'), s.t('pwRowFlashFree'), s.t('pwRowFlashFull')),
          if (app.helperLang != null) (s.t('pwBilingual'), '✓', '✓'),
          if (app.config.adsEnabled) (s.t('pwNoAds'), '—', '✓'),
        ];

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.close),
              tooltip: s.t('later'),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              children: [
                Icon(Icons.workspace_premium, size: 64, color: scheme.primary),
                const SizedBox(height: 8),
                Text(
                  s.t('paywallTitle'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (!app.premium) ...[
                  const SizedBox(height: 6),
                  Text(
                    s.t('pwLocked', {'n': total - free}),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: scheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Card(
                  color: scheme.surfaceContainerLow,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Table(
                      columnWidths: const {
                        0: FlexColumnWidth(2.2),
                        1: FlexColumnWidth(1.2),
                        2: FlexColumnWidth(1.4),
                      },
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: [
                        TableRow(
                          children: [
                            const SizedBox(),
                            _cell(
                              s.t('pwFree'),
                              bold: true,
                              color: scheme.onSurfaceVariant,
                            ),
                            _cell(
                              s.t('pwPremium'),
                              bold: true,
                              color: scheme.primary,
                            ),
                          ],
                        ),
                        for (final (label, f, p) in rows)
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  14,
                                  10,
                                  4,
                                  10,
                                ),
                                child: Text(label),
                              ),
                              _cell(f, color: scheme.onSurfaceVariant),
                              _cell(p, bold: true, color: scheme.primary),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  s.t('pwOnce'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                if (app.premium)
                  Card(
                    color: Colors.green.withValues(alpha: 0.12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        s.t('thanks'),
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
                          ? s.t('unlockAll')
                          : s.t('buyFor', {'price': money.product!.price}),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 14,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        s.t('pwSecure'),
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  if (money.product == null) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        s.t('storeUnavailable'),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: scheme.error),
                      ),
                    ),
                    TextButton(
                      onPressed: money.storeAvailable
                          ? money.loadProduct
                          : null,
                      child: Text(s.t('retry')),
                    ),
                  ],
                  if (money.purchasePending)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(s.t('pending'), textAlign: TextAlign.center),
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
                        child: Text(s.t('restore')),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(s.t('later')),
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

  static Widget _cell(String text, {bool bold = false, Color? color}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            color: color,
          ),
        ),
      );
}
