import 'package:flutter/material.dart';

import '../app_state.dart';

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
        final bullets = [
          (
            Icons.library_books_outlined,
            s.t('pwAll', {'n': app.bank.questions.length}),
          ),
          (Icons.timer_outlined, s.t('pwExam')),
          if (app.helperLang != null) (Icons.translate, s.t('pwBilingual')),
          app.config.adsEnabled
              ? (Icons.block, s.t('pwNoAds'))
              : (Icons.wifi_off, s.t('pwOffline')),
        ];
        return Scaffold(
          appBar: AppBar(),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              children: [
                Icon(Icons.workspace_premium, size: 72, color: scheme.primary),
                const SizedBox(height: 12),
                Text(
                  s.t('paywallTitle'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 24),
                for (final (icon, text) in bullets)
                  ListTile(
                    leading: Icon(icon, color: scheme.primary),
                    title: Text(text),
                    contentPadding: EdgeInsets.zero,
                  ),
                const SizedBox(height: 8),
                Text(
                  s.t('pwOnce'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 20),
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
                      minimumSize: const Size.fromHeight(54),
                    ),
                    onPressed: money.product == null ? null : money.buy,
                    child: Text(
                      money.product == null
                          ? s.t('unlockAll')
                          : s.t('buyFor', {'price': money.product!.price}),
                      style: const TextStyle(fontSize: 17),
                    ),
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
                  TextButton(
                    onPressed: money.storeAvailable ? money.restore : null,
                    child: Text(s.t('restore')),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
