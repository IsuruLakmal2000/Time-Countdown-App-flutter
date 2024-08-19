import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timecountdown/Component/CountdownCards/CardTemplates/Template1.dart';
import 'package:timecountdown/Model/TemplateData.dart';
import 'package:timecountdown/Pages/AddCountdown/RenderedWidget.dart';
import 'package:timecountdown/Pages/CountdownCardTemplate.dart';
import 'package:timecountdown/Providers/RenderedWidgetProvider.dart';

class TemplateSelectEditPage extends StatefulWidget {
  TemplateSelectEditPage({
    super.key,
    required this.templateData,
    required this.templateDateTime,
  });
  TemplateData templateData;
  DateTime? templateDateTime;
  @override
  State<TemplateSelectEditPage> createState() => _TemplateSelectEditPageState();
}

class _TemplateSelectEditPageState extends State<TemplateSelectEditPage> {
  // String renderedWidget = "none";
  // double dimCount = 0.8;

  @override
  Widget build(BuildContext context) {
    final widgetStateProvider = Provider.of<RenderedWidgetProvider>(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          'Edit Template',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          Template1(
            dimCount: widgetStateProvider.dimCount,
            templateData: widget.templateData,
            templateDateTime: widget.templateDateTime,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Color.fromARGB(0, 0, 0, 0).withOpacity(0.6),
                  Color.fromARGB(0, 0, 0, 0).withOpacity(0.0),
                  Color.fromARGB(0, 0, 0, 0).withOpacity(0.0),
                  Color.fromARGB(0, 0, 0, 0).withOpacity(0.0),
                  Color.fromARGB(0, 0, 0, 0).withOpacity(0.0),
                ],
              ),
            ),
            alignment: Alignment.bottomCenter,
            child: renderWidget(context),
          ),
        ],
      ),
    );
  }
}
