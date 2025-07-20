import 'package:flutter/material.dart';

Widget BottomBarItemComponent(BuildContext context, IconData icon, String title,
    String renderedWidgetName, Function onTap, {double iconSize = 32.0}) {
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
            size: iconSize,
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
