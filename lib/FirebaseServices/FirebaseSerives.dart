import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:timecountdown/Model/CountDownData.dart';
import 'package:timecountdown/Model/UserData.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();
final database = FirebaseDatabase.instance;

Future<UserCredential?> signInWithGoogle(BuildContext context) async {
  try {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    // Check if canceled
    if (googleUser == null) {
      return null; // User canceled the sign-in
    }

    // Obtain the auth details from the Google Sign-In account
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in with Firebase
    UserCredential userCredential =
        await _auth.signInWithCredential(credential);

    // Create database for this user
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
        'isPurchased': false,
        'countdownCount': 0,
        // ... other user data
      };

      await userRef.set(userData);
    }

    // Return the user credential
    return userCredential;
  } on FirebaseAuthException catch (e) {
    // Handle specific Firebase authentication errors
    String errorMessage = 'An unknown error occurred.';
    if (e.code == 'invalid-credential') {
      errorMessage = 'The provided credential is invalid.';
    } else if (e.code == 'operation-not-allowed') {
      errorMessage = 'Google sign-in is not enabled.';
    } else if (e.code == 'user-disabled') {
      errorMessage = 'This user has been disabled.';
    } else if (e.code == 'user-not-found') {
      errorMessage = 'No user found for this email.';
    } else if (e.code == 'email-already-in-use') {
      errorMessage = 'This email is already in use.';
    }

    // Show alert dialog with the error message
    _showErrorDialog(context, errorMessage);
    return null;
  } catch (e) {
    // Handle any other exceptions
    _showErrorDialog(context, e.toString());
    return null;
  }
}

void _showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
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

Future<void> deleteCountdown(String countdownId, BuildContext context) async {
  String uid = _auth.currentUser!.uid; // Get the current user's ID

  try {
    // Reference to the specific countdown entry
    await database
        .ref()
        .child('countdowns')
        .child(uid)
        .child(countdownId)
        .remove();
  } catch (e) {
    // Handle any errors that occur during deletion
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to delete countdown: $e')),
    );
  }
}

Future<UserData?> getCurrentUserData() async {
  // Get the current user
  User? currentUser = _auth.currentUser;

  // Check if the user is signed in
  if (currentUser == null) {
    return null; // Return null if no user is signed in
  }

  // Get the user's UID
  final uid = currentUser.uid;

  // Reference to the user's data in the database
  final userRef = database.ref().child('users').child(uid);

  // Fetch the user data from the database
  DataSnapshot snapshot = await userRef.get();

  if (snapshot.exists) {
    // Convert the snapshot data to a UserData object
    final data = snapshot.value as Map<dynamic, dynamic>;

    return UserData(
      uid: data['uid'] as String,
      name: data['name'] as String,
      email: data['email'] as String,
      account_created: data['account_created'] as String,
      last_app_opened: data['last_app_opened'] as String,
      isPurchased: data['isPurchased'] as bool,
      countdownCount: data['countdownCount'] as int,
    );
  } else {
    return null; // Return null if no data is found
  }
}

Future<void> updateCountdownCount(int newCount) async {
  // Get the current user
  User? currentUser = _auth.currentUser;

  if (currentUser != null) {
    final uid = currentUser.uid;
    final userRef = database.ref().child('users').child(uid);

    // Update the countdownCount field with the new value
    await userRef.update({
      'countdownCount': newCount,
    });
  }
}

Future<void> updateIsPurchased(bool newStatus) async {
  // Get the current user
  User? currentUser = _auth.currentUser;

  if (currentUser != null) {
    final uid = currentUser.uid;
    final userRef = database.ref().child('users').child(uid);

    // Update the isPurchased field with the new value
    await userRef.update({
      'isPurchased': newStatus,
    });
  }
}

Future<String> getRatingUrl() async {
  try {
    // Get the reference to the 'ratingUrl' property
    final ratingUrlRef = database.ref().child('properties').child('ratingUrl');

    // Fetch the value of 'ratingUrl'
    final snapshot = await ratingUrlRef.get();

    // Check if the snapshot has a value
    if (snapshot.exists) {
      // Get the value of 'ratingUrl'
      final ratingUrl = snapshot.value as String;
      print('Rating URL: $ratingUrl');
      return ratingUrl;
    } else {
      print('No rating URL found in the database.');
      return '';
    }
  } catch (e) {
    print('Error getting rating URL: $e');
    rethrow;
  }
}

// (Optional) Check if user is already signed in
Stream<User?> authStateChanges() => _auth.authStateChanges();
