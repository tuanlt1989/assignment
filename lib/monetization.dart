import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_review/in_app_review.dart';

import 'models.dart';
import 'progress.dart';

/// One non-consumable "premium" product that unlocks the whole bank (and
/// removes ads), optional AdMob ads for free users, and the review prompt.
/// Apps with `"ads": false` never touch the ads SDK and upsell instead.
class Monetization extends ChangeNotifier {
  Monetization(this.config, this.progress);

  final AppConfig config;
  final Progress progress;

  /// `--dart-define=NO_ADS=true` for screenshots and tests.
  static const _noAds = bool.fromEnvironment('NO_ADS');

  bool get _mobile =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  bool _adsReady = false;
  bool get showAds => _mobile && !_noAds && _adsReady && !progress.premium;

  InterstitialAd? _interstitial;
  ProductDetails? product;
  bool storeAvailable = false;
  String? purchaseError;
  bool purchasePending = false;
  StreamSubscription<List<PurchaseDetails>>? _sub;

  Future<void> init() async {
    if (!_mobile) return;
    unawaited(_initPurchases());
    if (_noAds || !config.adsEnabled) return;
    // Google's consent form (shown only where the law requires it, e.g. EEA/UK).
    final params = ConsentRequestParameters();
    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () => ConsentForm.loadAndShowConsentFormIfRequired((_) => _startAds()),
      (_) => _startAds(),
    );
  }

  Future<void> _startAds() async {
    if (_adsReady || !await ConsentInformation.instance.canRequestAds()) {
      return;
    }
    await MobileAds.instance.initialize();
    _adsReady = true;
    _loadInterstitial();
    notifyListeners();
  }

  Future<bool> privacyOptionsRequired() async {
    if (!_mobile || !config.adsEnabled) return false;
    return await ConsentInformation.instance
            .getPrivacyOptionsRequirementStatus() ==
        PrivacyOptionsRequirementStatus.required;
  }

  void showPrivacyOptions() {
    ConsentForm.showPrivacyOptionsForm((_) {});
  }

  void _loadInterstitial() {
    if (progress.premium) return;
    InterstitialAd.load(
      adUnitId: config.interstitialAdUnit,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitial = ad,
        onAdFailedToLoad: (_) => _interstitial = null,
      ),
    );
  }

  /// Called when a practice session or exam ends. Every second session a free
  /// user sees an interstitial, or, when no ad is shown, the caller should
  /// show the paywall (returns true).
  bool onSessionFinished() {
    progress.finishSession();
    if (progress.premium || progress.finishedSessions % 2 != 0) return false;
    final ad = _interstitial;
    if (!showAds || ad == null) return true;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _loadInterstitial();
      },
    );
    _interstitial = null;
    ad.show();
    return false;
  }

  Future<void> _initPurchases() async {
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
    // Picks up purchases made before a reinstall or on another device.
    if (!progress.premium) await iap.restorePurchases();
  }

  /// Fetches the price from Play. Retried from the paywall if it failed.
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
        _interstitial?.dispose();
        _interstitial = null;
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

  /// Ask for a Play review right after a good moment (a passed mock exam),
  /// at most once every 30 days. Google decides whether to show it.
  Future<void> maybeAskReview() async {
    if (!_mobile) return;
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
    _interstitial?.dispose();
    super.dispose();
  }
}

/// A standard 320x50 banner that collapses to nothing when ads are off.
class BannerSlot extends StatefulWidget {
  const BannerSlot({super.key, required this.money});
  final Monetization money;

  @override
  State<BannerSlot> createState() => _BannerSlotState();
}

class _BannerSlotState extends State<BannerSlot> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    widget.money.addListener(_onChange);
    _sync();
  }

  void _onChange() {
    _sync();
    if (mounted) setState(() {});
  }

  void _sync() {
    if (widget.money.showAds && _ad == null) {
      _ad = BannerAd(
        adUnitId: widget.money.config.bannerAdUnit,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (_) {
            if (mounted) setState(() => _loaded = true);
          },
          onAdFailedToLoad: (ad, _) {
            ad.dispose();
            _ad = null;
          },
        ),
      )..load();
    } else if (!widget.money.showAds && _ad != null) {
      _ad!.dispose();
      _ad = null;
      _loaded = false;
    }
  }

  @override
  void dispose() {
    widget.money.removeListener(_onChange);
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (!widget.money.showAds || ad == null || !_loaded) {
      return const SizedBox.shrink();
    }
    return SafeArea(
      top: false,
      child: SizedBox(
        width: ad.size.width.toDouble(),
        height: ad.size.height.toDouble(),
        child: AdWidget(ad: ad),
      ),
    );
  }
}
