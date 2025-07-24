import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timecountdown/Model/CountDownData.dart';
import 'package:timecountdown/Services/LocalStorageService.dart';

class CountdownWidgetService {
  static const platform = MethodChannel('com.circularx.timecountdown/widget_config');
  
  // Widget update frequency options
  static const String FREQUENCY_1_MIN = '1min';
  static const String FREQUENCY_5_MIN = '5min';
  static const String FREQUENCY_15_MIN = '15min';
  static const String FREQUENCY_1_HOUR = '1hour';
  
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
      
      // Convert countdown data to a format native platforms can parse
      final List<Map<String, dynamic>> widgetData = countdowns.map((countdown) => {
        'id': countdown.countDownId,
        'title': countdown.countDownTitle,
        'targetDate': countdown.countDownTargetDate.millisecondsSinceEpoch,
        'createdDate': countdown.countDownCreatedDate.millisecondsSinceEpoch,
      }).toList();
      
      // Save to shared preferences with a key the native sides can access
      await prefs.setString('widget_countdowns', json.encode(widgetData));
      
      if (Platform.isAndroid) {
        print('Android widget data updated successfully');
      } else if (Platform.isIOS) {
        print('iOS widget data updated successfully');
        
        // Update iOS App Groups UserDefaults for widget extension
        try {
          await platform.invokeMethod('updateWidgetData', {
            'countdowns': json.encode(widgetData),
          });
          print('iOS UserDefaults updated successfully');
        } catch (e) {
          print('iOS widget data update failed: $e');
        }
        
        // Notify iOS WidgetKit to reload widgets
        try {
          await platform.invokeMethod('reloadTimelines');
          print('iOS widget timelines reloaded successfully');
        } catch (e) {
          print('iOS widget reload failed: $e');
        }
      }
    } catch (e) {
      print('Error updating widget data: $e');
    }
  }
  
  // Save widget configuration
  static Future<void> configureWidget(String countdownId) async {
    try {
      if (Platform.isAndroid) {
        await platform.invokeMethod('configureWidget', {
          'countdownId': countdownId,
        });
      } else if (Platform.isIOS) {
        // For iOS, we'll configure the widget directly
        await configureIOSWidget(countdownId);
      }
    } on PlatformException catch (e) {
      print("Failed to configure widget: '${e.message}'.");
      throw e;
    }
  }
  
  // Configure iOS widget with selected countdown
  static Future<void> configureIOSWidget(String countdownId, {String? widgetId}) async {
    try {
      // First, ensure widget data is up to date
      await updateWidgetData();
      
      final prefs = await SharedPreferences.getInstance();
      
      // Store the selected countdown ID for global use
      await prefs.setString('ios_widget_countdown_global', countdownId);
      
      print('Configuring iOS widget with countdown ID: $countdownId');
      
      // Configure the widget through platform channel
      await platform.invokeMethod('configureIOSWidget', {
        'countdownId': countdownId,
      });
      
      print('iOS widget configured successfully with countdown: $countdownId');
    } catch (e) {
      print('Error configuring iOS widget: $e');
      throw e;
    }
  }
  
  // Configure specific iOS widget by index
  static Future<void> configureIOSWidgetByIndex(int widgetIndex, String countdownId) async {
    try {
      // First, ensure widget data is up to date
      await updateWidgetData();
      
      print('Configuring iOS widget index $widgetIndex with countdown ID: $countdownId');
      
      // Configure the widget through platform channel
      await platform.invokeMethod('configureIOSWidgetByIndex', {
        'widgetIndex': widgetIndex,
        'countdownId': countdownId,
      });
      
      print('iOS widget index $widgetIndex configured successfully with countdown: $countdownId');
    } catch (e) {
      print('Error configuring iOS widget by index: $e');
      throw e;
    }
  }
  
  // Configure iOS widget by index with frequency
  static Future<void> configureIOSWidgetByIndexWithFrequency(int widgetIndex, String countdownId, String frequency) async {
    try {
      await platform.invokeMethod('configureIOSWidgetByIndex', {
        'widgetIndex': widgetIndex,
        'countdownId': countdownId,
        'frequency': frequency,
      });
      print('iOS widget index $widgetIndex configured with countdown: $countdownId and frequency: $frequency');
    } catch (e) {
      print('Error configuring iOS widget by index with frequency: $e');
      throw e;
    }
  }
  
  // Get iOS widget configuration
  static Future<String?> getIOSWidgetConfiguration(String widgetId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('ios_widget_countdown_$widgetId');
    } catch (e) {
      print('Error getting iOS widget configuration: $e');
      return null;
    }
  }
  
  // Get all iOS widget indices and their assigned countdowns
  static Future<Map<int, String>> getIOSWidgetIndicesConfiguration() async {
    try {
      final result = await platform.invokeMethod('getIOSWidgetConfiguration');
      // Convert String keys to int keys
      final Map<int, String> config = {};
      if (result is Map) {
        result.forEach((key, value) {
          if (key is String && value is String) {
            final index = int.tryParse(key);
            if (index != null) {
              config[index] = value;
            }
          }
        });
      }
      return config;
    } catch (e) {
      print('Error getting iOS widget configuration: $e');
      return {};
    }
  }
  
  // Get iOS widget frequency configuration
  static Future<Map<int, String>> getIOSWidgetFrequencyConfiguration() async {
    try {
      final result = await platform.invokeMethod('getIOSWidgetFrequencyConfiguration');
      final Map<int, String> config = {};
      if (result is Map) {
        result.forEach((key, value) {
          if (key is String && value is String) {
            final index = int.tryParse(key);
            if (index != null) {
              config[index] = value;
            }
          }
        });
      }
      return config;
    } catch (e) {
      print('Error getting iOS widget frequency configuration: $e');
      return {};
    }
  }
  
  // List all configured iOS widgets
  static Future<Map<String, String>> getIOSConfiguredWidgets() async {
    try {
      final result = await platform.invokeMethod('getConfiguredWidgets');
      return Map<String, String>.from(result);
    } catch (e) {
      print('Error getting iOS configured widgets: $e');
      return {};
    }
  }
  
  // Cancel widget configuration
  static Future<void> cancelConfiguration() async {
    try {
      await platform.invokeMethod('cancelConfiguration');
    } on PlatformException catch (e) {
      print("Failed to cancel widget configuration: '${e.message}'.");
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
      
      // Notify platform to update widget appearance
      try {
        await platform.invokeMethod('updateWidgetStyle', {
          'style': style,
        });
      } catch (e) {
        print('Widget style update failed: $e');
        // Continue anyway, as the style preference is saved
      }
      
      if (Platform.isAndroid) {
        print('Android widget style updated to: $style');
      } else if (Platform.isIOS) {
        print('iOS widget style updated to: $style');
      }
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

  // Configure Android widget with frequency
  static Future<void> configureAndroidWidgetWithFrequency(int widgetId, String countdownId, String frequency) async {
    try {
      await platform.invokeMethod('configureWidget', {
        'countdownId': countdownId,
        'frequency': frequency,
        'widgetId': widgetId,
      });
      print('Android widget $widgetId configured with countdown: $countdownId and frequency: $frequency');
    } on PlatformException catch (e) {
      print("Failed to configure Android widget with frequency: '${e.message}'.");
      throw e;
    }
  }
  
  // Get Android widget frequency configuration
  static Future<Map<int, String>> getAndroidWidgetFrequencyConfiguration() async {
    try {
      final result = await platform.invokeMethod('getAndroidWidgetFrequencyConfiguration');
      final Map<int, String> config = {};
      if (result is Map) {
        result.forEach((key, value) {
          if (key is int && value is String) {
            config[key] = value;
          } else if (key is String && value is String) {
            final index = int.tryParse(key);
            if (index != null) {
              config[index] = value;
            }
          }
        });
      }
      return config;
    } catch (e) {
      print('Error getting Android widget frequency configuration: $e');
      return {};
    }
  }

  // Get Android widget configuration
  static Future<Map<int, String>> getAndroidWidgetConfiguration() async {
    try {
      final result = await platform.invokeMethod('getAndroidWidgetConfiguration');
      final Map<int, String> config = {};
      if (result is Map) {
        result.forEach((key, value) {
          if (key is int && value is String) {
            config[key] = value;
          } else if (key is String && value is String) {
            final index = int.tryParse(key);
            if (index != null) {
              config[index] = value;
            }
          }
        });
      }
      return config;
    } catch (e) {
      print('Error getting Android widget configuration: $e');
      return {};
    }
  }
}