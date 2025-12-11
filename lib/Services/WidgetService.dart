import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timecountdown/Model/CountDownData.dart';

class WidgetService {
  static const String androidWidgetName = 'CountdownWidgetProvider';
  static const String iOSWidgetName = 'CountdownWidgetExtension';
  static const String appGroupId = 'group.com.circularx.timecountdown.widgets';
  static const String widgetUpdateWorkName = 'countdown_widget_update';

  // Platform channel for iOS image copying
  static const MethodChannel _iosChannel =
      MethodChannel('com.circularx.timecountdown/widget_config');

  /// Initialize the home widget
  static Future<void> initialize() async {
    try {
      // Set the App Group ID for iOS
      if (Platform.isIOS) {
        await HomeWidget.setAppGroupId(appGroupId);
      }

      if (Platform.isAndroid) {
        // Register for background updates
        await HomeWidget.registerInteractivityCallback(backgroundCallback);
      }

      print('WidgetService initialized for ${Platform.operatingSystem}');
    } catch (e) {
      print('Error initializing widget: $e');
    }
  }

  /// Background callback for widget updates
  static Future<void> backgroundCallback(Uri? uri) async {
    print('Widget background callback triggered');
  }

  /// Copy image to iOS App Group container for widget access
  static Future<String?> _copyImageToiOSAppGroup(String imagePath) async {
    if (!Platform.isIOS || imagePath.isEmpty) {
      print('WidgetService: Skipping image copy - not iOS or empty path');
      return null;
    }

    try {
      final fileName = path.basename(imagePath);
      print('WidgetService: Copying image to iOS App Group');
      print('WidgetService: Source path: $imagePath');
      print('WidgetService: File name: $fileName');

      // Check if it's a Flutter asset path
      if (imagePath.startsWith('assets/')) {
        // Use copyAssetImageToAppGroup for Flutter assets
        print(
            'WidgetService: Detected asset path, using copyAssetImageToAppGroup');
        final result =
            await _iosChannel.invokeMethod('copyAssetImageToAppGroup', {
          'assetPath': imagePath,
          'fileName': fileName,
        });
        print('WidgetService: Copied asset image to iOS App Group: $result');
        return result as String?;
      } else {
        // It's a file path (user-selected image from gallery/camera)
        print('WidgetService: Detected file path, using copyImageToAppGroup');

        // Verify the source file exists before trying to copy
        final sourceFile = File(imagePath);
        if (!await sourceFile.exists()) {
          print(
              'WidgetService: WARNING - Source file does not exist at: $imagePath');
          // The file might have been moved or path is incorrect
          // Try to continue anyway as native code might handle it
        }

        final result = await _iosChannel.invokeMethod('copyImageToAppGroup', {
          'sourcePath': imagePath,
          'fileName': fileName,
        });
        print('WidgetService: Copied image to iOS App Group: $result');
        return result as String?;
      }
    } on PlatformException catch (e) {
      print('WidgetService: PlatformException copying image to iOS App Group:');
      print('WidgetService: Code: ${e.code}');
      print('WidgetService: Message: ${e.message}');
      print('WidgetService: Details: ${e.details}');
      return null;
    } catch (e) {
      print('WidgetService: Error copying image to iOS App Group: $e');
      return null;
    }
  }

  /// Update widget with countdown data
  static Future<void> updateWidget(CountDownData countdown) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Retrieve existing countdowns list
      String? existingJson = prefs.getString('widget_countdowns');
      List<dynamic> countdownsList = [];

      if (existingJson != null) {
        try {
          countdownsList = jsonDecode(existingJson);
        } catch (e) {
          print('Error parsing existing widget countdowns: $e');
          countdownsList = [];
        }
      }

      // Copy image to iOS App Group if on iOS
      if (Platform.isIOS && countdown.countDownImage.isNotEmpty) {
        await _copyImageToiOSAppGroup(countdown.countDownImage);
      }

      // Create JSON for current countdown
      final countdownMap = {
        'id': countdown.countDownId,
        'title': countdown.countDownTitle,
        'targetDate': countdown.countDownTargetDate.millisecondsSinceEpoch,
        'image': countdown.countDownImage,
        'createdDate': countdown.countDownCreatedDate.millisecondsSinceEpoch,
        'templateId': countdown.countDownTempId,
      };

      // Check if this countdown already exists in the list and update it
      int index = countdownsList
          .indexWhere((item) => item['id'] == countdown.countDownId);
      if (index != -1) {
        countdownsList[index] = countdownMap;
      } else {
        countdownsList.add(countdownMap);
      }

      // Store updated list in SharedPreferences (for Android)
      final updatedJson = jsonEncode(countdownsList);
      await prefs.setString('widget_countdowns', updatedJson);
      print(
          'WidgetDebug: Updated widget_countdowns list. Total items: ${countdownsList.length}');

      // Store the countdown ID for the widget (Legacy/Single widget support)
      await prefs.setString('widget_countdown_id', countdown.countDownId);

      // Save using home_widget for cross-platform support
      await HomeWidget.saveWidgetData<String>(
          'countdown_title', countdown.countDownTitle);
      await HomeWidget.saveWidgetData<String>(
          'countdown_id', countdown.countDownId);
      await HomeWidget.saveWidgetData<String>(
          'target_date', countdown.countDownTargetDate.toIso8601String());
      await HomeWidget.saveWidgetData<String>(
          'countdown_image', countdown.countDownImage);

      // Save the full countdowns list as JSON for iOS widget
      await HomeWidget.saveWidgetData<String>('countdowns', updatedJson);

      // Update the widget based on platform
      if (Platform.isAndroid) {
        await HomeWidget.updateWidget(androidName: androidWidgetName);
      } else if (Platform.isIOS) {
        await HomeWidget.updateWidget(iOSName: iOSWidgetName);
      }

      print(
          'Widget updated successfully with countdown: ${countdown.countDownTitle}');
    } catch (e) {
      print('Error updating widget: $e');
    }
  }

  /// Remove widget data
  static Future<void> clearWidget() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Clear the stored countdown data
      await prefs.remove('widget_countdowns');
      await prefs.remove('widget_countdown_id');
      print('WidgetDebug: Cleared widget_countdowns and widget_countdown_id');

      await HomeWidget.saveWidgetData<String>('countdown_title', null);
      await HomeWidget.saveWidgetData<String>('countdown_id', null);
      await HomeWidget.saveWidgetData<String>('target_date', null);
      await HomeWidget.saveWidgetData<String>('countdown_image', null);
      await HomeWidget.saveWidgetData<String>('countdowns', null);

      // Update the widget based on platform
      if (Platform.isAndroid) {
        await HomeWidget.updateWidget(androidName: androidWidgetName);
      } else if (Platform.isIOS) {
        await HomeWidget.updateWidget(iOSName: iOSWidgetName);
      }

      print('Widget cleared successfully');
    } catch (e) {
      print('Error clearing widget: $e');
    }
  }

  /// Update all countdowns data for widget picker
  static Future<void> updateAllCountdowns(
      List<CountDownData> countdowns) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Copy all images to iOS App Group container if on iOS
      if (Platform.isIOS) {
        for (final countdown in countdowns) {
          if (countdown.countDownImage.isNotEmpty) {
            await _copyImageToiOSAppGroup(countdown.countDownImage);
          }
        }
      }

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

      // Save to SharedPreferences (for Android legacy support)
      await prefs.setString('widget_countdowns', countdownsJson);
      print(
          'WidgetDebug: Saving widget_countdowns to SharedPreferences: $countdownsJson');

      // Save using home_widget for cross-platform App Groups support
      await HomeWidget.saveWidgetData<String>('countdowns', countdownsJson);

      // Update the widget based on platform
      if (Platform.isAndroid) {
        await HomeWidget.updateWidget(androidName: androidWidgetName);
      } else if (Platform.isIOS) {
        await HomeWidget.updateWidget(iOSName: iOSWidgetName);
      }

      print('Updated ${countdowns.length} countdowns for widget');
    } catch (e) {
      print('Error updating all countdowns: $e');
    }
  }
}
