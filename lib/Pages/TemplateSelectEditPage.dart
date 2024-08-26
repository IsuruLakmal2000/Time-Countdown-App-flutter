import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timecountdown/Pages/AddCountdown/RenderedWidget.dart';
import 'package:timecountdown/Pages/AddCountdown/ShowSelectedTemplate.dart';
import 'package:timecountdown/Providers/RenderedWidgetProvider.dart';

class TemplateSelectEditPage extends StatefulWidget {
  TemplateSelectEditPage({
    super.key,
  });

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
          ShowSelectedTemplate(context),
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
            child: BottomWidgetBar(context),
          ),
          if (widgetStateProvider.isLoading)
            Container(
              color: Color.fromARGB(97, 0, 0, 0),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Color.fromARGB(174, 26, 0, 0)),
                  backgroundColor: Color.fromARGB(230, 174, 2, 218),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
