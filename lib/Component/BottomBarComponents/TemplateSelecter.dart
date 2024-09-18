import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timecountdown/Component/TemplateSelectBarItem.dart';
import 'package:timecountdown/Providers/RenderedWidgetProvider.dart';

class TemplateSelector extends StatelessWidget {
  TemplateSelector({
    Key? key,
  });

  @override
  Widget build(BuildContext context) {
    final widgetStateProvider =
        Provider.of<RenderedWidgetProvider>(context, listen: false);

    bool checkProTemplate(String templateId) {
      if (templateId == 'template_5' ||
          templateId == 'template_6' ||
          templateId == 'template_7' ||
          templateId == 'template_8' ||
          templateId == 'template_9' ||
          templateId == 'template_10') {
        print('user selected pro template - ' + templateId);
        //then check user buy the pro version or not
        return true;
      } else {
        widgetStateProvider.templateId = templateId;
        return false;
      }
    }

    final List<Map<String, dynamic>> templates = [
      {
        'icon': Icons.local_attraction_sharp,
        'id': 'template_1',
        'label': 'Template 1',
        'isPro': false,
      },
      {
        'icon': Icons.local_offer,
        'id': 'template_2',
        'label': 'Template 2',
        'isPro': false,
      },
      {
        'icon': Icons.favorite,
        'id': 'template_3',
        'label': 'Template 3',
        'isPro': false,
      },
      {
        'icon': Icons.star,
        'id': 'template_4',
        'label': 'Template 4',
        'isPro': false,
      },
      {
        'icon': Icons.home,
        'id': 'template_5',
        'label': 'Template 5',
        'isPro': true,
      },
      {
        'icon': Icons.home,
        'id': 'template_6',
        'label': 'Template 6',
        'isPro': true,
      },
      {
        'icon': Icons.home,
        'id': 'template_7',
        'label': 'Template 7',
        'isPro': true,
      },
      {
        'icon': Icons.home,
        'id': 'template_8',
        'label': 'Template 8',
        'isPro': true,
      },
      {
        'icon': Icons.home,
        'id': 'template_9',
        'label': 'Template 9',
        'isPro': true,
      },
      {
        'icon': Icons.home,
        'id': 'template_10',
        'label': 'Template 10',
        'isPro': true,
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: templates.map((template) {
                return TemplateSelectBarItem(
                  context,
                  Icons.local_attraction_sharp,
                  template['label'],
                  template['id'],
                  () {
                    widgetStateProvider.templateId = template['id'];
                  },
                  template['isPro'],
                );
              }).toList(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: IconButton(
            onPressed: () {
              if (checkProTemplate(widgetStateProvider.templateId)) {
                // Show pro version dialog
                print('To use, you should buy the pro version');
                widgetStateProvider.renderedWidget = "none";
              } else {
                widgetStateProvider.renderedWidget = "none";
              }
            },
            icon: const Icon(
              Icons.check,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
