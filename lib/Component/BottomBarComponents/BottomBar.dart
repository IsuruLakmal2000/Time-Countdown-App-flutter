import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timecountdown/Component/BottomBarItemComponent.dart';
import 'package:timecountdown/Services/LocalStorageService.dart';
import 'package:timecountdown/Model/CountDownData.dart';
import 'package:timecountdown/Providers/EditCountDownProvider.dart';
import 'package:timecountdown/Providers/RenderedWidgetProvider.dart';
import 'package:timecountdown/Providers/UserProvider.dart';
import 'package:timecountdown/main.dart';

class BottomBar extends StatelessWidget {


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
                  await LocalStorageService.updateCountdownCount(
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
