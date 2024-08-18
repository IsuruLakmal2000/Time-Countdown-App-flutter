import 'package:flutter/material.dart';
import 'package:timecountdown/Pages/HomePage.dart';
import 'package:timecountdown/Theme/Theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // theme: lightMode,
      //   darkTheme: darkMode,
      home: HomePage(),
    );
  }
}
