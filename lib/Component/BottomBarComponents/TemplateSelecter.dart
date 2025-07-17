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
                    // Allow selection of all templates - premium check will happen at save time
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
            onPressed: () async {
              // Allow selection of any template - premium check will happen at save time
              widgetStateProvider.renderedWidget = "none";
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
