import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timecountdown/Component/BottomBarItemComponent.dart';
import 'package:timecountdown/Services/LocalStorageService.dart';

import 'package:timecountdown/Model/CountDownData.dart';
import 'package:timecountdown/Providers/EditCountDownProvider.dart';
import 'package:timecountdown/Providers/PremiumProvider.dart';
import 'package:timecountdown/Providers/RenderedWidgetProvider.dart';
import 'package:timecountdown/Providers/UserProvider.dart';
import 'package:timecountdown/Pages/PremiumPage/PremiumPage.dart';

import 'package:timecountdown/main.dart';

class BottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final widgetStateProvider =
        Provider.of<RenderedWidgetProvider>(context, listen: false);

    final editCountDownProvider =
        Provider.of<Editcountdownprovider>(context, listen: false);

    final userProvider = context.watch<UserProvider>();
    final premiumProvider = context.watch<PremiumProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withValues(alpha: 0.6),
            Colors.black.withValues(alpha: 0.8),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color.fromARGB(255, 252, 6, 252).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          BottomBarItemComponent(
            context,
            Icons.view_carousel_rounded,
            "Template",
            "template",
            () {
              widgetStateProvider.renderedWidget = "template";
            },
            iconSize: 28.0,
          ),
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 180, minWidth: 140),
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 252, 6, 252),
                    Color.fromARGB(255, 255, 0, 119),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 252, 6, 252)
                        .withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.transparent),
                  shadowColor:
                      MaterialStateProperty.all<Color>(Colors.transparent),
                  padding: MaterialStateProperty.all<EdgeInsets>(
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
                onPressed: () async {
                  // Check if template is premium and user has access
                  List<String> proTemplates = [
                    'template_7',
                    'template_8',
                    'template_9'
                  ];
                  if (proTemplates.contains(widgetStateProvider.templateId)) {
                    bool hasAccess = premiumProvider.isPremium;
                    if (!hasAccess) {
                      // Show premium dialog with options to purchase or switch template
                      _showPremiumSaveDialog(context, widgetStateProvider,
                          editCountDownProvider, userProvider);
                      return;
                    }
                  }

                  // Proceed with saving
                  _saveCountdown(context, widgetStateProvider,
                      editCountDownProvider, userProvider);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          BottomBarItemComponent(
            context,
            Icons.tune_rounded,
            'Settings',
            'settings',
            () {
              widgetStateProvider.renderedWidget = "settings";
            },
            iconSize: 28.0,
          ),
        ],
      ),
    );
  }

  void _showPremiumSaveDialog(
      BuildContext context,
      RenderedWidgetProvider widgetStateProvider,
      Editcountdownprovider editCountDownProvider,
      UserProvider userProvider) {
    Map<String, String> templateNames = {
      'template_7': 'Heart Animation Template',
      'template_8': 'Love Theme Template',
      'template_9': 'Money Countdown Template'
    };
    String templateName = templateNames[widgetStateProvider.templateId] ??
        widgetStateProvider.templateId;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          title: const Text(
            'Premium Template Selected',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You\'ve selected "$templateName", which is a premium template.',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                'Choose one of the following options:',
                // ignore: deprecated_member_use
                style: TextStyle(color: Colors.white.withOpacity(0.8)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Switch to template selector to choose a free template
                widgetStateProvider.renderedWidget = "template";
              },
              child: Text(
                'Change Template',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PremiumPage()),
                );
              },
              child: const Text(
                'Get Premium',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _saveCountdown(
      BuildContext context,
      RenderedWidgetProvider widgetStateProvider,
      Editcountdownprovider editCountDownProvider,
      UserProvider userProvider) async {
    try {
      // Ensure we have a valid image path
      String imagePath = widgetStateProvider.image;
      if (imagePath.isEmpty) {
        imagePath = 'assets/Images/image1.jpg';
      }

      // When editing, use the ID from editCountDownProvider
      // When creating new, use empty string to force generation of new ID
      String countdownId = editCountDownProvider.isEditCountDown
          ? editCountDownProvider.currentCountDownId
          : ''; // Empty string forces new ID generation in saveCountDownData

      CountDownData countDownData = CountDownData(
        countDownId: countdownId,
        countDownTempId: widgetStateProvider.templateId,
        countDownTitle: widgetStateProvider.countDownTitle,
        countDownTargetDate: widgetStateProvider.selectedDate,
        countDownDim: widgetStateProvider.dimCount,
        countDownCreatedDate: editCountDownProvider.isEditCountDown
            ? editCountDownProvider.currentCreatedDate
            : DateTime.now(),
        countDownImage: imagePath,
      );

      print(
          'Saving countdown - isEdit: ${editCountDownProvider.isEditCountDown}, ID: $countdownId');

      if (editCountDownProvider.isEditCountDown) {
        await LocalStorageService.updateCountDownData(countDownData);
      } else {
        await LocalStorageService.saveCountDownData(countDownData);

        // Ensure user data is available before updating countdown count
        if (userProvider.userData != null) {
          await LocalStorageService.updateCountdownCount(
              userProvider.userData!.countdownCount + 1);
        } else {
          // Initialize user data if not available
          await LocalStorageService.initializeUserData();
          final userData = await LocalStorageService.getCurrentUserData();
          if (userData != null) {
            await LocalStorageService.updateCountdownCount(
                userData.countdownCount + 1);
          }
        }
        context.read<UserProvider>().fetchUserData();
      }

      widgetStateProvider.isLoading = false;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MyApp(),
        ),
      );
    } catch (e) {
      // Handle any errors during save
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving countdown: $e')),
      );
    }
  }
}
