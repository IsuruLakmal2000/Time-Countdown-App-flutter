import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timecountdown/Model/CountDownData.dart';
import 'package:timecountdown/Services/LocalStorageService.dart';

class CountdownWidgetService {
  static const platform = MethodChannel('com.circularx.timecountdown/widget_config');
  
  // Widget style options
  static const String STYLE_GLASS = 'glass';
  static const String STYLE_NEOMORPHISM = 'neomorphism';
  static const String STYLE_GRADIENT = 'gradient';
  static const String STYLE_SUNSET = 'sunset';
  
  // Get all available countdowns for widget selection
  static Future<List<CountDownData>> getAvailableCountdowns() async {
    return await LocalStorageService.getCountdowns();
  }
  
  // Update widget data whenever countdowns change
  static Future<void> updateWidgetData() async {
    try {
      final countdowns = await LocalStorageService.getCountdowns();
      final prefs = await SharedPreferences.getInstance();
      
      // Convert countdown data to a format native Android can easily parse
      final List<Map<String, dynamic>> widgetData = countdowns.map((countdown) => {
        'id': countdown.countDownId,
        'title': countdown.countDownTitle,
        'targetDate': countdown.countDownTargetDate.millisecondsSinceEpoch,
        'createdDate': countdown.countDownCreatedDate.millisecondsSinceEpoch,
      }).toList();
      
      // Save to shared preferences with a key the native side can access
      await prefs.setString('widget_countdowns', json.encode(widgetData));
      
      print('Widget data updated: ${widgetData.length} countdowns');
    } catch (e) {
      print('Error updating widget data: $e');
    }
  }
  
  // Save widget configuration
  static Future<void> configureWidget(String countdownId) async {
    try {
      await platform.invokeMethod('configureWidget', {
        'countdownId': countdownId,
      });
    } on PlatformException catch (e) {
      print("Failed to configure widget: '${e.message}'.");
      throw e;
    }
  }
  
  // Cancel widget configuration
  static Future<void> cancelConfiguration() async {
    try {
      await platform.invokeMethod('cancelConfiguration');
    } on PlatformException catch (e) {
      print("Failed to cancel configuration: '${e.message}'.");
      throw e;
    }
  }
  
  // Get widget ID during configuration
  static Future<int> getWidgetId() async {
    try {
      final int widgetId = await platform.invokeMethod('getWidgetId');
      return widgetId;
    } on PlatformException catch (e) {
      print("Failed to get widget ID: '${e.message}'.");
      return -1;
    }
  }
  
  // Format countdown for widget display
  static Map<String, int> calculateTimeRemaining(DateTime targetDate) {
    final now = DateTime.now();
    final difference = targetDate.difference(now);
    
    if (difference.isNegative) {
      return {
        'days': 0,
        'hours': 0,
        'minutes': 0,
        'seconds': 0,
      };
    }
    
    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;
    
    return {
      'days': days,
      'hours': hours,
      'minutes': minutes,
      'seconds': seconds,
    };
  }
  
  // Widget style management
  static Future<void> setWidgetStyle(String style) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('widget_style', style);
      
      // Notify native Android to update widget appearance
      try {
        await platform.invokeMethod('updateWidgetStyle', {
          'style': style,
        });
      } catch (e) {
        print('Native style update not available: $e');
        // Continue anyway, as the style preference is saved
      }
      
      print('Widget style updated to: $style');
    } catch (e) {
      print('Error updating widget style: $e');
    }
  }
  
  static Future<String> getWidgetStyle() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('widget_style') ?? STYLE_NEOMORPHISM; // Default to neomorphism (free style)
    } catch (e) {
      print('Error getting widget style: $e');
      return STYLE_NEOMORPHISM;
    }
  }
}