import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:timecountdown/Providers/RenderedWidgetProvider.dart';

Widget BottomBarItemComponent(BuildContext context, IconData icon, String title,
    String renderedWidgetName, Function onTap) {
  final widgetStateProvider =
      Provider.of<RenderedWidgetProvider>(context, listen: false);
  return InkWell(
    onTap: () async {
      onTap();

      // widgetStateProvider.renderedWidget = renderedWidgetName,
    },
    child: Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            icon,
            color: Color.fromARGB(255, 184, 54, 244),
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
