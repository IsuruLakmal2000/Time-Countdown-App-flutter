import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Template6 extends StatefulWidget {
  Template6({
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
  State<Template6> createState() => _Template6State();
}

class _Template6State extends State<Template6> {
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
          image: widget.image != ''
              ? DecorationImage(
                  // image: NetworkImage(
                  //     "https://images.unsplash.com/photo-1723653263152-f20aae931b99?q=80&w=1374&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"),
                  image: FileImage(File(widget.image)),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(widget.dimCount),
                      BlendMode
                          .multiply), // here can use the double value for edition purpose
                )
              : null,
        ),
        // Sample content for each page
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Transform(
              transform: Matrix4.translationValues(0, 50, 0),
              child: Text(
                textAlign: TextAlign.center,
                widget.countDownTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Transform(
              transform: Matrix4.translationValues(0, 50, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      years == 0
                          ? Column(
                              children: [
                                Text(
                                  '$years',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 60,
                                  ),
                                ),
                                const Text(
                                  'Years',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 26,
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                    ],
                  )
                ],
              ),
            ),
            Transform(
              transform: Matrix4.translationValues(0, 50, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '$days',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 60,
                        ),
                      ),
                      const Text(
                        'Days',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                          fontSize: 26,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '$hours',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 60,
                        ),
                      ),
                      const Text(
                        'Hours',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                          fontSize: 26,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Transform(
              transform: Matrix4.translationValues(0, -50, 0),
              child: Lottie.asset(
                'assets/lottie/timeUp.json', // Path to your Lottie file
                width: 130, // Adjust the width as needed
                height: 100, // Adjust the height as needed
                fit: BoxFit.fill,
              ),
            ),
            Transform(
              transform: Matrix4.translationValues(0, -75, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '$minutes',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 60,
                        ),
                      ),
                      const Text(
                        'Minutes',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                          fontSize: 26,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '$seconds',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 60,
                        ),
                      ),
                      const Text(
                        'Seconds',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                          fontSize: 26,
                        ),
                      ),
                    ],
                  )
                ],
              ),
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
  void didUpdateWidget(covariant Template6 oldWidget) {
    super.didUpdateWidget(oldWidget);

    setState(() {});
  }
}
