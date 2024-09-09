import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:timecountdown/Providers/UserProvider.dart';

class Interstialadservice {
  InterstitialAd? interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  final int maxFailedLoadAttempts = 3;

  void loadAd() {
    InterstitialAd.load(
        //  adUnitId: 'ca-app-pub-9764584713102923/3744425699',
        adUnitId: 'ca-app-pub-3940256099942544/1033173712',
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) {
            debugPrint('$ad loaded.');
            // Keep a reference to the ad so you can show it later.
            interstitialAd = ad;
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('InterstitialAd failed to load: $error');
          },
        ));
  }

  void showAd() {
    print('Showing Interstitial Ad');
    if (interstitialAd != null) {
      interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          print('$ad onAdDismissedFullScreenContent.');
          ad.dispose();
          loadAd(); // Load a new ad for next time
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          print('$ad onAdFailedToShowFullScreenContent: $error');
          ad.dispose();
          loadAd(); // Load a new ad for next time
        },
      );

      interstitialAd!.show();
      interstitialAd = null;
    } else {
      print('Showing Interstitial nilk');
    }
  }

  // void showInterstitialAd() {
  //   if (_interstitialAd == null) {
  //     print('Warning: attempt to show interstitial before loaded.');
  //     return;
  //   }
  //   _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
  //     onAdShowedFullScreenContent: (InterstitialAd ad) =>
  //         print('ad onAdShowedFullScreenContent.'),
  //     onAdDismissedFullScreenContent: (InterstitialAd ad) {
  //       print('$ad onAdDismissedFullScreenContent.');
  //       ad.dispose();
  //       _loadInterstitialAd(); // Load a new ad for next time
  //     },
  //     onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
  //       print('$ad onAdFailedToShowFullScreenContent: $error');
  //       ad.dispose();
  //       _loadInterstitialAd(); // Load a new ad for next time
  //     },
  //   );

  //   _interstitialAd!.show();
  //   _interstitialAd = null; // Set to null after showing
  // }

  // Call this method to initialize and load the ad
  // void initialize() {
  //   _loadInterstitialAd();
  // }
}
