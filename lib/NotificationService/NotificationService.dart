import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

Future<void> initializeTimeZones() async {
  try {
    print('Initializing time zones...');
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    print('Current time zone: $currentTimeZone');
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));
  } catch (e) {
    print('Error initializing time zones: $e');
  }
}

Future<void> requestPermissions() async {
  final bool? isGranted = await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.areNotificationsEnabled();
  final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
  final bool? grantedNotificationPermission =
      await androidImplementation?.requestExactAlarmsPermission() ?? false;
  if (isGranted == true) {
    print("Notification permission is already granted.");
  } else {
    print(
        "Notification permission is not granted. Please enable it in settings.");
  }
}

Future<void> scheduleReminder(DateTime reminderTime) async {
  print('Scheduling reminder for $reminderTime');
  await flutterLocalNotificationsPlugin.zonedSchedule(
    0,
    'Countdown Reminder',
    'Your countdown ends in 1 hour!',
    tz.TZDateTime.from(reminderTime, tz.local),
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'Reminderid3',
        'reminderdwf',
        channelDescription: 'Your countdown ends in 1 hours!',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('alarm'),
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );
  print('Reminder scheduled for $reminderTime');
}
