import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timecountdown/Model/CountDownData.dart';
import 'package:timecountdown/Model/UserData.dart';
import 'package:timecountdown/Services/WidgetService.dart';

class LocalStorageService {
  static const String _countdownsKey = 'countdowns';
  static const String _userDataKey = 'userData';
  static const String _onboardingCompletedKey = 'onboarding_completed';

  // Initialize user data if it doesn't exist
  static Future<void> initializeUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_userDataKey)) {
      final userData = UserData(
        uid: 'local_user',
        name: 'User',
        email: 'user@local.com',
        account_created: DateTime.now().toString(),
        last_app_opened: DateTime.now().toString(),
        isPurchased: false,
        countdownCount: 0,
      );
      await _saveUserData(userData);
    }
  }

  // User Data Operations
  static Future<void> _saveUserData(UserData userData) async {
    final prefs = await SharedPreferences.getInstance();
    final userDataMap = {
      'uid': userData.uid,
      'name': userData.name,
      'email': userData.email,
      'account_created': userData.account_created,
      'last_app_opened': userData.last_app_opened,
      'isPurchased': userData.isPurchased,
      'countdownCount': userData.countdownCount,
    };
    await prefs.setString(_userDataKey, json.encode(userDataMap));
  }

  static Future<UserData?> getCurrentUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataJson = prefs.getString(_userDataKey);
    
    if (userDataJson != null) {
      final userDataMap = json.decode(userDataJson) as Map<String, dynamic>;
      return UserData(
        uid: userDataMap['uid'] as String,
        name: userDataMap['name'] as String,
        email: userDataMap['email'] as String,
        account_created: userDataMap['account_created'] as String,
        last_app_opened: userDataMap['last_app_opened'] as String,
        isPurchased: userDataMap['isPurchased'] as bool,
        countdownCount: userDataMap['countdownCount'] as int,
      );
    }
    return null;
  }

  static Future<void> updateCountdownCount(int newCount) async {
    final userData = await getCurrentUserData();
    if (userData != null) {
      final updatedUserData = UserData(
        uid: userData.uid,
        name: userData.name,
        email: userData.email,
        account_created: userData.account_created,
        last_app_opened: DateTime.now().toString(),
        isPurchased: userData.isPurchased,
        countdownCount: newCount,
      );
      await _saveUserData(updatedUserData);
    }
  }

  static Future<void> updateIsPurchased(bool newStatus) async {
    final userData = await getCurrentUserData();
    if (userData != null) {
      final updatedUserData = UserData(
        uid: userData.uid,
        name: userData.name,
        email: userData.email,
        account_created: userData.account_created,
        last_app_opened: userData.last_app_opened,
        isPurchased: newStatus,
        countdownCount: userData.countdownCount,
      );
      await _saveUserData(updatedUserData);
    }
  }

  // Countdown Data Operations
  static Future<void> saveCountDownData(CountDownData countDownData) async {
    try {
      final countdowns = await getCountdowns();
      
      // Generate a unique ID for new countdowns
      final countdownId = countDownData.countDownId.isEmpty 
          ? DateTime.now().millisecondsSinceEpoch.toString()
          : countDownData.countDownId;
      
      final newCountdown = CountDownData(
        countDownId: countdownId,
        countDownTempId: countDownData.countDownTempId,
        countDownTitle: countDownData.countDownTitle,
        countDownTargetDate: countDownData.countDownTargetDate,
        countDownDim: countDownData.countDownDim,
        countDownCreatedDate: countDownData.countDownCreatedDate,
        countDownImage: countDownData.countDownImage,
      );
      
      countdowns.add(newCountdown);
      await _saveCountdowns(countdowns);
      
      // Update widget data with all countdowns
      await WidgetService.updateAllCountdowns(countdowns);
      
      print('CountDownData saved successfully!');
    } catch (e) {
      print('Error saving CountDownData: ${e.toString()}');
    }
  }

  static Future<void> updateCountDownData(CountDownData countDownData) async {
    try {
      final countdowns = await getCountdowns();
      final index = countdowns.indexWhere((c) => c.countDownId == countDownData.countDownId);
      
      if (index != -1) {
        countdowns[index] = countDownData;
        await _saveCountdowns(countdowns);
        
        // Update widget data with all countdowns
        await WidgetService.updateAllCountdowns(countdowns);
        
        print('CountDownData updated successfully!');
      }
    } catch (e) {
      print('Error updating CountDownData: ${e.toString()}');
    }
  }

  static Future<List<CountDownData>> getCountdowns() async {
    final prefs = await SharedPreferences.getInstance();
    final countdownsJson = prefs.getString(_countdownsKey);
    
    if (countdownsJson != null) {
      final countdownsList = json.decode(countdownsJson) as List<dynamic>;
      return countdownsList.map((countdownMap) {
        return CountDownData(
          countDownId: countdownMap['countDownId'] as String,
          countDownTempId: countdownMap['countDownTempId'] as String,
          countDownTitle: countdownMap['countDownTitle'] as String,
          countDownTargetDate: DateTime.fromMillisecondsSinceEpoch(
              countdownMap['countDownTargetDate'] as int),
          countDownDim: countdownMap['countDownDim'] as double,
          countDownCreatedDate: DateTime.fromMillisecondsSinceEpoch(
              countdownMap['countDownCreatedDate'] as int),
          countDownImage: countdownMap['countDownImage'] as String,
        );
      }).toList();
    }
    return [];
  }

  static Future<void> _saveCountdowns(List<CountDownData> countdowns) async {
    final prefs = await SharedPreferences.getInstance();
    final countdownsList = countdowns.map((countdown) {
      return {
        'countDownId': countdown.countDownId,
        'countDownTempId': countdown.countDownTempId,
        'countDownTitle': countdown.countDownTitle,
        'countDownTargetDate': countdown.countDownTargetDate.millisecondsSinceEpoch,
        'countDownDim': countdown.countDownDim,
        'countDownCreatedDate': countdown.countDownCreatedDate.millisecondsSinceEpoch,
        'countDownImage': countdown.countDownImage,
      };
    }).toList();
    
    await prefs.setString(_countdownsKey, json.encode(countdownsList));
  }

  static Future<void> deleteCountdown(String countdownId, BuildContext context) async {
    try {
      final countdowns = await getCountdowns();
      countdowns.removeWhere((countdown) => countdown.countDownId == countdownId);
      await _saveCountdowns(countdowns);
      
      // Update widget data with remaining countdowns
      await WidgetService.updateAllCountdowns(countdowns);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Countdown deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete countdown: $e')),
      );
    }
  }

  // Clear all countdowns (for backup import)
  static Future<void> clearAllCountdowns() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_countdownsKey);
    print('All countdowns cleared');
  }

  // Add countdown without generating new ID (for backup import)
  static Future<void> addCountdown(CountDownData countdown) async {
    try {
      final countdowns = await getCountdowns();
      countdowns.add(countdown);
      await _saveCountdowns(countdowns);
      print('Countdown added successfully: ${countdown.countDownId}');
    } catch (e) {
      print('Error adding countdown: ${e.toString()}');
    }
  }

  // Update current user data (for backup import)
  static Future<void> updateCurrentUserData(UserData userData) async {
    await _saveUserData(userData);
    print('User data updated successfully');
  }

  // Template migration - converts removed templates to template_1
  static Future<void> migrateRemovedTemplates() async {
    try {
      final countdowns = await getCountdowns();
      bool hasChanges = false;
      
      for (int i = 0; i < countdowns.length; i++) {
        final countdown = countdowns[i];
        if (countdown.countDownTempId == 'template_5' ||
            countdown.countDownTempId == 'template_6' ||
            countdown.countDownTempId == 'template_10') {
          
          // Create a new countdown with template_1 instead
          countdowns[i] = CountDownData(
            countDownId: countdown.countDownId,
            countDownTempId: 'template_1', // Migrate to template_1
            countDownTitle: countdown.countDownTitle,
            countDownTargetDate: countdown.countDownTargetDate,
            countDownDim: countdown.countDownDim,
            countDownCreatedDate: countdown.countDownCreatedDate,
            countDownImage: countdown.countDownImage,
          );
          hasChanges = true;
          print('Migrated countdown ${countdown.countDownId} from ${countdown.countDownTempId} to template_1');
        }
      }
      
      if (hasChanges) {
        await _saveCountdowns(countdowns);
        print('Template migration completed successfully');
      }
    } catch (e) {
      print('Error during template migration: ${e.toString()}');
    }
  }

  // Purchase related operations
  static Future<void> savePurchaseDetails() async {
    await updateIsPurchased(true);
    print('Purchase details saved');
  }

  static Future<bool> hasPurchasedPremium() async {
    final userData = await getCurrentUserData();
    return userData?.isPurchased ?? false;
  }

  // Rating URL (can be hardcoded or configurable)
  static Future<String> getRatingUrl() async {
    // You can store this in shared preferences or hardcode it
    return 'https://apps.apple.com/app/your-app-id'; // Replace with your actual app URL
  }

  // Sign out equivalent (just clears data if needed)
  static Future<void> signOut() async {
    // In local storage, we might just want to keep the data
    // or you can choose to clear everything
    print('User signed out locally');
  }

  // Auth state changes equivalent (always returns true for local user)
  static Stream<bool> authStateChanges() {
    return Stream.value(true);
  }

  // Onboarding Operations
  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  static Future<void> setOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, true);
    print('Onboarding marked as completed');
  }

  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, false);
    print('Onboarding reset - will show again on next app start');
  }
}
