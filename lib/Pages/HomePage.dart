import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timecountdown/FirebaseServices/FirebaseSerives.dart';
import 'package:timecountdown/Pages/CountdownCardTemplate.dart';
import 'package:timecountdown/Pages/AddCountdown/NewCountDownAddBottomSheet.dart';
import 'package:timecountdown/Pages/EditCountdown/EditCountDownBottomSheet.dart';
import 'package:timecountdown/Pages/OnBoarding/OnBoardingPage.dart';
import 'package:timecountdown/Pages/OnBoarding/OnBoardingScreen.dart';
import 'package:timecountdown/Pages/SideBar/SideBar.dart';
import 'package:timecountdown/Providers/EditCountDownProvider.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? currentUser;
  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  void _signOut() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (context) =>
              OnboardingScreen()), // Replace with your home page widget
    );
  }

  void getUserDetails() {
    currentUser = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    final editCountDownProvider =
        Provider.of<Editcountdownprovider>(context, listen: false);

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
              showDeleteConfirmationDialog(
                  context, editCountDownProvider.currentCountDownId);
            },
            icon: const Icon(
              Icons.delete_forever_rounded,
              color: Colors.red,
            ),
          ),
          IconButton(
            color: Colors.white,
            onPressed: () {
              showEditCountdownBottomSheet(context);
            },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: const CountDownCardTemplate(),
      drawer: SideBar(currentUser, _signOut),
    );
  }

  void showNewcountdownAddpage(BuildContext context) {
    final editCountDownProvider =
        Provider.of<Editcountdownprovider>(context, listen: false);
    editCountDownProvider.isEditCountDown = false;

    showModalBottomSheet(
      backgroundColor: Color.fromARGB(255, 0, 0, 0),
      context: context,
      builder: (BuildContext context) {
        return NewcountdownAddBottomSheet();
      },
    );
  }

  void showEditCountdownBottomSheet(BuildContext context) {
    final editCountDownProvider =
        Provider.of<Editcountdownprovider>(context, listen: false);
    editCountDownProvider.isEditCountDown = true;

    showModalBottomSheet(
      backgroundColor: Color.fromARGB(255, 0, 0, 0),
      context: context,
      builder: (BuildContext context) {
        return EditCountDownBottomSheet(
          initialTitle: editCountDownProvider.currentTitle,
          initialDate: editCountDownProvider.currentDate,
        );
      },
    );
  }

  Future<void> showDeleteConfirmationDialog(
      BuildContext context, String countdownId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content:
              const Text('Are you sure you want to delete this countdown?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                // Call the delete function here

                deleteCountdown(countdownId, context);

                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  // void deleteCountdown() async {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(
  //       content: Text('Countdown deleted successfully'),
  //     ),
  //   );
  // }
}
