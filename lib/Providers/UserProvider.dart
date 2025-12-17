import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:timecountdown/Services/LocalStorageService.dart';
import 'package:timecountdown/Model/UserData.dart';

class UserProvider extends ChangeNotifier {
  UserData? _userData;
  bool _isPremium = false;

  UserData? get userData => _userData;
  bool get isPremium => _isPremium;

  Future<void> fetchUserData() async {
    print("Fetching user data");
    _userData = await LocalStorageService.getCurrentUserData();
    await _checkPremiumStatus();
    notifyListeners();
  }

  Future<void> _checkPremiumStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      // Fixed: Use correct entitlement ID from RevenueCatService
      _isPremium = customerInfo.entitlements.all["pro"]?.isActive ?? false;
      print("User is premium: $_isPremium");
      
      // Sync premium status to local storage
      await LocalStorageService.updateIsPurchased(_isPremium);
    } catch (e) {
      print("Error checking premium status: $e");
      _isPremium = false;
    }
    notifyListeners();
  }

  // Other methods related to user data
}
