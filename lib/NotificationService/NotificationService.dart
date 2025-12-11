import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  // Ensure timezones are initialized
  await initializeTimeZones();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
    requestSoundPermission: false,
    requestBadgePermission: false,
    requestAlertPermission: false,
  );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
    macOS: initializationSettingsDarwin,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      // Handle notification tap logic here
      print('Notification tapped: ${response.payload}');
    },
  );
}

Future<void> initializeTimeZones() async {
  try {
    print('Initializing time zones...');
    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    print('Current time zone: $currentTimeZone');
    tz.setLocalLocation(tz.getLocation(currentTimeZone));
  } catch (e) {
    print('Error initializing time zones: $e');
    // Fallback if needed
  }
}

Future<void> requestPermissions() async {
  if (Platform.isIOS || Platform.isMacOS) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  } else if (Platform.isAndroid) {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.requestNotificationsPermission();
    await androidImplementation?.requestExactAlarmsPermission();

    // Check status
    final bool? areEnabled =
        await androidImplementation?.areNotificationsEnabled();
    if (areEnabled == true) {
      print("Notification permission is granted.");
    } else {
      print("Notification permission is not granted.");
    }
  }
}

Future<void> scheduleReminder({
  required int id,
  required String title,
  required String body,
  required DateTime scheduledDate,
}) async {
  print('Scheduling reminder: $title for $scheduledDate');

  if (scheduledDate.isBefore(DateTime.now())) {
    print('Cannot schedule reminder in the past');
    throw Exception('Cannot schedule reminder in the past');
  }

  try {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'countdown_reminder_channel',
          'Countdown Reminders',
          channelDescription: 'Notifications for countdown reminders',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('alarm'),
        ),
        iOS: DarwinNotificationDetails(
          categoryIdentifier: 'countdown_reminder',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'default',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
    print('Reminder scheduled successfully for $scheduledDate with ID $id');
  } catch (e) {
    print('Error scheduling reminder: $e');
    throw e;
  }
}
