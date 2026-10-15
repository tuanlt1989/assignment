import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_review/in_app_review.dart';

import 'config.dart';
import 'progress.dart';

/// One non-consumable product: unlimited lives and hints.
class Monetization extends ChangeNotifier {
  Monetization(this.config, this.progress);

  final GameConfig config;
  final GameProgress progress;

  bool get _mobile =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  ProductDetails? product;
  bool storeAvailable = false;
  bool purchasePending = false;
  String? purchaseError;
  StreamSubscription<List<PurchaseDetails>>? _sub;

  Future<void> init() async {
    if (!_mobile) return;
    final iap = InAppPurchase.instance;
    _sub = iap.purchaseStream.listen(
      _onPurchases,
      onError: (Object e) {
        purchaseError = '$e';
        notifyListeners();
      },
    );
    storeAvailable = await iap.isAvailable();
    if (!storeAvailable) {
      notifyListeners();
      return;
    }
    await loadProduct();
    if (!progress.premium) await iap.restorePurchases();
  }

  Future<void> loadProduct() async {
    final resp = await InAppPurchase.instance.queryProductDetails({
      config.premiumProductId,
    });
    product = resp.productDetails.isEmpty ? null : resp.productDetails.first;
    notifyListeners();
  }

  void _onPurchases(List<PurchaseDetails> purchases) {
    for (final p in purchases) {
      purchasePending = p.status == PurchaseStatus.pending;
      if (p.productID == config.premiumProductId &&
          (p.status == PurchaseStatus.purchased ||
              p.status == PurchaseStatus.restored)) {
        progress.setPremium(true);
        purchaseError = null;
      } else if (p.status == PurchaseStatus.error) {
        purchaseError = p.error?.message;
      }
      if (p.pendingCompletePurchase) {
        InAppPurchase.instance.completePurchase(p);
      }
    }
    notifyListeners();
  }

  Future<bool> buy() async {
    final p = product;
    if (p == null) return false;
    return InAppPurchase.instance.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: p),
    );
  }

  Future<void> restore() => InAppPurchase.instance.restorePurchases();

  /// Ask for a review after a few wins, at most every 30 days.
  Future<void> maybeAskReview() async {
    if (!_mobile || progress.solvedTotal < 5) return;
    final since =
        DateTime.now().millisecondsSinceEpoch - progress.lastReviewAskMs;
    if (since < const Duration(days: 30).inMilliseconds) return;
    final review = InAppReview.instance;
    if (await review.isAvailable()) {
      progress.markReviewAsked();
      await review.requestReview();
    }
  }

  Future<void> openStoreListing() => InAppReview.instance.openStoreListing();

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
