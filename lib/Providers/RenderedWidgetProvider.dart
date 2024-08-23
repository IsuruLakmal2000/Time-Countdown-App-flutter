import 'dart:io';

import 'package:flutter/material.dart';

class RenderedWidgetProvider extends ChangeNotifier {
  String _renderedWidget = "none";
  double _dimCount = 0.5;
  String _templateId = "template_1";
  String _countDownTitle = "Template 1";
  String _image = '';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  String get renderedWidget => _renderedWidget;
  double get dimCount => _dimCount;
  String get templateId => _templateId;
  DateTime get selectedDate => _selectedDate;
  String get countDownTitle => _countDownTitle;
  bool get isLoading => _isLoading;
  String get image => _image;

  set renderedWidget(String value) {
    _renderedWidget = value;
    notifyListeners(); // Notify listeners (widgets) of state change
  }

  set dimCount(double value) {
    _dimCount = value;
    notifyListeners(); // Notify listeners (widgets) of state change
  }

  set templateId(String value) {
    _templateId = value;
    notifyListeners(); // Notify listeners (widgets) of state change
  }

  set selectedDate(DateTime value) {
    _selectedDate = value;
    notifyListeners(); // Notify listeners (widgets) of state change
  }

  set countDownTitle(String value) {
    _countDownTitle = value;
    notifyListeners(); // Notify listeners (widgets) of state change
  }

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners(); // Notify listeners (widgets) of state change
  }

  set image(String value) {
    _image = value;
    notifyListeners(); // Notify listeners (widgets) of state change
  }
}
