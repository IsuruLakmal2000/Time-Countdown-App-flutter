import 'package:flutter/material.dart';
import 'package:timecountdown/FirebaseServices/FirebaseSerives.dart';
import 'package:timecountdown/Model/UserData.dart';

class UserProvider extends ChangeNotifier {
  UserData? _userData;

  UserData? get userData => _userData;

  Future<void> fetchUserData() async {
    print("Fetching user data");
    _userData = await getCurrentUserData();

    notifyListeners();
  }

  // Other methods related to user data
}
