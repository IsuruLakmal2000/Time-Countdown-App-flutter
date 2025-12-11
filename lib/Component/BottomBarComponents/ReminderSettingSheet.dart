import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timecountdown/NotificationService/NotificationService.dart';
import 'package:timecountdown/Providers/RenderedWidgetProvider.dart';

class ReminderSettingSheet extends StatefulWidget {
  const ReminderSettingSheet({super.key});

  @override
  State<ReminderSettingSheet> createState() => _ReminderSettingSheetState();
}

bool isEnabledReminder = false;
bool isEnabledCustomReminder = false;
DateTime? remindedDate; // Variable to hold the selected date
TimeOfDay? remindedTime;

class _ReminderSettingSheetState extends State<ReminderSettingSheet> {
  String? selectedOption;

  @override
  Widget build(BuildContext context) {
    final widgetStateProvider =
        Provider.of<RenderedWidgetProvider>(context, listen: false);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Reminder',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Switch(
                    value: isEnabledReminder,
                    onChanged: (value) {
                      setState(() {
                        isEnabledReminder = value;
                      });
                    },
                  ),
                ],
              ),
              if (isEnabledReminder) ...[
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Countdown Setup date",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Text(
                        ' ${widgetStateProvider.selectedDate.day}/${widgetStateProvider.selectedDate.month}/${widgetStateProvider.selectedDate.year}-${widgetStateProvider.selectedDate.hour}H:${widgetStateProvider.selectedDate.minute}M',
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green)),
                  ],
                ),
                if (!isEnabledCustomReminder)
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          alignment: WrapAlignment.start,
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: [
                            selectableButton('15M Before', '15M'),
                            selectableButton('30M Before', '30M'),
                            selectableButton('1 Hr Before', '1H'),
                            selectableButton('6 Hr Before', '6H'),
                            selectableButton('1 Day Before', '1D'),
                          ],
                        ),
                        remindedDate != null
                            ? Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  'Reminded Time: ${remindedDate!.day}/${remindedDate!.month}/${remindedDate!.year} ${remindedDate!.hour}H:${remindedDate!.minute.toString().padLeft(2, '0')}M',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                Row(
                  // Custom reminder
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Want to setup Custom Reminder?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Switch(
                      value: isEnabledCustomReminder,
                      onChanged: (value) {
                        setState(() {
                          isEnabledCustomReminder = value;
                        });
                      },
                    ),
                  ],
                ),
                if (isEnabledCustomReminder)
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Reminder Time',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () async {
                                  DateTime? date = await showDatePicker(
                                    context: context,
                                    initialDate: remindedDate ?? DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101),
                                  );

                                  // If a date was selected, show the time picker
                                  if (date != null) {
                                    setState(() {
                                      remindedDate =
                                          date; // Update the selected date
                                    });

                                    // Show time picker
                                    TimeOfDay? time = await showTimePicker(
                                      context: context,
                                      initialTime:
                                          remindedTime ?? TimeOfDay.now(),
                                    );

                                    // If a time was selected, update the state
                                    if (time != null) {
                                      setState(() {
                                        remindedTime =
                                            time; // Update the selected time
                                      });
                                    }
                                  }
                                },
                                child: const Text(
                                  'Set Time',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            remindedDate != null
                                ? 'Selected Date: ${remindedDate!.day}/${remindedDate!.month}/${remindedDate!.year}'
                                : 'No Date Selected',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            remindedTime != null
                                ? 'Selected Time: ${remindedTime!.format(context)}'
                                : 'No Time Selected',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                    onPressed: () {
                      if (remindedDate != null) {
                        scheduleReminder(
                          id: widgetStateProvider.countDownId.hashCode,
                          title: 'Countdown Reminder',
                          body:
                              'Your countdown "${widgetStateProvider.countDownTitle}" is finished!',
                          scheduledDate: remindedDate!,
                        );
                      }

                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                )
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget selectableButton(String text, String ID) {
    return OutlinedButton(
      onPressed: () {
        setState(() {
          selectedOption = text;
          remindedDate =
              calculateReminderTime(ID); // Update the selected option
        });
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: selectedOption == text
            ? Colors.black // Set text color to white if selected
            : Colors.white,
        backgroundColor: selectedOption == text
            ? Colors.green // Set background color to green if selected
            : Colors
                .transparent, // Set background color to white if not selected
      ),
      child: Container(
        width: 100, // Reduced width to fit more items
        child: Center(
          child: Text(text,
              textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
        ),
      ),
    );
  }

  DateTime calculateReminderTime(String option) {
    final widgetStateProvider =
        Provider.of<RenderedWidgetProvider>(context, listen: false);
    Duration duration;
    switch (option) {
      case '15M':
        duration = Duration(minutes: 15);
        break;
      case '30M':
        duration = Duration(minutes: 30);
        break;
      case '1H':
        duration = Duration(hours: 1);
        break;
      case '6H':
        duration = Duration(hours: 6);
        break;
      case '1D':
        duration = Duration(days: 1);
        break;
      default:
        return DateTime.now();
    }

    // Calculate the reminder time by subtracting the duration from the target date
    DateTime reminderDateTime =
        widgetStateProvider.selectedDate.subtract(duration);
    return reminderDateTime;
  }
}
