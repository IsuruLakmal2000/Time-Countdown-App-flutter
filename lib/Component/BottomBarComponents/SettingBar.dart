import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:timecountdown/Component/BottomBarComponents/ReminderSettingSheet.dart';
import 'package:timecountdown/Component/BottomBarItemComponent.dart';
import 'package:timecountdown/Providers/RenderedWidgetProvider.dart';

class SettingsBar extends StatelessWidget {
  SettingsBar({
    Key? key,
  });

  @override
  Widget build(BuildContext context) {
    final widgetStateProvider =
        Provider.of<RenderedWidgetProvider>(context, listen: false);

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
                  context,
                  Icons.light_mode_sharp,
                  'Dark',
                  "dim",
                  () {
                    widgetStateProvider.renderedWidget = "dim";
                  },
                ),
                BottomBarItemComponent(
                  context,
                  Icons.add_photo_alternate,
                  'Background',
                  "background",
                  () async {
                    SaveImageOnLocalAndFirebase();
                  },
                ),
                BottomBarItemComponent(
                  context,
                  Icons.alarm,
                  'Reminder',
                  "reminder",
                  () async {
                    // showModalBottomSheet(
                    //     context: context,
                    //     builder: (context) {
                    //       return ReminderSettingSheet();
                    //     });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Reminder feature available soon in next update :)'),
                        duration: Duration(
                            seconds:
                                2), // Duration for which the Snackbar will be displayed
                      ),
                    );
                  },
                ),
                // Add more BottomBarItemComponent instances as needed
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
