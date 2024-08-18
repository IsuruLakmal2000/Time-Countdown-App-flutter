import 'package:flutter/material.dart';
import 'package:timecountdown/Component/CountdownCards/CardTemplates/Template1.dart';

class TemplateSelectEditPage extends StatefulWidget {
  TemplateSelectEditPage({
    super.key,
    required this.templateData,
    required this.templateDateTime,
  });
  String templateData;
  DateTime? templateDateTime;
  @override
  State<TemplateSelectEditPage> createState() => _TemplateSelectEditPageState();
}

class _TemplateSelectEditPageState extends State<TemplateSelectEditPage> {
  @override
  Widget build(BuildContext context) {
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
            dimCount: 8,
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () => {
                    print('Template'),
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
                    print('Template'),
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
            ),
          ),
        ],
      ),
    );
  }
}
