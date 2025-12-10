import 'dart:convert';
import 'dart:io';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timecountdown/Model/CountDownData.dart';

class WidgetService {
  static const String androidWidgetName = 'CountdownWidgetProvider';
  static const String widgetUpdateWorkName = 'countdown_widget_update';

  /// Initialize the home widget
  static Future<void> initialize() async {
    try {
      if (Platform.isAndroid) {
        // Register for background updates
        await HomeWidget.registerInteractivityCallback(backgroundCallback);
      }
    } catch (e) {
      print('Error initializing widget: $e');
    }
  }

  /// Background callback for widget updates
  static Future<void> backgroundCallback(Uri? uri) async {
    print('Widget background callback triggered');
  }

  /// Update widget with countdown data
  static Future<void> updateWidget(CountDownData countdown) async {
    try {
      if (!Platform.isAndroid) return;

      final prefs = await SharedPreferences.getInstance();

      // Store countdown data as JSON in the format expected by native code
      final countdownJson = jsonEncode({
        'id': countdown.countDownId,
        'title': countdown.countDownTitle,
        'targetDate': countdown.countDownTargetDate.millisecondsSinceEpoch,
        'image': countdown.countDownImage,
        'createdDate': countdown.countDownCreatedDate.millisecondsSinceEpoch,
        'templateId': countdown.countDownTempId,
      });
      print('WidgetDebug: Converted JSON: $countdownJson');

      // Store as a list of countdowns (the native code expects an array)
      await prefs.setString('widget_countdowns', '[$countdownJson]');
      print(
          'WidgetDebug: Saving widget_countdowns to SharedPreferences: [$countdownJson]');

      // Store the countdown ID for the widget (this is critical!)
      await prefs.setString('widget_countdown_id', countdown.countDownId);
      print(
          'WidgetDebug: Saving widget_countdown_id to SharedPreferences: ${countdown.countDownId}');

      // Also save using home_widget for consistency
      await HomeWidget.saveWidgetData<String>(
          'countdown_title', countdown.countDownTitle);
      await HomeWidget.saveWidgetData<String>(
          'countdown_id', countdown.countDownId);
      await HomeWidget.saveWidgetData<String>(
          'target_date', countdown.countDownTargetDate.toIso8601String());
      await HomeWidget.saveWidgetData<String>(
          'countdown_image', countdown.countDownImage);

      // Update the widget
      await HomeWidget.updateWidget(androidName: androidWidgetName);

      print(
          'Widget updated successfully with countdown: ${countdown.countDownTitle}');
      print('Countdown ID: ${countdown.countDownId}');
      print('Target date: ${countdown.countDownTargetDate}');
    } catch (e) {
      print('Error updating widget: $e');
    }
  }

  /// Remove widget data
  static Future<void> clearWidget() async {
    try {
      if (!Platform.isAndroid) return;

      final prefs = await SharedPreferences.getInstance();

      // Clear the stored countdown data
      await prefs.remove('widget_countdowns');
      await prefs.remove('widget_countdown_id');
      print('WidgetDebug: Cleared widget_countdowns and widget_countdown_id');

      await HomeWidget.saveWidgetData<String>('countdown_title', null);
      await HomeWidget.saveWidgetData<String>('countdown_id', null);
      await HomeWidget.saveWidgetData<String>('target_date', null);
      await HomeWidget.saveWidgetData<String>('countdown_image', null);

      await HomeWidget.updateWidget(androidName: androidWidgetName);
      print('Widget cleared successfully');
    } catch (e) {
      print('Error clearing widget: $e');
    }
  }

  /// Update all countdowns data for widget picker
  static Future<void> updateAllCountdowns(
      List<CountDownData> countdowns) async {
    try {
      if (!Platform.isAndroid) return;

      final prefs = await SharedPreferences.getInstance();

      // Convert all countdowns to JSON
      final countdownsList = countdowns
          .map((countdown) => {
                'id': countdown.countDownId,
                'title': countdown.countDownTitle,
                'targetDate':
                    countdown.countDownTargetDate.millisecondsSinceEpoch,
                'image': countdown.countDownImage,
                'createdDate':
                    countdown.countDownCreatedDate.millisecondsSinceEpoch,
                'templateId': countdown.countDownTempId,
              })
          .toList();

      final countdownsJson = jsonEncode(countdownsList);
      print('WidgetDebug: Converted JSON: $countdownsJson');
      await prefs.setString('widget_countdowns', countdownsJson);
      print(
          'WidgetDebug: Saving widget_countdowns to SharedPreferences: $countdownsJson');

      print('Updated ${countdowns.length} countdowns for widget');
    } catch (e) {
      print('Error updating all countdowns: $e');
    }
  }
}
