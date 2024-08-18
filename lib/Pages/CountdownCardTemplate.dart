import 'package:flutter/material.dart';
import 'package:timecountdown/Component/CountdownCards/CardTemplates/Template1.dart';

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
          title: 'Template 1 Data', templateType: TemplateType.template1),
      TemplateData(
          title: 'Template 2 Data', templateType: TemplateType.template2),
      TemplateData(
          title: 'Template 3 Data', templateType: TemplateType.template3),
    ];
    return PageView.builder(
      itemCount: templateData.length,
      itemBuilder: (context, index) {
        final data = templateData[index];
        switch (data.templateType) {
          case TemplateType.template1:
            return Template1(
              //  index: index,
              dimCount: 8,
              templateData: data.title,
              templateDateTime: userDateTime,
            );
          case TemplateType.template2:
            return Template1(
              //  index: index,
              dimCount: 8,
              templateData: data.title,
              templateDateTime: userDateTime,
            );
          case TemplateType.template3:
            return Template1(
              //  index: index,
              dimCount: 8,
              templateData: data.title,
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

class TemplateData {
  final String title;
  final TemplateType templateType;

  TemplateData({required this.title, required this.templateType});
}
