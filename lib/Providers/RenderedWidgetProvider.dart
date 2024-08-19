import 'package:flutter/material.dart';

class RenderedWidgetProvider extends ChangeNotifier {
  String _renderedWidget = "none";
  double _dimCount = 0.5;

  String get renderedWidget => _renderedWidget;
  double get dimCount => _dimCount;

  set renderedWidget(String value) {
    _renderedWidget = value;
    notifyListeners(); // Notify listeners (widgets) of state change
  }

  set dimCount(double value) {
    _dimCount = value;
    notifyListeners(); // Notify listeners (widgets) of state change
  }
}
