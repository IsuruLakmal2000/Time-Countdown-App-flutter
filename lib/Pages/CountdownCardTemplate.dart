import 'package:flutter/material.dart';
import 'package:timecountdown/Component/CountdownCards/CardTemplates/Template1.dart';
import 'package:timecountdown/Model/TemplateData.dart';

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

//select date with picker--------------------------------------------

  @override
  Widget build(BuildContext context) {
    final List<TemplateData> templateData = [
      TemplateData(
          title: 'Template 1 Data',
          templateId: 'template_1',
          createdDate: DateTime.now()),
      TemplateData(
          title: 'Template 2 Data',
          templateId: 'template_2',
          createdDate: DateTime.now()),
    ];
    return PageView.builder(
      itemCount: templateData.length,
      itemBuilder: (context, index) {
        final data = templateData[index];
        switch (data.templateId) {
          case 'template_1':
            return Template1(
              //  index: index,
              dimCount: 0.8,
              templateData: data,
              templateDateTime: userDateTime,
            );
          case 'template_2':
            return Template1(
              //  index: index,
              dimCount: 0.8,
              templateData: data,
              templateDateTime: userDateTime,
            );
          case 'template_3':
            return Template1(
              //  index: index,
              dimCount: 0.8,
              templateData: data,
              templateDateTime: userDateTime,
            );
          default:
            throw Exception('Invalid template type');
        }
      },
    );
  }
}

enum TemplateType { template1, template2, template3 }
