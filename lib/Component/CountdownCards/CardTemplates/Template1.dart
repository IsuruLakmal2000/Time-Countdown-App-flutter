// ignore_for_file: prefer_const_constructors, prefer_adjacent_string_concatenation, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';

class Template1 extends StatefulWidget {
  Template1({
    super.key,
    // required this.index,
    required this.templateData,
    required this.templateDateTime,
    required this.dimCount,
  });

  String templateData;
//  int index = 0;
  DateTime? templateDateTime;
  double dimCount = 8;

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

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(
      Duration(seconds: 1),
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
          image: DecorationImage(
            image: NetworkImage(
                "https://images.unsplash.com/photo-1723653263152-f20aae931b99?q=80&w=1374&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(widget.dimCount),
                BlendMode
                    .multiply), // here can use the double value for edition purpose
          ),
        ),
        // Sample content for each page
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.templateData,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.normal,
                fontSize: 24,
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Column(
              children: [
                Text(
                  '$days' + " Days",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 54,
                  ),
                ),
                Transform(
                  transform: Matrix4.translationValues(0, -10, 0),
                  child: Text(
                    '$hours' + " Hours",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                    ),
                  ),
                ),
                Transform(
                  transform: Matrix4.translationValues(0, -17, 0),
                  child: Text(
                    '$minutes' + " Minutes",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                ),
                Transform(
                  transform: Matrix4.translationValues(0, -20, 0),
                  child: Text(
                    '$seconds' + " Seconds",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        )),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant Template1 oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update dimValue based on count from parent widget
    // Adjust this calculation as needed
    setState(() {}); // Rebuild the widget to apply the new dimValue
  }
}
