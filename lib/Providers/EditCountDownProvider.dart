import 'package:flutter/material.dart';

class Editcountdownprovider extends ChangeNotifier {
  int _currentPage = 0;
  String _currentTitle = '';
  DateTime _currentDate = DateTime.now();
  String _currentImage = '';
  double _currentDim = 0.5; // Default dim value should be 0.5, not 0.0
  String _currentCountDownId = 'localID';
  String _currentCountDownTempId = 'template_1';
  DateTime _currentCreatedDate = DateTime.now();
  bool _isEditCountDown = false;

  int get currentPage => _currentPage;
  String get currentTitle => _currentTitle;
  DateTime get currentDate => _currentDate;
  String get image => _currentImage;
  double get currentDim => _currentDim;
  String get currentImage => _currentImage;
  String get currentCountDownId => _currentCountDownId;
  String get currentCountDownTempId => _currentCountDownTempId;
  DateTime get currentCreatedDate => _currentCreatedDate;
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

  set currentCreatedDate(DateTime value) {
    _currentCreatedDate = value;
    notifyListeners(); // Notify listeners (widgets) of state change
  }

  set isEditCountDown(bool value) {
    _isEditCountDown = value;
    notifyListeners(); // Notify listeners (widgets) of state change
  }
}
