import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
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

    print('CountDownData saved successfully!');
  } catch (e) {
    print('Error saving CountDownData: ${e.toString()}');
  }
}

Future<void> updateCountDownData(CountDownData countDownData) async {
  try {
    // Reference to the user's countdowns
    DatabaseReference countdownRef =
        database.ref().child('countdowns').child(_auth.currentUser!.uid);

    // Check if the countdown ID already exists
    // We assume countDownId is the unique identifier for the countdown
    print("current countdown id -" + countDownData.countDownId);
    DataSnapshot existingCountdownSnapshot =
        await countdownRef.child(countDownData.countDownId).get();

    // Create a map of the CountDownData object
    Map<String, dynamic> data = {
      'countDownTempId': countDownData.countDownTempId,
      'countDownTitle': countDownData.countDownTitle,
      'countDownTargetDate': countDownData
          .countDownTargetDate.millisecondsSinceEpoch, // Store as timestamp
      'countDownDim': countDownData.countDownDim,
      'countDownCreatedDate':
          countDownData.countDownCreatedDate.millisecondsSinceEpoch,
      'countDownImage': countDownData.countDownImage,
    };

    if (existingCountdownSnapshot.exists) {
      // Update existing countdown data
      await countdownRef.child(countDownData.countDownId).update(data);
      print('CountDownData updated successfully!');
    }
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
        countDownId: key as String,
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

// Future<String> SaveImgOnFirebase(final pickedFile) async {
//   String uid = _auth.currentUser!.uid;
//   print('call save img');
//   try {
//     if (pickedFile != null) {
//       // Create a reference to the Firebase Storage
//       String fileName =
//           DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';
//       Reference storageReference =
//           FirebaseStorage.instance.ref().child('CountdownImgs/$fileName');

//       // Upload the image to Firebase Storage
//       UploadTask uploadTask = storageReference.putFile(File(pickedFile.path));
//       print('uploading');
//       // Wait for the upload to complete
//       TaskSnapshot snapshot = await uploadTask;

//       // Get the download URL
//       String downloadUrl = await snapshot.ref.getDownloadURL();
//       print(downloadUrl);
//       return downloadUrl;
//     } else {
//       return 'picked file not valid';
//     }
//   } catch (e) {
//     return e.toString();
//   }
// }

// (Optional) Check if user is already signed in
Stream<User?> authStateChanges() => _auth.authStateChanges();
