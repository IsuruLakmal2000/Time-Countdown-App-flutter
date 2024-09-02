// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timecountdown/FirebaseServices/FirebaseSerives.dart';
import 'package:timecountdown/Pages/HomePage.dart';
import 'package:timecountdown/Providers/RenderedWidgetProvider.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  Future<void>? _signInWithGoogle() async {
    final widgetStateProvider =
        Provider.of<RenderedWidgetProvider>(context, listen: false);
    try {
      widgetStateProvider.isLoading = true;
      final userCredential = await signInWithGoogle(context);
      if (userCredential != null) {
        widgetStateProvider.isLoading = false;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) =>
                  HomePage()), // Replace with your home page widget
        );
      } else {
        widgetStateProvider.isLoading = false;
        print("User not signed in");
      }
    } on FirebaseAuthException catch (e) {
      widgetStateProvider.isLoading = false;
      // Handle errors (e.g., user canceled, network issues)
      print(e.code);
      print(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final widgetStateProvider = Provider.of<RenderedWidgetProvider>(context);
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Image.asset(
            "assets/Images/signPage.jpg", // Replace with your image path
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.5),
                  Color.fromARGB(139, 0, 0, 0).withOpacity(0.8),
                ],
              ),
            ),
          ),
          // Content on top of the gradient
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 300,
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Make ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w600,
                          height: 1,
                        ),
                      ),
                      TextSpan(
                        text: 'your own ',
                        style: TextStyle(
                          color: Color.fromARGB(
                              255, 255, 0, 255), // Change the color here
                          fontSize: 44,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      ),
                      TextSpan(
                        text: 'countdowns',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w600,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "dreams, goals, and more",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                SizedBox(
                  height: 100,
                ),
                Text(
                  "Get started by signing in",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () {
                    _signInWithGoogle();
                  },
                  child: Container(
                    height: 50,
                    width: 230,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              image: DecorationImage(
                                  image: NetworkImage(
                                      "https://cdn-icons-png.flaticon.com/512/2991/2991148.png"))),
                        ),
                        Text(
                          "Continue with Google",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          widgetStateProvider.isLoading
              ? Container(
                  color: Color.fromARGB(97, 0, 0, 0),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Color.fromARGB(174, 26, 0, 0)),
                      backgroundColor: Color.fromARGB(230, 174, 2, 218),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
