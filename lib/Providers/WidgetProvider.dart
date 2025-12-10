import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timecountdown/Model/CountDownData.dart';
import 'package:timecountdown/Services/WidgetService.dart';

class WidgetProvider extends ChangeNotifier {
  CountDownData? _selectedCountdownForWidget;
  bool _isWidgetActive = false;

  CountDownData? get selectedCountdownForWidget => _selectedCountdownForWidget;
  bool get isWidgetActive => _isWidgetActive;

  /// Set countdown for widget
  Future<void> setCountdownForWidget(CountDownData countdown) async {
    _selectedCountdownForWidget = countdown;
    _isWidgetActive = true;
    
    // Update the widget with the countdown data
    await WidgetService.updateWidget(countdown);
    
    // Save the widget state
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('flutter.active_widget_countdown_id', countdown.countDownId);
    
    notifyListeners();
  }

  /// Clear widget
  Future<void> clearWidget() async {
    _selectedCountdownForWidget = null;
    _isWidgetActive = false;
    
    await WidgetService.clearWidget();
    
    // Clear the widget state
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('flutter.active_widget_countdown_id');
    
    notifyListeners();
  }

  /// Update widget with latest countdown data
  Future<void> updateWidget(CountDownData countdown) async {
    if (_isWidgetActive && _selectedCountdownForWidget?.countDownId == countdown.countDownId) {
      _selectedCountdownForWidget = countdown;
      await WidgetService.updateWidget(countdown);
      notifyListeners();
    }
  }

  /// Check if a specific countdown is set for widget
  bool isCountdownSetForWidget(String countdownId) {
    return _isWidgetActive && 
           _selectedCountdownForWidget?.countDownId == countdownId;
  }
  
  /// Load widget state on app start
  Future<void> loadWidgetState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final activeCountdownId = prefs.getString('flutter.active_widget_countdown_id');
      
      if (activeCountdownId != null && activeCountdownId.isNotEmpty) {
        _isWidgetActive = true;
        // The countdown data will be loaded when needed
        notifyListeners();
      }
    } catch (e) {
      print('Error loading widget state: $e');
    }
  }
}

