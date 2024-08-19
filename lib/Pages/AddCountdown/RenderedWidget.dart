import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timecountdown/Providers/RenderedWidgetProvider.dart';

Widget renderWidget(BuildContext context) {
  final List<Map<String, dynamic>> templates = [
    {
      'icon': Icons.local_attraction_sharp,
      'id': 'Template_1',
      'widget': 'template1_widget', // Replace with your actual widget name
    },
    {
      'icon': Icons.local_offer,
      'id': 'Template_2',
      'widget': 'template2_widget', // Replace with your actual widget name
    },
    {
      'icon': Icons.favorite,
      'id': 'Template_3',
      'widget': 'template3_widget', // Replace with your actual widget name
    },
    {
      'icon': Icons.star,
      'id': 'Template_4',
      'widget': 'template4_widget', // Replace with your actual widget name
    },
    {
      'icon': Icons.home,
      'id': 'Template_5',
      'widget': 'template5_widget', // Replace with your actual widget name
    },
  ];

  final widgetStateProvider =
      Provider.of<RenderedWidgetProvider>(context, listen: false);
  switch (widgetStateProvider.renderedWidget) {
    case 'dim':
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Slider(
                  value: widgetStateProvider.dimCount,
                  onChanged: (value) {
                    widgetStateProvider.dimCount = value;
                  },
                  min: 0,
                  max: 1,
                ),
              ),
              IconButton(
                  onPressed: () {
                    widgetStateProvider.renderedWidget = "none";
                  },
                  icon: const Icon(
                    Icons.check,
                    color: Colors.white,
                  )),
            ],
          ),
        ],
      );
    case 'template':
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: templates.map((template) {
                  return InkWell(
                    onTap: () => {
                      print('Template 1'),
                      widgetStateProvider.renderedWidget = 'none',
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.local_attraction_sharp,
                            color: Color.fromARGB(255, 184, 54, 244),
                          ),
                          Text(
                            'Template 1',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ); // Replace Container() with the desired widget for each template
                }).toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: IconButton(
                onPressed: () {
                  widgetStateProvider.renderedWidget = "none";
                },
                icon: Icon(
                  Icons.check,
                  color: Colors.white,
                )),
          ),
        ],
      );
    case 'none':
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          InkWell(
            onTap: () => {
              print('Template'),
              widgetStateProvider.renderedWidget = "template",
            },
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.local_attraction_sharp,
                    color: const Color.fromARGB(255, 184, 54, 244),
                  ),
                  Text(
                    'Template',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 20),
            child: SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ),
          ),
          InkWell(
            onTap: () => {
              print('dark'),
              widgetStateProvider.renderedWidget = "dim",
            },
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.light_mode_sharp,
                    color: const Color.fromARGB(255, 184, 54, 244),
                  ),
                  Text(
                    'Dark',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    default:
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          InkWell(
            onTap: () => {
              print('Template'),
              widgetStateProvider.renderedWidget = "template",
            },
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.local_attraction_sharp,
                    color: const Color.fromARGB(255, 184, 54, 244),
                  ),
                  Text(
                    'Template',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 20),
            child: SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ),
          ),
          InkWell(
            onTap: () => {
              print('dark'),
              widgetStateProvider.renderedWidget = "dim",
            },
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.light_mode_sharp,
                    color: const Color.fromARGB(255, 184, 54, 244),
                  ),
                  Text(
                    'Dark',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
  }
}
