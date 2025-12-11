import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timecountdown/Pages/AppWrapper.dart';
import 'package:timecountdown/Pages/WidgetConfigPage.dart';
import 'package:timecountdown/Providers/EditCountDownProvider.dart';
import 'package:timecountdown/Providers/PremiumProvider.dart';
import 'package:timecountdown/Providers/UserProvider.dart';
import 'package:timecountdown/Providers/RenderedWidgetProvider.dart';
import 'package:timecountdown/Providers/WidgetProvider.dart';
import 'package:timecountdown/Services/LocalStorageService.dart';
import 'package:timecountdown/Services/WidgetService.dart';
import 'package:timecountdown/Theme/Theme.dart';
import 'package:timecountdown/Services/RevenueCatService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local storage user data if needed
  await LocalStorageService.initializeUserData();

  // Initialize widget service
  await WidgetService.initialize();

  // Load all countdowns for widget
  try {
    final countdowns = await LocalStorageService.getCountdowns();
    await WidgetService.updateAllCountdowns(countdowns);
  } catch (e) {
    print('Error loading countdowns for widget: $e');
  }

  await _initializeRevenueCat();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Editcountdownprovider()),
        ChangeNotifierProvider(
            create: (context) => PremiumProvider()..checkPremiumStatus()),
        ChangeNotifierProvider(
            create: (context) => UserProvider()..fetchUserData()),
        ChangeNotifierProvider(create: (context) => RenderedWidgetProvider()),
        ChangeNotifierProvider(create: (context) => WidgetProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> _initializeRevenueCat() async {
  await RevenueCatService.initialize();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Time Countdown',
      theme: darkMode,
      home: AppWrapper(),
      routes: {
        '/widget_config': (context) => WidgetConfigPage(),
      },
    );
  }
}
