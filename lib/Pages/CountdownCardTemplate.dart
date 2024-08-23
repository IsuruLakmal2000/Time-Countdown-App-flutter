import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timecountdown/Component/CountdownCards/CardTemplates/Template1.dart';
import 'package:timecountdown/Component/CountdownCards/CardTemplates/Template2.dart';
import 'package:timecountdown/Component/CountdownCards/CardTemplates/Template3.dart';
import 'package:timecountdown/Component/CountdownCards/CardTemplates/Template4.dart';
import 'package:timecountdown/FirebaseServices/FirebaseSerives.dart';
import 'package:timecountdown/Model/CountDownData.dart';
import 'package:timecountdown/Model/TemplateData.dart';
import 'package:timecountdown/Providers/RenderedWidgetProvider.dart';

// ignore: must_be_immutable
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

  @override
  void initState() {
    super.initState();
    // Fetch countdowns when the widget is initialized
    fetchCountdowns();
  }

  Future<void> fetchCountdowns() async {
    setState(() {
      isLoading = true;
    });
    countdowns = await getCountdowns();

    setState(() {
      isLoading = false;
    });
    // Use the countdowns list to update your UI or perform other operations
  }

//select date with picker--------------------------------------------

  @override
  Widget build(BuildContext context) {
    final widgetStateProvider =
        Provider.of<RenderedWidgetProvider>(context, listen: false);
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return countdowns.isEmpty
        ? Template1(
            //  index: index,.
            image: '',
            dimCount: 0.8,
            countDownTitle: 'No countdowns available',
            templateDateTime: DateTime.now(),
          )
        : PageView.builder(
            itemCount: countdowns.length,
            itemBuilder: (context, index) {
              final data = countdowns[index];
              switch (data.countDownTempId) {
                case 'template_1':
                  return Template1(
                    //  index: index,.
                    image: data.countDownImage,
                    dimCount: data.countDownDim,
                    countDownTitle: data.countDownTitle,
                    templateDateTime: data.countDownTargetDate,
                  );
                case 'template_2':
                  return Template2(
                    image: data.countDownImage?.toString() ?? '',
                    dimCount: data.countDownDim,
                    countDownTitle: data.countDownTitle,
                    templateDateTime: data.countDownTargetDate,
                  );
                case 'template_3':
                  return Template3(
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
