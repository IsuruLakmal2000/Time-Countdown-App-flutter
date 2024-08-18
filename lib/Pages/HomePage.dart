import 'package:flutter/material.dart';
import 'package:timecountdown/Pages/CountdownCardTemplate.dart';
import 'package:timecountdown/Pages/AddCountdown/NewCountDownAddBottomSheet.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showNewcountdownAddpage(context);
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          'Material 3 App',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: CountDownCardTemplate(),
    );
  }

  void showNewcountdownAddpage(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Color.fromARGB(255, 0, 0, 0),
      context: context,
      builder: (BuildContext context) {
        return NewcountdownAddBottomSheet();
      },
    );
  }
}
