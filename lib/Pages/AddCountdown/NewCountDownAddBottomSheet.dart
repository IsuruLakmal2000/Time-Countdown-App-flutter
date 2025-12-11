// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timecountdown/Component/AlertPopupComponent.dart';
import 'package:timecountdown/Component/ButtonComponent.dart';
import 'package:timecountdown/Component/TextFieldComponent.dart';
import 'package:timecountdown/Pages/MainPages/TemplateSelectEditPage.dart';
import 'package:timecountdown/Providers/RenderedWidgetProvider.dart';
import 'package:timecountdown/Theme/AppColors.dart';

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
        // Initialize with default image if no image is set
        if (widgetStateProvider.image.isEmpty) {
          widgetStateProvider.image = 'assets/Images/image1.jpg';
        }
        // Set default dimCount for new countdown
        if (widgetStateProvider.dimCount == 0.0) {
          widgetStateProvider.dimCount = 0.5;
        }
        print("--------" + widgetStateProvider.selectedDate.toString());
        print("DimCount set to: ${widgetStateProvider.dimCount}");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                TemplateSelectEditPage(), // Replace with your new page
          ),
        );
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle Bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'New Countdown',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Title Input
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
            const SizedBox(height: 20),

            // Date Selector Card
            GestureDetector(
              onTap: _presentDatePicker,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: AppRadius.mdAll,
                  border: Border.all(
                    color: _selectedDate != null
                        ? AppColors.success
                        : AppColors.border,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _selectedDate != null
                            ? AppColors.success.withOpacity(0.15)
                            : AppColors.card,
                        borderRadius: AppRadius.smAll,
                      ),
                      child: Icon(
                        Icons.calendar_today_rounded,
                        color: _selectedDate != null
                            ? AppColors.success
                            : AppColors.textTertiary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date',
                            style: TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedDate == null
                                ? 'Select a date'
                                : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                            style: TextStyle(
                              color: _selectedDate != null
                                  ? AppColors.success
                                  : AppColors.textSecondary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textTertiary,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Time Selector Card
            GestureDetector(
              onTap: _presentTimePicker,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: AppRadius.mdAll,
                  border: Border.all(
                    color: _selectedTime != TimeOfDay(hour: 0, minute: 0)
                        ? AppColors.success
                        : AppColors.border,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _selectedTime != TimeOfDay(hour: 0, minute: 0)
                            ? AppColors.success.withOpacity(0.15)
                            : AppColors.card,
                        borderRadius: AppRadius.smAll,
                      ),
                      child: Icon(
                        Icons.access_time_rounded,
                        color: _selectedTime != TimeOfDay(hour: 0, minute: 0)
                            ? AppColors.success
                            : AppColors.textTertiary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Time',
                            style: TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedTime == TimeOfDay(hour: 0, minute: 0)
                                ? 'Select a time (optional)'
                                : _selectedTime!.format(context),
                            style: TextStyle(
                              color:
                                  _selectedTime != TimeOfDay(hour: 0, minute: 0)
                                      ? AppColors.success
                                      : AppColors.textSecondary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textTertiary,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Next Button
            Buttoncomponent(
              onPressed: () {
                _SaveDateTimeTitle();
              },
              buttonText: "Continue",
            ),
            SizedBox(
                height: MediaQuery.of(context).viewInsets.bottom > 0 ? 8 : 0),
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
