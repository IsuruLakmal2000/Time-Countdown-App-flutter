import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timecountdown/Component/CountdownCards/CardTemplates/Template1.dart';
import 'package:timecountdown/Component/CountdownCards/CardTemplates/Template2.dart';
import 'package:timecountdown/Component/CountdownCards/CardTemplates/Template3.dart';
import 'package:timecountdown/Component/CountdownCards/CardTemplates/Template4.dart';
import 'package:timecountdown/FirebaseServices/FirebaseSerives.dart';
import 'package:timecountdown/Model/CountDownData.dart';
import 'package:timecountdown/Providers/RenderedWidgetProvider.dart';
import 'package:timecountdown/Providers/EditCountDownProvider.dart';

class CountDownCardTemplate extends StatefulWidget {
  const CountDownCardTemplate({
    super.key,
  });

  @override
  State<CountDownCardTemplate> createState() => _CountDownCardTemplateState();
}

class _CountDownCardTemplateState extends State<CountDownCardTemplate> {
  DateTime? userDateTime;
  List<CountDownData> countdowns = [];
  bool isLoading = false;
  PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    fetchCountdowns();
  }

  Future<void> fetchCountdowns() async {
    setState(() {
      isLoading = true;
    });
    countdowns = await getCountdowns();
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
    return countdowns.isEmpty
        ? Template1(
            //  index: index,.
            createdDate: DateTime.now(),
            image: '',
            dimCount: 0.8,
            countDownTitle: 'No countdowns available',
            templateDateTime: DateTime.now(),
          )
        : PageView.builder(
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
                    image: data.countDownImage,
                    dimCount: data.countDownDim,
                    countDownTitle: data.countDownTitle,
                    templateDateTime: data.countDownTargetDate,
                  );
                default:
                  throw Exception('Invalid template type');
              }
            },
          );
  }
}
