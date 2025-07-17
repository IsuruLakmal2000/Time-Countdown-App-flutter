import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PremiumProvider with ChangeNotifier {
  bool _isPremium = false;

  bool get isPremium => _isPremium;

  Future<void> checkPremiumStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      _isPremium = customerInfo.entitlements.all["pro"]?.isActive ?? false;
    } catch (e) {
      _isPremium = false;
    }
    notifyListeners();
  }

  void setPremiumStatus(bool status) {
    _isPremium = status;
    notifyListeners();
  }
}
