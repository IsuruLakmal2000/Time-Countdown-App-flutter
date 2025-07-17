import 'package:flutter/material.dart';
import 'package:timecountdown/Pages/MainPages/HomePage.dart';
import 'package:timecountdown/Pages/OnBoarding/OnBoardingScreen.dart';
import 'package:timecountdown/Services/LocalStorageService.dart';

class AppWrapper extends StatefulWidget {
  const AppWrapper({Key? key}) : super(key: key);

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  bool _isLoading = true;
  bool _showOnboarding = true;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
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
