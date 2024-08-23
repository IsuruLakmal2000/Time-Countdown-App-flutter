import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:timecountdown/Model/CountDownData.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();
final database = FirebaseDatabase.instance;

Future<UserCredential?> signInWithGoogle() async {
  // Trigger the authentication flow
  final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

  // Check if canceled
  if (googleUser == null) {
    return null;
  }

  // Obtain the auth details from the Google Sign-In account
  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  // Sign in with Firebase
  UserCredential userCredential = await _auth.signInWithCredential(credential);
  //create database for this user
  if (userCredential != null) {
    final user = userCredential.user;
    if (user != null) {
      final uid = user.uid;
      final name = user.displayName; // Optional
      final email = user.email; // Optional

      final userRef = database.ref().child('users').child(uid);
      final userData = {
        'uid': uid,
        'name': name,
        'email': email,
        'account_created': DateTime.now().toString(),
        'last_app_opened': DateTime.now().toString(),
        // ... other user data
      };

      await userRef.set(userData);

      // Navigate to home screen or other relevant page
    }
  }
  // Return the user credential
  return userCredential;
}

//save countdown data
Future<void> saveCountDownData(CountDownData countDownData) async {
  try {
    // Generate a unique ID for the countdown (if needed)

    // Create a map of the CountDownData object
    Map<String, dynamic> data = {
      'countDownTempId': countDownData.countDownTempId,
      'countDownTitle': countDownData.countDownTitle,
      'countDownTargetDate': countDownData
          .countDownTargetDate.millisecondsSinceEpoch, // Store as timestamp
      'countDownDim': countDownData.countDownDim,
      'countDownCreatedDate':
          countDownData.countDownCreatedDate.millisecondsSinceEpoch,
      'countDownImage': countDownData.countDownImage, // Store as timestamp
    };
    // Generate a unique key for each countdown
    String countdownKey = database
        .ref()
        .child('countdowns')
        .child(_auth.currentUser!.uid)
        .push()
        .key!;

    await database
        .ref()
        .child('countdowns')
        .child(_auth.currentUser!.uid)
        .child(countdownKey)
        .set(data);

    // Save the data to the Firebase Realtime Database
    // if (_auth.currentUser?.uid != null) {
    //   await database
    //       .ref()
    //       .child('countdowns')
    //       .child(_auth.currentUser!.uid)
    //       .set(data);
    // }

    print('CountDownData saved successfully!');
  } catch (e) {
    print('Error saving CountDownData: ${e.toString()}');
  }
}

//get countdown data
Future<List<CountDownData>> getCountdowns() async {
  List<CountDownData> countdowns = [];
  String uid = _auth.currentUser!.uid;

  DataSnapshot snapshot =
      await database.ref().child('countdowns').child(uid).get();

  if (snapshot.exists) {
    Map<dynamic, dynamic> countdownMap =
        snapshot.value as Map<dynamic, dynamic>;
    countdownMap.forEach((key, value) {
      // Directly create CountDownData instance without fromMap
      countdowns.add(CountDownData(
        countDownImage: value['countDownImage'] as String,
        countDownTempId: value['countDownTempId'] as String,
        countDownTitle: value['countDownTitle'] as String,
        countDownTargetDate: DateTime.fromMillisecondsSinceEpoch(
            value['countDownTargetDate'] as int),
        countDownDim: value['countDownDim'] as double,
        countDownCreatedDate: DateTime.fromMillisecondsSinceEpoch(
            value['countDownCreatedDate'] as int),
      ));
    });
  }

  return countdowns;
}

// (Optional) Check if user is already signed in
Stream<User?> authStateChanges() => _auth.authStateChanges();
