import 'package:flutter/material.dart';

import '../main.dart';

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
        final bullets = [
          (Icons.favorite, Colors.red, t.t('pwLives')),
          (Icons.lightbulb, Colors.amber.shade700, t.t('pwHints')),
          (Icons.calendar_today, scheme.primary, t.t('pwDaily')),
        ];
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              children: [
                Icon(Icons.all_inclusive, size: 72, color: scheme.primary),
                const SizedBox(height: 12),
                Text(
                  t.t('pwTitle'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 24),
                for (final (icon, color, text) in bullets)
                  ListTile(
                    leading: Icon(icon, color: color),
                    title: Text(
                      text,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                const SizedBox(height: 8),
                Text(
                  t.t('pwOnce'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 20),
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
}
