import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timecountdown/Component/CountdownCards/CardTemplates/Template1.dart';
import 'package:timecountdown/Component/CountdownCards/CardTemplates/Template2.dart';
import 'package:timecountdown/Component/CountdownCards/CardTemplates/Template3.dart';
import 'package:timecountdown/Component/CountdownCards/CardTemplates/Template4.dart';
import 'package:timecountdown/Component/CountdownCards/CardTemplates/Template7.dart';
import 'package:timecountdown/Component/CountdownCards/CardTemplates/Template8.dart';
import 'package:timecountdown/Component/CountdownCards/CardTemplates/Template9.dart';
import 'package:timecountdown/Providers/RenderedWidgetProvider.dart';

Widget ShowSelectedTemplate(
  BuildContext context,
) {
  final widgetStateProvider =
      Provider.of<RenderedWidgetProvider>(context, listen: false);

  switch (widgetStateProvider.templateId) {
    case 'template_1':
      return Template1(
        createdDate: widgetStateProvider.countDownCreatedDate,
        image: widgetStateProvider.image,
        dimCount: widgetStateProvider.dimCount,
        countDownTitle: widgetStateProvider.countDownTitle,
        templateDateTime: widgetStateProvider.selectedDate,
      );
    case "template_2":
      return Template2(
        createdDate: widgetStateProvider.countDownCreatedDate,
        image: widgetStateProvider.image,
        dimCount: widgetStateProvider.dimCount,
        countDownTitle: widgetStateProvider.countDownTitle,
        templateDateTime: widgetStateProvider.selectedDate,
      );

    case "template_3":
      return Template3(
        createdDate: widgetStateProvider.countDownCreatedDate,
        image: widgetStateProvider.image,
        dimCount: widgetStateProvider.dimCount,
        countDownTitle: widgetStateProvider.countDownTitle,
        templateDateTime: widgetStateProvider.selectedDate,
      );
    case "template_4":
      return Template4(
        createdDate: widgetStateProvider.countDownCreatedDate,
        image: widgetStateProvider.image,
        dimCount: widgetStateProvider.dimCount,
        countDownTitle: widgetStateProvider.countDownTitle,
        templateDateTime: widgetStateProvider.selectedDate,
      );

    case "template_7":
      return Template7(
        createdDate: widgetStateProvider.countDownCreatedDate,
        image: widgetStateProvider.image,
        dimCount: widgetStateProvider.dimCount,
        countDownTitle: widgetStateProvider.countDownTitle,
        templateDateTime: widgetStateProvider.selectedDate,
      );

    case "template_8":
      return Template8(
        createdDate: widgetStateProvider.countDownCreatedDate,
        image: widgetStateProvider.image,
        dimCount: widgetStateProvider.dimCount,
        countDownTitle: widgetStateProvider.countDownTitle,
        templateDateTime: widgetStateProvider.selectedDate,
      );

    case "template_9":
      return Template9(
        createdDate: widgetStateProvider.countDownCreatedDate,
        image: widgetStateProvider.image,
        dimCount: widgetStateProvider.dimCount,
        countDownTitle: widgetStateProvider.countDownTitle,
        templateDateTime: widgetStateProvider.selectedDate,
      );

    case "template_5":
    case "template_6":
    case "template_10":
    default:
      // Fallback to Template1 for removed templates or invalid template types
      return Template1(
        createdDate: widgetStateProvider.countDownCreatedDate,
        image: widgetStateProvider.image,
        dimCount: widgetStateProvider.dimCount,
        countDownTitle: widgetStateProvider.countDownTitle,
        templateDateTime: widgetStateProvider.selectedDate,
      );
  }
}
