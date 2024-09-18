import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timecountdown/Component/CustomSnackBar.dart';
import 'package:timecountdown/FirebaseServices/FirebaseSerives.dart';
import 'package:timecountdown/Mobile%20ads/InterstialAdService.dart';
import 'package:timecountdown/NotificationService/NotificationService.dart';
import 'package:timecountdown/Pages/MainPages/CountdownCardTemplate.dart';
import 'package:timecountdown/Pages/AddCountdown/NewCountDownAddBottomSheet.dart';
import 'package:timecountdown/Pages/EditCountdown/EditCountDownBottomSheet.dart';
import 'package:timecountdown/Pages/OnBoarding/OnBoardingScreen.dart';
import 'package:timecountdown/Pages/PremiumPage/PremiumPage.dart';
import 'package:timecountdown/Pages/SideBar/SideBar.dart';
import 'package:timecountdown/Providers/EditCountDownProvider.dart';
import 'package:timecountdown/Providers/RenderedWidgetProvider.dart';
import 'package:timecountdown/Providers/UserProvider.dart';
import 'package:timecountdown/main.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? currentUser;
  bool isLoading = false;
  final Interstialadservice _interstitialAdService = Interstialadservice();
  @override
  void initState() {
    super.initState();
    getUserDetails();
    _interstitialAdService.loadAd();
    requestPermissions();
    initializeNotifications();
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (context) =>
              OnboardingScreen()), // Replace with your home page widget
    );
  }

  void getUserDetails() async {
    isLoading = true;
    await context.read<UserProvider>().fetchUserData();
    currentUser = await FirebaseAuth.instance.currentUser;
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    final editCountDownProvider =
        Provider.of<Editcountdownprovider>(context, listen: false);
    final userProvider = context.watch<UserProvider>();
    final isUserPurchased = userProvider.userData?.isPurchased == true;
    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (!isUserPurchased) {
            if ((userProvider.userData?.countdownCount ?? 0) >= 5) {
              ScaffoldMessenger.of(context).showSnackBar(
                CustomSnackBar(
                  message1: 'You can only add ',
                  message2: '5 countdowns ',
                  message3: 'in the free version. ',
                  message4: 'Upgrade to premium ',
                  message5: 'to add more.',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PremiumPage(),
                      ),
                    );
                  },
                ),
              );
            } else {
              showNewcountdownAddpage(context);
            }
          } else {
            showNewcountdownAddpage(context);
          }
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
      body: userProvider.userData != null
          ? const CountDownCardTemplate()
          : Center(child: CircularProgressIndicator()),
      drawer: SideBar(context, currentUser, _signOut),
    );
  }

  void showNewcountdownAddpage(BuildContext context) {
    final editCountDownProvider =
        Provider.of<Editcountdownprovider>(context, listen: false);
    editCountDownProvider.isEditCountDown = false;

    showModalBottomSheet(
      backgroundColor: Color.fromARGB(255, 0, 0, 0),
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: NewcountdownAddBottomSheet(),
        );
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
    final widgetStateProvider =
        Provider.of<RenderedWidgetProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

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
              onPressed: () async {
                _interstitialAdService.showAd();
                // Call the delete function here
                widgetStateProvider.isLoading = true;
                await deleteCountdown(countdownId, context);
                await updateCountdownCount(
                    userProvider.userData!.countdownCount - 1);
                context.read<UserProvider>().fetchUserData();
                widgetStateProvider.isLoading = false;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyApp(),
                  ),
                );
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
