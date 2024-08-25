// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timecountdown/Component/AlertPopupComponent.dart';
import 'package:timecountdown/Component/ButtonComponent.dart';
import 'package:timecountdown/Component/TextFieldComponent.dart';
import 'package:timecountdown/Model/TemplateData.dart';
import 'package:timecountdown/Pages/CountdownCardTemplate.dart';
import 'package:timecountdown/Pages/TemplateSelectEditPage.dart';
import 'package:timecountdown/Providers/RenderedWidgetProvider.dart';

class EditCountDownBottomSheet extends StatefulWidget {
  EditCountDownBottomSheet({
    required this.initialTitle,
    required this.initialDate,
    required this.initialTime,
    super.key,
  });
  final String initialTitle;
  final DateTime? initialDate;
  final TimeOfDay? initialTime;

  @override
  State<EditCountDownBottomSheet> createState() =>
      _EditCountDownBottomSheetState();
}

class _EditCountDownBottomSheetState extends State<EditCountDownBottomSheet> {
  String _textFieldValue = '';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime = const TimeOfDay(hour: 0, minute: 0);

  @override
  Widget build(BuildContext context) {
    final widgetStateProvider =
        Provider.of<RenderedWidgetProvider>(context, listen: false);

    @override
    void initState() {
      super.initState();
      // setState(() {
      //   _textFieldValue = widget.initialTitle; // Set the initial title
      //   _selectedDate = widget.initialDate; // Set the initial date
      //   _selectedTime = widget.initialTime;
      // }); // Set the initial time
    }

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
      }
      if (_selectedDate == null) {
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
          Textfieldcomponent(
            initialValue: widget.initialTitle,
            hintText: "Enter Title",
            maxLength: 20,
            onTextChanged: (Text) {
              setState(() {
                _textFieldValue = Text;
              });
            },
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

  //show datepicker
  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Set initial date to today
      firstDate: DateTime(2000), // Set minimum selectable date
      lastDate: DateTime(2300), // Set maximum selectable date
    ).then((pickedDate) {
      // Check if a date was selected
      if (pickedDate == null) return;

      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  //show timepicker

  void _presentTimePicker() {
    showTimePicker(
      context: context,
      initialTime: _selectedTime ??
          const TimeOfDay(hour: 0, minute: 0), // Use current value or midnight
    ).then((pickedTime) {
      if (pickedTime == null) return;

      setState(() {
        _selectedTime = pickedTime;
      });
    });
  }
}
