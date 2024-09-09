// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timecountdown/Component/AlertPopupComponent.dart';
import 'package:timecountdown/Component/ButtonComponent.dart';
import 'package:timecountdown/Component/TextFieldComponent.dart';
import 'package:timecountdown/Mobile%20ads/InterstialAdService.dart';
import 'package:timecountdown/Model/TemplateData.dart';
import 'package:timecountdown/Pages/CountdownCardTemplate.dart';
import 'package:timecountdown/Pages/TemplateSelectEditPage.dart';
import 'package:timecountdown/Providers/RenderedWidgetProvider.dart';

class NewcountdownAddBottomSheet extends StatefulWidget {
  NewcountdownAddBottomSheet({
    super.key,
  });

  @override
  State<NewcountdownAddBottomSheet> createState() =>
      _NewcountdownAddBottomSheetState();
}

class _NewcountdownAddBottomSheetState
    extends State<NewcountdownAddBottomSheet> {
  String _textFieldValue = '';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime = const TimeOfDay(hour: 0, minute: 0);
  final FocusNode _textFieldFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final widgetStateProvider =
        Provider.of<RenderedWidgetProvider>(context, listen: false);

    void _SaveDateTimeTitle() {
      if (_textFieldValue.isEmpty) {
        print('Please enter a title');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertPopupComponent(
              context: context,
              title: 'Error',
              message: 'Please enter a title',
              onOkPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            );
          },
        );
      } else if (_selectedDate == null) {
        print('Please select a date');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertPopupComponent(
              context: context,
              title: 'Error',
              message: 'Please select a date',
              onOkPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            );
          },
        );
      } else {
        widgetStateProvider.selectedDate = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );
        widgetStateProvider.countDownTitle = _textFieldValue;
        print("--------" + widgetStateProvider.selectedDate.toString());
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                TemplateSelectEditPage(), // Replace with your new page
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          const Text(
            'New Countdown',
            style: TextStyle(
              color: Color.fromARGB(255, 253, 253, 253),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Textfieldcomponent(
              focusNode: _textFieldFocusNode,
              initialValue: null,
              hintText: "Enter Title",
              maxLength: 30,
              onTextChanged: (Text) {
                setState(() {
                  _textFieldValue = Text;
                });
              },
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Date : ' +
                    (_selectedDate == null
                        ? 'No Date Chosen'
                        : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
                style: TextStyle(
                  color: _selectedDate == null
                      ? Color.fromARGB(255, 190, 57, 57)
                      : Color.fromARGB(255, 61, 184, 37),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                width: 20,
              ),
              IconButton(
                onPressed: () {
                  _presentDatePicker();
                },
                icon: Icon(
                  Icons.calendar_today,
                  color: Color.fromARGB(255, 253, 253, 253),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Time : ' +
                    (_selectedTime == null
                        ? 'No Date Chosen'
                        : '${_selectedTime!.format(context)}'),
                style: TextStyle(
                  color: _selectedTime == TimeOfDay(hour: 0, minute: 0)
                      ? Color.fromARGB(255, 155, 155, 155)
                      : Color.fromARGB(255, 61, 184, 37),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                width: 20,
              ),
              IconButton(
                onPressed: () {
                  _presentTimePicker();
                },
                icon: Icon(
                  Icons.access_time,
                  color: Color.fromARGB(255, 253, 253, 253),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Buttoncomponent(
            onPressed: () {
              //set date and time as one
              _SaveDateTimeTitle();
            },
            buttonText: "Next",
          ),
        ],
      ),
    );
  }

  void _presentDatePicker() {
    FocusScope.of(context).requestFocus(FocusNode());
    showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(), // Set initial date to today
      firstDate: DateTime.now(), // Set minimum selectable date to today
      lastDate: DateTime(2300), // Set maximum selectable date
    ).then((pickedDate) {
      // Check if a date was selected
      if (pickedDate == null) return;

      // If the picked date is today, check if the selected time has already passed
      if (pickedDate.isAtSameMomentAs(DateTime.now())) {
        // If the picked date is today, we will check the time later when the time is picked
        // Allow the selection of today's date
      }

      setState(() {
        _selectedDate = pickedDate; // Update the selected date
      });
    });
  }

  //show timepicker

  void _presentTimePicker() {
    FocusScope.of(context).requestFocus(FocusNode());

    TimeOfDay initialTime;
    if (_selectedDate != null &&
        _selectedDate!.day == DateTime.now().day &&
        _selectedDate!.month == DateTime.now().month &&
        _selectedDate!.year == DateTime.now().year) {
      // If the selected date is today, set the initial time to the current time
      initialTime = TimeOfDay.now();
    } else {
      // If the selected date is not today, use the previously selected time or midnight
      initialTime = _selectedTime ?? const TimeOfDay(hour: 0, minute: 0);
    }

    showTimePicker(
      context: context,
      initialTime: initialTime,
    ).then((pickedTime) {
      if (pickedTime == null) return;

      // If the picked date is today, check if the time has already passed
      if (_selectedDate != null &&
          _selectedDate!.day == DateTime.now().day &&
          _selectedDate!.month == DateTime.now().month &&
          _selectedDate!.year == DateTime.now().year) {
        if (pickedTime.hour < TimeOfDay.now().hour ||
            (pickedTime.hour == TimeOfDay.now().hour &&
                pickedTime.minute <= TimeOfDay.now().minute)) {
          // Time has already passed, show an error message or handle it as per your requirement
          print('Cannot select a time that has already passed today.');
          return;
        }
      }

      setState(() {
        _selectedTime = pickedTime; // Update the selected time
      });
    });
  }
}
