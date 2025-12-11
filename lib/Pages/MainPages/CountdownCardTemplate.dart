import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timecountdown/Component/CountdownCards/CardTemplates/Template1.dart';
import 'package:timecountdown/Component/CountdownCards/CardTemplates/Template2.dart';
import 'package:timecountdown/Component/CountdownCards/CardTemplates/Template3.dart';
import 'package:timecountdown/Component/CountdownCards/CardTemplates/Template4.dart';
import 'package:timecountdown/Component/CountdownCards/CardTemplates/Template7.dart';
import 'package:timecountdown/Component/CountdownCards/CardTemplates/Template8.dart';
import 'package:timecountdown/Component/CountdownCards/CardTemplates/Template9.dart';
import 'package:timecountdown/Component/PageIndicatorComponent.dart';
import 'package:timecountdown/Services/LocalStorageService.dart';
import 'package:timecountdown/Model/CountDownData.dart';
import 'package:timecountdown/Providers/EditCountDownProvider.dart';

class CountDownCardTemplate extends StatefulWidget {
  final VoidCallback? onDoubleTap;

  const CountDownCardTemplate({
    super.key,
    this.onDoubleTap,
  });

  @override
  State<CountDownCardTemplate> createState() => _CountDownCardTemplateState();
}

class _CountDownCardTemplateState extends State<CountDownCardTemplate> {
  DateTime? userDateTime;
  List<CountDownData> countdowns = [];
  bool isLoading = false;
  PageController _pageController = PageController();

  Future<void> showDeleteConfirmationDialog(
      BuildContext context, String countdownId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content:
              const Text('Are you sure you want to delete this countdown?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                // Call the delete function here

                LocalStorageService.deleteCountdown(countdownId, context);
                setState(() {});
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchCountdowns();
  }

  Future<void> fetchCountdowns() async {
    setState(() {
      isLoading = true;
    });

    countdowns = await LocalStorageService.getCountdowns();
    if (countdowns.isNotEmpty) {
      final editCountDownProvider =
          Provider.of<Editcountdownprovider>(context, listen: false);

      editCountDownProvider.currentPage = 0; // Set initial page
      editCountDownProvider.currentTitle = countdowns[0].countDownTitle;
      editCountDownProvider.currentDate = countdowns[0].countDownTargetDate;
      editCountDownProvider.currentImage = countdowns[0].countDownImage;
      editCountDownProvider.currentDim = countdowns[0].countDownDim;
      editCountDownProvider.currentCountDownId = countdowns[0].countDownId;
      editCountDownProvider.currentCountDownTempId =
          countdowns[0].countDownTempId;
    }

    setState(() {
      isLoading = false;
    });
  }

  void setVlaues(int index) {}

  @override
  Widget build(BuildContext context) {
    final editCountDownProvider =
        Provider.of<Editcountdownprovider>(context, listen: false);
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (countdowns.isEmpty) {
      return Template1(
        //  index: index,.
        createdDate: DateTime.now(),
        image: 'assets/Images/image1.jpg',
        dimCount: 0.8,
        countDownTitle: 'No countdowns available',
        templateDateTime: DateTime.now(),
      );
    }

    return Stack(
      children: [
        GestureDetector(
          onDoubleTap: widget.onDoubleTap,
          child: PageView.builder(
            controller: _pageController,
            itemCount: countdowns.length,
            onPageChanged: (index) {
              setState(
                () {
                  editCountDownProvider.currentPage = index;
                  editCountDownProvider.currentTitle =
                      countdowns[index].countDownTitle;
                  editCountDownProvider.currentDate =
                      countdowns[index].countDownTargetDate;
                  editCountDownProvider.currentImage =
                      countdowns[index].countDownImage;
                  editCountDownProvider.currentDim =
                      countdowns[index].countDownDim;
                  editCountDownProvider.currentCountDownId =
                      countdowns[index].countDownId;
                  editCountDownProvider.currentCountDownTempId =
                      countdowns[index].countDownTempId;
                },
              );
            },
            itemBuilder: (context, index) {
              final data = countdowns[index];

              switch (data.countDownTempId) {
                case 'template_1':
                  return Template1(
                    //  index: index,.
                    createdDate: data.countDownCreatedDate,
                    image: data.countDownImage,
                    dimCount: data.countDownDim,
                    countDownTitle: data.countDownTitle,
                    templateDateTime: data.countDownTargetDate,
                  );
                case 'template_2':
                  return Template2(
                    createdDate: data.countDownCreatedDate,
                    image: data.countDownImage,
                    dimCount: data.countDownDim,
                    countDownTitle: data.countDownTitle,
                    templateDateTime: data.countDownTargetDate,
                  );
                case 'template_3':
                  return Template3(
                    createdDate: data.countDownCreatedDate,
                    image: data.countDownImage,
                    dimCount: data.countDownDim,
                    countDownTitle: data.countDownTitle,
                    templateDateTime: data.countDownTargetDate,
                  );
                case 'template_4':
                  return Template4(
                    createdDate: data.countDownCreatedDate,
                    image: data.countDownImage,
                    dimCount: data.countDownDim,
                    countDownTitle: data.countDownTitle,
                    templateDateTime: data.countDownTargetDate,
                  );
                case 'template_7':
                  return Template7(
                    createdDate: data.countDownCreatedDate,
                    image: data.countDownImage,
                    dimCount: data.countDownDim,
                    countDownTitle: data.countDownTitle,
                    templateDateTime: data.countDownTargetDate,
                  );
                case 'template_8':
                  return Template8(
                    createdDate: data.countDownCreatedDate,
                    image: data.countDownImage,
                    dimCount: data.countDownDim,
                    countDownTitle: data.countDownTitle,
                    templateDateTime: data.countDownTargetDate,
                  );
                case 'template_9':
                  return Template9(
                    createdDate: data.countDownCreatedDate,
                    image: data.countDownImage,
                    dimCount: data.countDownDim,
                    countDownTitle: data.countDownTitle,
                    templateDateTime: data.countDownTargetDate,
                  );
                case 'template_5':
                case 'template_6':
                case 'template_10':
                default:
                  // Fallback to Template1 for removed templates or invalid template types
                  return Template1(
                    createdDate: data.countDownCreatedDate,
                    image: data.countDownImage,
                    dimCount: data.countDownDim,
                    countDownTitle: data.countDownTitle,
                    templateDateTime: data.countDownTargetDate,
                  );
              }
            },
          ),
        ),
        // Page indicator positioned at the bottom
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Center(
            child: PageIndicatorComponent(
              currentPage: editCountDownProvider.currentPage,
              itemCount: countdowns.length,
              activeColor: Colors.white,
              inactiveColor: Colors.white.withOpacity(0.4),
              dotSize: 10.0,
              spacing: 12.0,
            ),
          ),
        ),
      ],
    );
  }
}
