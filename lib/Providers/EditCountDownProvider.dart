import 'package:flutter/material.dart';

class Editcountdownprovider extends ChangeNotifier {
  int _currentPage = 0;
  String _currentTitle = '';
  DateTime _currentDate = DateTime.now();
  String _currentImage = '';
  double _currentDim = 0.0;
  String _currentCountDownId = 'firebaseID';
  String _currentCountDownTempId = 'template_1';
  bool _isEditCountDown = false;

  int get currentPage => _currentPage;
  String get currentTitle => _currentTitle;
  DateTime get currentDate => _currentDate;
  String get image => _currentImage;
  double get currentDim => _currentDim;
  String get currentImage => _currentImage;
  String get currentCountDownId => _currentCountDownId;
  String get currentCountDownTempId => _currentCountDownTempId;
  bool get isEditCountDown => _isEditCountDown;

  set currentPage(int value) {
    _currentPage = value;
    notifyListeners(); // Notify listeners (widgets) of state change
  }

  set currentTitle(String value) {
    _currentTitle = value;
    notifyListeners(); // Notify listeners (widgets) of state change
  }

  set currentDate(DateTime value) {
    _currentDate = value;
    notifyListeners(); // Notify listeners (widgets) of state change
  }

  set currentDim(double value) {
    _currentDim = value;
    notifyListeners(); // Notify listeners (widgets) of state change
  }

  set currentImage(String value) {
    _currentImage = value;
    notifyListeners(); // Notify listeners (widgets) of state change
  }

  set currentCountDownId(String value) {
    _currentCountDownId = value;
    notifyListeners(); // Notify listeners (widgets) of state change
  }

  set currentCountDownTempId(String value) {
    _currentCountDownTempId = value;
    notifyListeners(); // Notify listeners (widgets) of state change
  }

  set isEditCountDown(bool value) {
    _isEditCountDown = value;
    notifyListeners(); // Notify listeners (widgets) of state change
  }
}
