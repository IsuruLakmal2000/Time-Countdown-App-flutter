import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timecountdown/Providers/RenderedWidgetProvider.dart';

Widget TemplateSelectBarItem(BuildContext context, IconData icon, String title,
    String renderedWidgetName, Function onTap, bool isPro) {
  final widgetStateProvider =
      Provider.of<RenderedWidgetProvider>(context, listen: false);

  return InkWell(
    onTap: () async {
      onTap();
      // widgetStateProvider.renderedWidget = renderedWidgetName,
    },
    child: Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Stack(
            alignment: Alignment.topCenter,
            children: [
              Icon(
                icon,
                color: Color.fromARGB(255, 184, 54, 244),
                size: 40, // Adjust size as needed
              ),
              if (isPro)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 20,
                      minHeight: 8,
                    ),
                    child: Text(
                      'Pro',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    ),
  );
}
