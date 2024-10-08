import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:timecountdown/FirebaseServices/FirebaseSerives.dart';
import 'package:timecountdown/NotificationService/NotificationService.dart';
import 'package:timecountdown/Pages/MainPages/HomePage.dart';
import 'package:timecountdown/Pages/OnBoarding/OnBoardingScreen.dart';
import 'package:timecountdown/Pages/PremiumPage/PremiumPage.dart';
import 'package:timecountdown/Pages/SignInPage.dart';
import 'package:timecountdown/Providers/EditCountDownProvider.dart';
import 'package:timecountdown/Providers/RenderedWidgetProvider.dart';

import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timecountdown/Providers/UserProvider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  unawaited(MobileAds.instance.initialize());
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
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // User is signed in

            return HomePage();
          } else {
            // User is not signed in
            return OnboardingScreen();
          }
        },
      ),
    );
  }
}
