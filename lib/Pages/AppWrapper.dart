import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timecountdown/Pages/MainPages/HomePage.dart';
import 'package:timecountdown/Pages/OnBoarding/OnBoardingScreen.dart';
import 'package:timecountdown/Pages/WidgetPages/IOSMultiWidgetConfigurationPage.dart';
import 'package:timecountdown/Services/LocalStorageService.dart';
import 'package:timecountdown/Services/CountdownWidgetService.dart';

class AppWrapper extends StatefulWidget {
  const AppWrapper({Key? key}) : super(key: key);

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  bool _isLoading = true;
  bool _showOnboarding = true;
  static const platform = MethodChannel('com.circularx.timecountdown/deep_link');

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
    _setupDeepLinkHandling();
    _initializeWidgetData();
  }

  Future<void> _initializeWidgetData() async {
    try {
      // Update widget data when app starts to ensure widgets have latest countdowns
      await CountdownWidgetService.updateWidgetData();
      print('Widget data initialized successfully');
    } catch (e) {
      print('Failed to initialize widget data: $e');
    }
  }

  void _setupDeepLinkHandling() {
    if (Platform.isIOS) {
      platform.setMethodCallHandler((call) async {
        if (call.method == 'handleDeepLink') {
          final url = call.arguments['url'] as String?;
          if (url?.contains('widget-config') == true) {
            _showIOSWidgetConfiguration();
          }
        }
      });
    }
  }

  void _showIOSWidgetConfiguration() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const IOSMultiWidgetConfigurationPage(),
        fullscreenDialog: true,
      ),
    );
  }

  Future<void> _checkOnboardingStatus() async {
    try {
      final isOnboardingCompleted = await LocalStorageService.isOnboardingCompleted();
      setState(() {
        _showOnboarding = !isOnboardingCompleted;
        _isLoading = false;
      });
    } catch (e) {
      print('Error checking onboarding status: $e');
      // Default to showing onboarding if there's an error
      setState(() {
        _showOnboarding = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    return _showOnboarding ? OnboardingScreen() : HomePage();
  }
}
