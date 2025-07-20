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

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        BottomBarItemComponent(
          context,
          Icons.local_attraction_sharp,
          "Template",
          "template",
          () {
            widgetStateProvider.renderedWidget = "template";
          },
          iconSize: 36.0,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 16),
          child: SizedBox(
            width: 200,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                padding: MaterialStateProperty.all<EdgeInsets>(
                  EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              ),
              onPressed: () async {
                // Check if template is premium and user has access
                List<String> proTemplates = ['template_7', 'template_8', 'template_9'];
                if (proTemplates.contains(widgetStateProvider.templateId)) {
                  bool hasAccess = premiumProvider.isPremium;
                  if (!hasAccess) {
                    // Show premium dialog with options to purchase or switch template
                    _showPremiumSaveDialog(context, widgetStateProvider, editCountDownProvider, userProvider);
                    return;
                  }
                }
                
                // Proceed with saving
                _saveCountdown(context, widgetStateProvider, editCountDownProvider, userProvider);
              },
              child: const Text(
                'Save', 
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
        BottomBarItemComponent(
          context,
          Icons.settings,
          'Settings',
          'settings',
          () {
            widgetStateProvider.renderedWidget = "settings";
          },
          iconSize: 36.0,
        ),
      ],
    );
  }

  void _showPremiumSaveDialog(BuildContext context, RenderedWidgetProvider widgetStateProvider, 
      Editcountdownprovider editCountDownProvider, UserProvider userProvider) {
    Map<String, String> templateNames = {
      'template_7': 'Heart Animation Template',
      'template_8': 'Love Theme Template', 
      'template_9': 'Money Countdown Template'
    };
    String templateName = templateNames[widgetStateProvider.templateId] ?? widgetStateProvider.templateId;
    
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

  void _saveCountdown(BuildContext context, RenderedWidgetProvider widgetStateProvider,
      Editcountdownprovider editCountDownProvider, UserProvider userProvider) async {
    try {
      // Ensure we have a valid image path
      String imagePath = widgetStateProvider.image;
      if (imagePath.isEmpty) {
        imagePath = 'assets/Images/office.jpg';
      }
      
      CountDownData countDownData = CountDownData(
        countDownId: widgetStateProvider.countDownId,
        countDownTempId: widgetStateProvider.templateId,
        countDownTitle: widgetStateProvider.countDownTitle,
        countDownTargetDate: widgetStateProvider.selectedDate,
        countDownDim: widgetStateProvider.dimCount,
        countDownCreatedDate: DateTime.now(),
        countDownImage: imagePath,
      );

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
            await LocalStorageService.updateCountdownCount(userData.countdownCount + 1);
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
