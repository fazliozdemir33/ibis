import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  bool _isInitialized = false;

  /// AdMob App ID Setup:
  /// Android & iOS: ca-app-pub-4502761746939945~5576684014
  /// Publisher ID: pub-4502761746939945

  Future<void> init() async {
    if (_isInitialized) return;
    await MobileAds.instance.initialize();
    _isInitialized = true;
  }

  // --- Banner Ads ---

  static String get bannerAdUnitId {
    if (kDebugMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111' // Android Test
          : 'ca-app-pub-3940256099942544/2934735716'; // iOS Test
    }

    // REAL ID'leri buraya ekleyin:
    return Platform.isAndroid
        ? 'ca-app-pub-4502761746939945/2502072340'
        : 'ca-app-pub-4502761746939945/2502072340';
  }

  static BannerAd createBannerAd({
    required Function(Ad) onAdLoaded,
    required Function(Ad, LoadAdError) onAdFailedToLoad,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
      ),
    );
  }

  // --- Interstitial Ads (Geçiş Reklamları) ---

  static String get interstitialAdUnitId {
    if (kDebugMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/1033173712' // Android Test
          : 'ca-app-pub-3940256099942544/4411468910'; // iOS Test
    }

    // REAL ID'leri buraya ekleyin:
    return Platform.isAndroid
        ? 'ca-app-pub-4502761746939945/YOUR_ANDROID_INTERSTITIAL_ID'
        : 'ca-app-pub-4502761746939945/YOUR_IOS_INTERSTITIAL_ID';
  }

  static void loadInterstitialAd({
    required Function(InterstitialAd) onAdLoaded,
    required Function(LoadAdError) onAdFailedToLoad,
  }) {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
      ),
    );
  }
}
