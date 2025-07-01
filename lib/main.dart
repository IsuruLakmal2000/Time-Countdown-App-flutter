import 'package:flutter/material.dart';
import 'package:timecountdown/Services/LocalStorageService.dart';
import 'package:timecountdown/NotificationService/NotificationService.dart';
import 'package:timecountdown/Pages/MainPages/HomePage.dart';
import 'package:timecountdown/Providers/EditCountDownProvider.dart';
import 'package:timecountdown/Providers/RenderedWidgetProvider.dart';

import 'package:provider/provider.dart';
import 'package:timecountdown/Providers/UserProvider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.initializeUserData();
  await initializeTimeZones();
  await initializeNotifications();
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => RenderedWidgetProvider()),
      ChangeNotifierProvider(create: (context) => Editcountdownprovider()),
      ChangeNotifierProvider(create: (context) => UserProvider()),
    ], child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(brightness: Brightness.dark),
      // theme: lightMode,
      //   darkTheme: darkMode,
      //  home: OnboardingScreen(),
      home: HomePage(), // Directly go to HomePage since no authentication needed
    );
  }
}
