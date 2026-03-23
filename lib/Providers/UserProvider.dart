import 'package:flutter/material.dart';
import 'package:timecountdown/Services/LocalStorageService.dart';
import 'package:timecountdown/Services/RevenueCatService.dart';
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
      // Use RevenueCatService instead of calling Purchases SDK directly
      // This respects test mode and handles initialization checks
      _isPremium = await RevenueCatService.isPremiumUser();
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
