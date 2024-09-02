import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:provider/provider.dart';
import 'package:timecountdown/Component/BottomBarItemComponent.dart';
import 'package:timecountdown/Component/TemplateSelectBarItem.dart';
import 'package:timecountdown/FirebaseServices/FirebaseSerives.dart';
import 'package:timecountdown/Model/CountDownData.dart';
import 'package:timecountdown/Providers/EditCountDownProvider.dart';
import 'package:timecountdown/Providers/RenderedWidgetProvider.dart';
import 'package:timecountdown/Providers/UserProvider.dart';
import 'package:timecountdown/main.dart';
//import 'package:firebase_storage/firebase_storage.dart';

Widget BottomWidgetBar(BuildContext context) {
  final widgetStateProvider =
      Provider.of<RenderedWidgetProvider>(context, listen: false);
  final editCountDownProvider =
      Provider.of<Editcountdownprovider>(context, listen: false);
  final userProvider = context.watch<UserProvider>();
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
//save all template values and countdown data to loacal and firebase

  Future<void> SaveImageOnLocalAndFirebase() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      String fileName =
          DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';
      widgetStateProvider.isLoading = true;
      final directory = await getApplicationDocumentsDirectory();
      // Create a new file in the documents directory
      final File newImage = File('${directory.path}/$fileName');

      await File(pickedFile.path).copy(newImage.path);

      widgetStateProvider.image = newImage.path;
      widgetStateProvider.isLoading = false;

      print("image path: ${pickedFile.path}");
    }
    //save to firebase
  }

  switch (widgetStateProvider.renderedWidget) {
    //setting dim bottom bar -------------------------------------------------items -----------
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
                    widgetStateProvider.renderedWidget = "settings";
                  },
                  icon: const Icon(
                    Icons.check,
                    color: Colors.white,
                  )),
            ],
          ),
        ],
      );

    case 'settings':
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  BottomBarItemComponent(
                      context, Icons.light_mode_sharp, 'Dark', "dim", () {
                    widgetStateProvider.renderedWidget = "dim";
                  }),
                  BottomBarItemComponent(context, Icons.add_photo_alternate,
                      'Background', "background", () async {
                    SaveImageOnLocalAndFirebase();
                  }),
                  // Replace Container() with the desired widget for each template
                ],
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
                  return TemplateSelectBarItem(
                    context,
                    Icons.local_attraction_sharp,
                    template['label'],
                    template['id'],
                    () {
                      widgetStateProvider.templateId = template['id'];
                    },
                    template['isPro'],
                  ); // Replace Container() with the desired widget for each template
                }).toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: IconButton(
                onPressed: () {
                  if (checkProTemplate(widgetStateProvider.templateId)) {
                    //show pro version dialog
                    print('to use,you shoul buy pro version');
                    widgetStateProvider.renderedWidget = "none";
                  } else {
                    widgetStateProvider.renderedWidget = "none";
                  }

                  //  widgetStateProvider.renderedWidget = "none";
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
          BottomBarItemComponent(
              context, Icons.local_attraction_sharp, "template", "template",
              () {
            widgetStateProvider.renderedWidget = "template";
          }),
          Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 20),
            child: SizedBox(
              width: 200,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
                ),
                onPressed: () async {
                  widgetStateProvider.isLoading = true;
                  CountDownData countDownData = CountDownData(
                    countDownId: widgetStateProvider.countDownId,
                    countDownTempId: widgetStateProvider.templateId,
                    countDownTitle: widgetStateProvider.countDownTitle,
                    countDownTargetDate: widgetStateProvider.selectedDate,
                    countDownDim: widgetStateProvider.dimCount,
                    countDownCreatedDate: DateTime.now(),
                    countDownImage: widgetStateProvider.image,
                  );
                  if (editCountDownProvider.isEditCountDown) {
                    await updateCountDownData(countDownData);
                  } else {
                    await saveCountDownData(countDownData);
                    await updateCountdownCount(
                        userProvider.userData!.countdownCount + 1);
                    context.read<UserProvider>().fetchUserData();
                  }

                  widgetStateProvider.isLoading = false;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyApp(),
                    ),
                  );
                },
                child:
                    const Text('Save', style: TextStyle(color: Colors.black)),
              ),
            ),
          ),
          BottomBarItemComponent(
              context, Icons.settings, 'Settings', 'settings', () {
            widgetStateProvider.renderedWidget = "settings";
          }),
        ],
      );
    default:
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          BottomBarItemComponent(
              context, Icons.local_attraction_sharp, "Template", "template",
              () {
            widgetStateProvider.renderedWidget = "template";
          }),
          Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 20),
            child: SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Save',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ),
          BottomBarItemComponent(
              context, Icons.settings, 'Settings', 'settings', () {
            widgetStateProvider.renderedWidget = "settings";
          }),
        ],
      );
  }

  //check selected template is pro or not
}
