// ignore_for_file: prefer_const_constructors, prefer_adjacent_string_concatenation, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:timecountdown/Model/TemplateData.dart';
import 'package:timecountdown/Pages/CountdownCardTemplate.dart';

class Template4 extends StatefulWidget {
  Template4({
    super.key,
    // required this.index,
    required this.countDownTitle,
    required this.templateDateTime,
    required this.dimCount,
    required this.image,
  });

  String countDownTitle;
//  int index = 0;
  DateTime? templateDateTime;
  double dimCount = 8;
  String image;
  @override
  State<Template4> createState() => _Template4State();
}

class _Template4State extends State<Template4> {
  Timer? timer;
  int years = 0;
  int days = 0;
  int hours = 0;
  int minutes = 0;
  int seconds = 0;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(
      Duration(milliseconds: 200),
      (_) => setState(() {
        if (widget.templateDateTime == null) {
          return;
        } else {
          getCountdown();
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
    Duration difference = widget.templateDateTime!.difference(now);
    years = difference.inDays ~/ 365; // Calculate years
    days = difference.inDays %
        365; // Get remaining days after accounting for years
    hours = difference.inHours %
        24; // Get remaining hours after accounting for days
    minutes = difference.inMinutes %
        60; // Get remaining minutes after accounting for hours
    seconds = difference.inSeconds %
        60; // Get remaining seconds after accounting for minutes
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
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
              Text(
                widget.countDownTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                  fontSize: 30,
                ),
              ),
              SizedBox(
                height: 50,
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  // Circular progress indicator
                  CircularProgressIndicator(
                    value: 1 -
                        (seconds /
                            (days * 24 * 60 * 60 +
                                hours * 60 * 60 +
                                minutes * 60 +
                                seconds)),
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 10,
                  ),
                  // Countdown text
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '$days',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 54,
                        ),
                      ),
                      Text(
                        'Dasys',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'Time Remaining',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                  fontSize: 20,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        '$hours',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 36,
                        ),
                      ),
                      Text(
                        'Hours',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '$minutes',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 36,
                        ),
                      ),
                      Text(
                        'Minutes',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
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
                          fontSize: 36,
                        ),
                      ),
                      Text(
                        'Seconds',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant Template4 oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update dimValue based on count from parent widget
    // Adjust this calculation as needed
    setState(() {}); // Rebuild the widget to apply the new dimValue
  }
}
