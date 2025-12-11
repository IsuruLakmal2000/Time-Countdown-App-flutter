import 'package:flutter/material.dart';
import 'package:timecountdown/Pages/MainPages/HomePage.dart';
import 'package:timecountdown/Pages/OnBoarding/OnBoardingPage.dart';
import 'package:timecountdown/Services/LocalStorageService.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _nextPage() async {
    if (_currentPage < 2) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Mark onboarding as completed before navigating to main app
      await LocalStorageService.setOnboardingCompleted();

      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: [
              OnboardingPage(
                title: 'Stay Focused and Inspired',
                description:
                    'Stay focused on your goals, and let every tick of the clock remind you of your commitment to success!',
                imgUrl: "assets/Images/girls.jpg",
              ),
              OnboardingPage(
                title: 'Make Every Second Count',
                description:
                    'Reach your goals with our countdown timer. Every second matters',
                imgUrl: "assets/Images/dream.jpg",
              ),
              OnboardingPage(
                title: 'Time is Your Ally',
                description:
                    'Set a deadline and let our countdown keep you on track to achieve your goals',
                imgUrl: "assets/Images/cafe.jpg",
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => _buildDot(index, _currentPage),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 20,
            child: IconButton(
              onPressed: _nextPage,
              icon: Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index, int currentPage) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      height: 10,
      width: 10,
      decoration: BoxDecoration(
        color: currentPage == index ? Colors.white : Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }
}
