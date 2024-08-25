import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timecountdown/Pages/CountdownCardTemplate.dart';
import 'package:timecountdown/Pages/AddCountdown/NewCountDownAddBottomSheet.dart';
import 'package:timecountdown/Pages/EditCountdown/EditCountDownBottomSheet.dart';
import 'package:timecountdown/Providers/EditCountDownProvider.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final editCountDownProvider =
        Provider.of<Editcountdownprovider>(context, listen: false);

    void _countDownEdit() {
      print('Edit----' + editCountDownProvider.currentPage.toString());
    }

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
          'Time CountDown',
          style: TextStyle(
              color: Color.fromRGBO(255, 255, 255, 1),
              fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            color: Colors.white,
            onPressed: () {
              // _countDownEdit();
              showEditCountdownBottomSheet(context);
            },
            icon: const Icon(Icons.edit),
          ),
        ],
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

  void showEditCountdownBottomSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Color.fromARGB(255, 0, 0, 0),
      context: context,
      builder: (BuildContext context) {
        return EditCountDownBottomSheet(
          initialTitle: 'Initial Title',
          initialDate: DateTime.now(),
          initialTime: TimeOfDay.now(),
        );
      },
    );
  }
}
