import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timecountdown/Pages/AppWrapper.dart';
import 'package:timecountdown/Pages/WidgetPages/WidgetConfigurationPage.dart';
import 'package:timecountdown/Providers/EditCountDownProvider.dart';
import 'package:timecountdown/Providers/PremiumProvider.dart';
import 'package:timecountdown/Providers/RenderedWidgetProvider.dart';
import 'package:timecountdown/Providers/UserProvider.dart';
import 'package:timecountdown/Services/LocalStorageService.dart';
import 'package:timecountdown/Theme/Theme.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize local storage user data if needed
  await LocalStorageService.initializeUserData();
  
  await _initializeRevenueCat();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Editcountdownprovider()),
        ChangeNotifierProvider(create: (context) => RenderedWidgetProvider()),
        ChangeNotifierProvider(
            create: (context) => PremiumProvider()..checkPremiumStatus()),
        ChangeNotifierProvider(create: (context) => UserProvider()..fetchUserData()),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> _initializeRevenueCat() async {
  try {
    await Purchases.setLogLevel(LogLevel.debug);
    PurchasesConfiguration configuration;
    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration("goog_olOAnQcQvdhSNeRGbIDWNoXJOoi");
    } else if (Platform.isIOS) {
      configuration = PurchasesConfiguration("appl_NsiZfSrVfgdJwEVKRRIzfVZrjiU");
    } else {
      // Handle other platforms if necessary
      return;
    }
    await Purchases.configure(configuration);
  } catch (e) {
    print('Failed to initialize RevenueCat: $e');
  }
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
        '/widget_config': (context) => WidgetConfigurationPage(),
      },
      onGenerateRoute: (settings) {
        // Handle deep links
        if (settings.name?.contains('widget-config') == true) {
          return MaterialPageRoute(
            builder: (context) => WidgetConfigurationPage(),
            settings: settings,
          );
        } else if (settings.name == '/widget_config') {
          return MaterialPageRoute(
            builder: (context) => WidgetConfigurationPage(),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}
