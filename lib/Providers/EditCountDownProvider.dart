import 'dart:io';

import 'package:flutter/material.dart';

class Editcountdownprovider extends ChangeNotifier {
  int _currentPage = 0;

  int get currentPage => _currentPage;

  set currentPage(int value) {
    _currentPage = value;
    notifyListeners(); // Notify listeners (widgets) of state change
  }
}
