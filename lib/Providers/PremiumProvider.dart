import 'package:flutter/material.dart';
import 'package:timecountdown/Services/RevenueCatService.dart';

class PremiumProvider with ChangeNotifier {
  bool _isPremium = false;

  bool get isPremium => _isPremium;

  Future<void> checkPremiumStatus() async {
    _isPremium = await RevenueCatService.isPremiumUser();
    notifyListeners();
  }

  void setPremiumStatus(bool status) {
    _isPremium = status;
    notifyListeners();
  }
}
