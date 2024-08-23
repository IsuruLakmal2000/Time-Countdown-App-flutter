import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timecountdown/Component/CountdownCards/CardTemplates/Template1.dart';
import 'package:timecountdown/Component/CountdownCards/CardTemplates/Template2.dart';
import 'package:timecountdown/Component/CountdownCards/CardTemplates/Template3.dart';
import 'package:timecountdown/Component/CountdownCards/CardTemplates/Template4.dart';
import 'package:timecountdown/Model/TemplateData.dart';
import 'package:timecountdown/Providers/RenderedWidgetProvider.dart';

Widget ShowSelectedTemplate(
  BuildContext context,
) {
  final widgetStateProvider =
      Provider.of<RenderedWidgetProvider>(context, listen: false);

  switch (widgetStateProvider.templateId) {
    case 'template_1':
      return Template1(
        image: widgetStateProvider.image,
        dimCount: widgetStateProvider.dimCount,
        countDownTitle: widgetStateProvider.countDownTitle,
        templateDateTime: widgetStateProvider.selectedDate,
      );
    case "template_2":
      return Template2(
        image: widgetStateProvider.image,
        dimCount: widgetStateProvider.dimCount,
        countDownTitle: widgetStateProvider.countDownTitle,
        templateDateTime: widgetStateProvider.selectedDate,
      );

    case "template_3":
      return Template3(
        image: widgetStateProvider.image,
        dimCount: widgetStateProvider.dimCount,
        countDownTitle: widgetStateProvider.countDownTitle,
        templateDateTime: widgetStateProvider.selectedDate,
      );
    case "template_4":
      return Template4(
        image: widgetStateProvider.image,
        dimCount: widgetStateProvider.dimCount,
        countDownTitle: widgetStateProvider.countDownTitle,
        templateDateTime: widgetStateProvider.selectedDate,
      );

    default:
      return Template1(
        image: widgetStateProvider.image,
        dimCount: widgetStateProvider.dimCount,
        countDownTitle: widgetStateProvider.countDownTitle,
        templateDateTime: widgetStateProvider.selectedDate,
      );
  }
}
