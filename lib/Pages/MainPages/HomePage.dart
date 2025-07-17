import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timecountdown/Component/CustomSnackBar.dart';
import 'package:timecountdown/Services/LocalStorageService.dart';
import 'package:timecountdown/Services/CountdownWidgetService.dart';
import 'package:timecountdown/NotificationService/NotificationService.dart';
import 'package:timecountdown/Pages/MainPages/CountdownCardTemplate.dart';
import 'package:timecountdown/Pages/AddCountdown/NewCountDownAddBottomSheet.dart';
import 'package:timecountdown/Pages/EditCountdown/EditCountDownBottomSheet.dart';
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
  bool isLoading = false;
  bool isFullScreen = false; // Track full screen mode
  bool showFullScreenIndicator = false; // Show visual feedback
  
  @override
  void initState() {
    super.initState();
    getUserDetails();
    requestPermissions();
    initializeNotifications();
  }

  void _toggleFullScreen() {
    setState(() {
      isFullScreen = !isFullScreen;
      showFullScreenIndicator = true;
    });
    
    // Hide the indicator after 1 second
    Future.delayed(Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          showFullScreenIndicator = false;
        });
      }
    });
  }

  void _showWidgetConfigurationDialog() async {
    try {
      // Update widget data first
      await CountdownWidgetService.updateWidgetData();
      
      final countdowns = await LocalStorageService.getCountdowns();
      
      if (countdowns.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Create a countdown first to add it as a widget'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A1A2E),
            title: Text(
              'Add Home Screen Widget',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'To add a countdown widget to your home screen:\n\n'
              '1. Go to your home screen\n'
              '2. Long press on empty space\n'
              '3. Tap "Widgets"\n'
              '4. Find "Time CountDown" widget\n'
              '5. Drag it to your home screen\n'
              '6. Select which countdown to display',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Got it!',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error preparing widget data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void getUserDetails() async {
    isLoading = true;
    await context.read<UserProvider>().fetchUserData();
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
      floatingActionButton: isFullScreen ? null : Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.3),
              Colors.white.withOpacity(0.1),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              spreadRadius: -1,
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: () {
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
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ),
      appBar: isFullScreen ? null : AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        actions: [
          IconButton(
            color: Colors.white,
            onPressed: _showWidgetConfigurationDialog,
            icon: const Icon(
              Icons.widgets,
              color: Colors.blue,
            ),
          ),
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
      body: Stack(
        children: [
          userProvider.userData != null
              ? GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onDoubleTap: () {
                    print("Double tap detected!"); // Debug output
                    _toggleFullScreen();
                  },
                  child: CountDownCardTemplate(
                    onDoubleTap: () {
                      print("CountDownCardTemplate double tap detected!"); // Debug output
                      _toggleFullScreen();
                    },
                  ),
                )
              : Center(
                  child: isLoading 
                    ? CircularProgressIndicator()
                    : CountDownCardTemplate()
                ),
          // Visual indicator for full screen toggle
          if (showFullScreenIndicator)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.4,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isFullScreen ? "Full Screen Mode" : "Normal Mode",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      drawer: isFullScreen ? null : SideBar(context, null),
    );
  }

  void showNewcountdownAddpage(BuildContext context) {
    final editCountDownProvider =
        Provider.of<Editcountdownprovider>(context, listen: false);
    final widgetStateProvider =
        Provider.of<RenderedWidgetProvider>(context, listen: false);
    
    editCountDownProvider.isEditCountDown = false;
    // Reset provider to default values for new countdown
    widgetStateProvider.resetForNewCountdown();

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
                // Call the delete function here
                widgetStateProvider.isLoading = true;
                await LocalStorageService.deleteCountdown(countdownId, context);
                
                // Ensure user data is available before updating countdown count
                if (userProvider.userData != null) {
                  await LocalStorageService.updateCountdownCount(
                      userProvider.userData!.countdownCount - 1);
                } else {
                  // Get current user data if provider data is null
                  final userData = await LocalStorageService.getCurrentUserData();
                  if (userData != null) {
                    await LocalStorageService.updateCountdownCount(userData.countdownCount - 1);
                  }
                }
                
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
