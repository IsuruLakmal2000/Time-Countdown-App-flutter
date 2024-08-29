import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

class Template1 extends StatefulWidget {
  Template1({
    super.key,
    // required this.index,
    required this.countDownTitle,
    required this.templateDateTime,
    required this.createdDate,
    required this.dimCount,
    required this.image,
  });

  String countDownTitle;
//  int index = 0;
  DateTime? createdDate;
  DateTime? templateDateTime;
  double dimCount = 8;
  String image;

  @override
  State<Template1> createState() => _Template1State();
}

class _Template1State extends State<Template1> {
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 41, 41, 41),
              Color.fromARGB(255, 13, 14, 14),
            ],
          ),
          image: widget.countDownTitle != 'No countdowns available'
              ? DecorationImage(
                  image: FileImage(File(widget.image)),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(widget.dimCount),
                      BlendMode.multiply),
                )
              : DecorationImage(
                  image: Image.asset('assets/Images/office.jpg').image,
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(widget.dimCount),
                      BlendMode.multiply),
                ),
        ),
        // Sample content for each page
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              textAlign: TextAlign.center,
              widget.countDownTitle,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Column(
              children: [
                years != 0
                    ? Text(
                        '$years' + " Years",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                          fontSize: 40,
                        ),
                      )
                    : Container(),
                days != 0
                    ? Transform(
                        transform: Matrix4.translationValues(0, -20, 0),
                        child: Text(
                          '$days' + " Days",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.normal,
                            fontSize: 50,
                          ),
                        ),
                      )
                    : Container(),
                Transform(
                  transform: Matrix4.translationValues(0, -35, 0),
                  child: Text(
                    '$hours' + " Hours",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                      fontSize: 40,
                    ),
                  ),
                ),
                Transform(
                  transform: Matrix4.translationValues(0, -47, 0),
                  child: Text(
                    '$minutes' + " Minutes",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                      fontSize: 28,
                    ),
                  ),
                ),
                Transform(
                  transform: Matrix4.translationValues(0, -50, 0),
                  child: Text(
                    '$seconds' + " Seconds",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                      fontSize: 20,
                    ),
                  ),
                ),
                isElapsed
                    ? Transform(
                        transform: Matrix4.translationValues(0, -50, 0),
                        child: const Text(
                          " (Since)",
                          style: TextStyle(
                            color: Color.fromARGB(255, 0, 255, 43),
                            fontWeight: FontWeight.normal,
                            fontSize: 20,
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
            Transform(
              transform: Matrix4.translationValues(0, 50, 0),
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
        )),
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
  void didUpdateWidget(covariant Template1 oldWidget) {
    super.didUpdateWidget(oldWidget);

    setState(() {});
  }
}
