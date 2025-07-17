import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:timecountdown/Component/CountdownCards/TemplateFunctions.dart';

class Template9 extends StatefulWidget {
  Template9({
    super.key,
    // required this.index,
    required this.countDownTitle,
    required this.templateDateTime,
    required this.createdDate,
    required this.dimCount,
    required this.image,
  });

  final String countDownTitle;
//  int index = 0;
  final DateTime? createdDate;
  final DateTime? templateDateTime;
  final double dimCount;
  final String image;

  @override
  State<Template9> createState() => _Template9State();
}

class _Template9State extends State<Template9> {
  Timer? timer;
  int years = 0;
  int days = 0;
  int hours = 0;
  int minutes = 0;
  int seconds = 0;
  bool isElapsed = false;

  @override
  void initState() {
    super.initState();
    DateTime targetDateTime = widget.templateDateTime!;
    DateTime now = DateTime.now();
    timer = Timer.periodic(
      Duration(milliseconds: 200),
      (_) => setState(() {
        if (widget.templateDateTime == null) {
          return;
        } else {
          if (now.isAfter(targetDateTime)) {
            isElapsed = true;
            getElapsedTime();
          } else {
            isElapsed = false;
            getCountdown();
          }
        }
      }),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void getCountdown() {
    DateTime now = DateTime.now();
    DateTime targetDateTime = widget.templateDateTime!;

    int remainingDays = targetDateTime.difference(now).inDays;

    years = 0;
    days = remainingDays;

    while (days >= 365) {
      if (isLeapYear(targetDateTime.year)) {
        if (days >= 366) {
          days -= 366;
          targetDateTime = DateTime(targetDateTime.year + 1);
          years++;
        } else {
          break;
        }
      } else {
        days -= 365;
        targetDateTime = DateTime(targetDateTime.year + 1);
        years++;
      }
    }

    hours = targetDateTime.difference(now).inHours % 24;
    minutes = targetDateTime.difference(now).inMinutes % 60;
    seconds = targetDateTime.difference(now).inSeconds % 60;
  }

  void getElapsedTime() {
    DateTime now = DateTime.now();
    DateTime targetDateTime = widget.templateDateTime!;

    // Check if the target date has passed
    if (now.isAfter(targetDateTime)) {
      // Calculate the elapsed time
      Duration elapsed = now.difference(targetDateTime);

      // Set years, days, hours, minutes, and seconds for elapsed time
      years = elapsed.inDays ~/ 365;
      days = elapsed.inDays % 365;
      hours = elapsed.inHours % 24;
      minutes = elapsed.inMinutes % 60;
      seconds = elapsed.inSeconds % 60;
    } else {
      // Reset elapsed time variables to 0
      years = 0;
      days = 0;
      hours = 0;
      minutes = 0;
      seconds = 0;
    }
  }

  bool isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;
  }

  Widget _buildCountdownElement(int value, String label) {
    // Use cascading logic instead of simple value == 0 check
    String unit = label.toLowerCase();
    if (unit.contains('year')) {
      unit = 'years';
    } else if (unit.contains('day')) {
      unit = 'days'; 
    } else if (unit.contains('hour')) {
      unit = 'hours';
    } else if (unit.contains('minute')) {
      unit = 'minutes';
    } else if (unit.contains('second')) {
      unit = 'seconds';
    }
    
    if (!TemplateFunctions.shouldShowTimeUnit(
      unit: unit,
      years: years,
      days: days,
      hours: hours,
      minutes: minutes,
      seconds: seconds,
    )) {
      return Container();
    }
    
    return Column(
      children: [
        Text(
          '$value',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 60,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.normal,
            fontSize: 26,
          ),
        ),
      ],
    );
  }

  Widget _buildResponsiveTopRow() {
    List<Widget> elements = [
      _buildCountdownElement(days, 'Days'),
      _buildCountdownElement(hours, 'Hours'),
    ];

    if (elements.isEmpty) {
      return Container();
    }

    return Row(
      mainAxisAlignment: elements.length == 1 
          ? MainAxisAlignment.center 
          : MainAxisAlignment.spaceAround,
      children: elements,
    );
  }

  Widget _buildResponsiveBottomRow() {
    List<Widget> elements = [
      _buildCountdownElement(minutes, 'Minutes'),
      _buildCountdownElement(seconds, 'Seconds'),
    ];

    if (elements.isEmpty) {
      return Container();
    }

    return Row(
      mainAxisAlignment: elements.length == 1 
          ? MainAxisAlignment.center 
          : MainAxisAlignment.spaceAround,
      children: elements,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: widget.image != ''
          ? Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(255, 41, 41, 41),
                    Color.fromARGB(255, 13, 14, 14),
                  ],
                ),
                image: widget.image.isNotEmpty
                    ? DecorationImage(
                        image: widget.image.startsWith('assets/')
                            ? AssetImage(widget.image)
                            : FileImage(File(widget.image)) as ImageProvider,
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(widget.dimCount),
                          BlendMode.multiply,
                        ),
                      )
                    : null,
              ),
              child: _buildTemplateContent(),
            )
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(255, 41, 41, 41),
                    Color.fromARGB(255, 13, 14, 14),
                  ],
                ),
              ),
              child: _buildTemplateContent(),
            ),
    );
  }

  Widget _buildTemplateContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Transform(
            transform: Matrix4.translationValues(0, 50, 0),
            child: Text(
              widget.countDownTitle,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          years != 0
              ? Transform(
                  transform: Matrix4.translationValues(0, 50, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildCountdownElement(years, 'Years'),
                    ],
                  ),
                )
              : Container(),
          Transform(
            transform: Matrix4.translationValues(0, 50, 0),
            child: _buildResponsiveTopRow(),
          ),
          Transform(
            transform: Matrix4.translationValues(0, 0, 0),
            child: Lottie.asset(
              'assets/lottie/money.json', // Path to your Lottie file
              width: 170, // Adjust the width as needed
              height: 130, // Adjust the height as needed
              fit: BoxFit.fill,
            ),
          ),
          Transform(
            transform: Matrix4.translationValues(0, -75, 0),
            child: _buildResponsiveBottomRow(),
          ),
          Transform(
            transform: Matrix4.translationValues(0, 0, 0),
            child: Text(
              "Created on : " + formatDate(widget.createdDate!),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.normal,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String formatDate(DateTime dateTime) {
    int year = dateTime.year;
    int month = dateTime.month;
    int day = dateTime.day;
    String formattedDate =
        year.toString() + '-' + month.toString() + '-' + day.toString();

    return formattedDate; // Format the DateTime
  }

  @override
  void didUpdateWidget(covariant Template9 oldWidget) {
    super.didUpdateWidget(oldWidget);

    setState(() {});
  }
}
