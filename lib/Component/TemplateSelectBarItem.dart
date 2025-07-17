import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timecountdown/Providers/RenderedWidgetProvider.dart';

Widget TemplateSelectBarItem(BuildContext context, IconData icon, String title,
    String renderedWidgetName, Function onTap, bool isPro) {
  final widgetStateProvider =
      Provider.of<RenderedWidgetProvider>(context, listen: false);

  return InkWell(
    onTap: () async {
      // Allow selection of all templates - premium check will happen at save time
      onTap();
    },
    child: Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isPro 
                    ? Colors.amber.withOpacity(0.1)
                    : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isPro 
                    ? Border.all(color: Colors.amber.withOpacity(0.3), width: 1)
                    : null,
                ),
                child: Icon(
                  icon,
                  color: isPro 
                    ? Colors.amber
                    : Color.fromARGB(255, 184, 54, 244),
                  size: 40,
                ),
              ),
              if (isPro)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.amber, Colors.orange],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.3),
                          blurRadius: 4,
                          spreadRadius: 1,
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.workspace_premium,
                          color: Colors.white,
                          size: 10,
                        ),
                        SizedBox(width: 2),
                        Text(
                          'PRO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          Text(
            title,
            style: TextStyle(
              color: isPro ? Colors.amber : Colors.white,
              fontWeight: isPro ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    ),
  );
}
