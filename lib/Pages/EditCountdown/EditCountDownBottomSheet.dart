// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timecountdown/Component/AlertPopupComponent.dart';
import 'package:timecountdown/Component/ButtonComponent.dart';
import 'package:timecountdown/Component/TextFieldComponent.dart';
import 'package:timecountdown/Pages/MainPages/TemplateSelectEditPage.dart';
import 'package:timecountdown/Providers/EditCountDownProvider.dart';
import 'package:timecountdown/Providers/RenderedWidgetProvider.dart';

class EditCountDownBottomSheet extends StatefulWidget {
  EditCountDownBottomSheet({
    required this.initialTitle,
    required this.initialDate,
    super.key,
  });
  final String initialTitle;
  final DateTime? initialDate;

  @override
  State<EditCountDownBottomSheet> createState() =>
      _EditCountDownBottomSheetState();
}

class _EditCountDownBottomSheetState extends State<EditCountDownBottomSheet> {
  String _textFieldValue = '';

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime = const TimeOfDay(hour: 0, minute: 0);
  final FocusNode _textFieldFocusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    setState(() {
      _textFieldValue = widget.initialTitle;
      _selectedDate = widget.initialDate; // Set the selected date
      _selectedTime =
          TimeOfDay.fromDateTime(widget.initialDate!); // Set the selected time
    });
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
    final editCountDownProvider =
        Provider.of<Editcountdownprovider>(context, listen: false);

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
        widgetStateProvider.image = editCountDownProvider.currentImage;
        widgetStateProvider.dimCount = editCountDownProvider.currentDim;
        widgetStateProvider.templateId =
            editCountDownProvider.currentCountDownTempId;
        widgetStateProvider.countDownId =
            editCountDownProvider.currentCountDownId;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                TemplateSelectEditPage(), // Replace with your new page
          ),
        );
      }
    }

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            // Drag handle indicator
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Color.fromARGB(255, 252, 6, 252),
                  Color.fromARGB(255, 255, 0, 119),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: const Text(
                'Edit Countdown',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Textfieldcomponent(
                focusNode: _textFieldFocusNode,
                initialValue: widget.initialTitle,
                hintText: "Enter Title",
                maxLength: 30,
                onTextChanged: (Text) {
                  setState(() {
                    _textFieldValue = Text;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(255, 252, 6, 252).withValues(alpha: 0.1),
                  const Color.fromARGB(255, 255, 0, 119).withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color.fromARGB(255, 252, 6, 252).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Date',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedDate == null
                            ? 'No Date Chosen'
                            : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                        style: TextStyle(
                          color: _selectedDate == null
                              ? Colors.red.shade400
                              : const Color.fromARGB(255, 252, 6, 252),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 252, 6, 252),
                        Color.fromARGB(255, 255, 0, 119),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () {
                      _presentDatePicker();
                    },
                    icon: const Icon(
                      Icons.calendar_today_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(255, 252, 6, 252).withValues(alpha: 0.1),
                  const Color.fromARGB(255, 255, 0, 119).withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color.fromARGB(255, 252, 6, 252).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Time',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedTime == null
                            ? 'No Time Chosen'
                            : '${_selectedTime!.format(context)}',
                        style: TextStyle(
                          color: _selectedTime == TimeOfDay(hour: 0, minute: 0)
                              ? Colors.grey.shade400
                              : const Color.fromARGB(255, 255, 0, 119),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 252, 6, 252),
                        Color.fromARGB(255, 255, 0, 119),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () {
                      _presentTimePicker();
                    },
                    icon: const Icon(
                      Icons.access_time_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
            const SizedBox(height: 20),
            Buttoncomponent(
              onPressed: () {
                //set date and time as one
                _SaveDateTimeTitle();
              },
              buttonText: "Next",
            ),
          ],
        ),
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
