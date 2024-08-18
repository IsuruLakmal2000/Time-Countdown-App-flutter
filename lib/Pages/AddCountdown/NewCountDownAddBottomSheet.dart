// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:timecountdown/Component/ButtonComponent.dart';
import 'package:timecountdown/Component/TextFieldComponent.dart';
import 'package:timecountdown/Model/TemplateData.dart';
import 'package:timecountdown/Pages/CountdownCardTemplate.dart';
import 'package:timecountdown/Pages/TemplateSelectEditPage.dart';

class NewcountdownAddBottomSheet extends StatefulWidget {
  NewcountdownAddBottomSheet({super.key});

  @override
  State<NewcountdownAddBottomSheet> createState() =>
      _NewcountdownAddBottomSheetState();
}

class _NewcountdownAddBottomSheetState
    extends State<NewcountdownAddBottomSheet> {
  String _textFieldValue = '';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime = const TimeOfDay(hour: 0, minute: 0);

  @override
  Widget build(BuildContext context) {
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
              DateTime _selectedDateTime = DateTime(
                _selectedDate!.year,
                _selectedDate!.month,
                _selectedDate!.day,
                _selectedTime!.hour,
                _selectedTime!.minute,
              );

              TemplateData templateData = TemplateData(
                templateId: 'template_1',
                title: _textFieldValue,
                createdDate: DateTime.now(),
              );

              print("--------" + _selectedDateTime.toString());
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TemplateSelectEditPage(
                    templateData: templateData,
                    templateDateTime: _selectedDateTime,
                  ), // Replace with your new page
                ),
              );
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
