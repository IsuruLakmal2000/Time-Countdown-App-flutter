import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timecountdown/Component/BottomBarItemComponent.dart';
import 'package:timecountdown/FirebaseServices/FirebaseSerives.dart';
import 'package:timecountdown/Mobile%20ads/InterstialAdService.dart';
import 'package:timecountdown/Model/CountDownData.dart';
import 'package:timecountdown/Providers/EditCountDownProvider.dart';
import 'package:timecountdown/Providers/RenderedWidgetProvider.dart';
import 'package:timecountdown/Providers/UserProvider.dart';
import 'package:timecountdown/main.dart';

class BottomBar extends StatelessWidget {
  final Interstialadservice interstitialAdService;

  BottomBar({
    required this.interstitialAdService,
  });

  @override
  Widget build(BuildContext context) {
    final widgetStateProvider =
        Provider.of<RenderedWidgetProvider>(context, listen: false);

    final editCountDownProvider =
        Provider.of<Editcountdownprovider>(context, listen: false);

    final userProvider = context.watch<UserProvider>();

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
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20.0, bottom: 20),
          child: SizedBox(
            width: 200,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
              onPressed: () async {
                widgetStateProvider.isLoading = true;
                CountDownData countDownData = CountDownData(
                  countDownId: widgetStateProvider.countDownId,
                  countDownTempId: widgetStateProvider.templateId,
                  countDownTitle: widgetStateProvider.countDownTitle,
                  countDownTargetDate: widgetStateProvider.selectedDate,
                  countDownDim: widgetStateProvider.dimCount,
                  countDownCreatedDate: DateTime.now(),
                  countDownImage: widgetStateProvider.image,
                );
                if (editCountDownProvider.isEditCountDown) {
                  await updateCountDownData(countDownData);
                } else {
                  await saveCountDownData(countDownData);
                  await updateCountdownCount(
                      userProvider.userData!.countdownCount + 1);
                  context.read<UserProvider>().fetchUserData();
                }

                widgetStateProvider.isLoading = false;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyApp(),
                  ),
                );
                Future.delayed(Duration(seconds: 2), () {
                  interstitialAdService.showAd();
                });
              },
              child: const Text('Save', style: TextStyle(color: Colors.black)),
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
        ),
      ],
    );
  }
}
