import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  // Sign in with Email/Password
  Future<Map<String, dynamic>?> signInWithEmailPassword(String email, String password) async {
    try {
      // Sign in with email and password
      final UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      // Fetch the user data from Firestore
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        return userDoc.data();
      } else {
        throw Exception("User data not found!");
      }
    } catch (e) {
      throw Exception("Failed to login: ${e.toString()}");
    }
  }


  // Register with Email/Password
  Future<void> registerWithEmailPassword(String name, String email, String password) async {
    try {
      // Create the user and capture the UserCredential
      final UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Extract the user ID
      final uid = userCredential.user!.uid;

      // Print the UID to the console
      print("User ID: $uid");

      // Save user data in Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Notify listeners if using a state management solution
      notifyListeners();
    } catch (e) {
      throw Exception("Failed to register: ${e.toString()}");
    }
  }



  // Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in.
        print("Sign-in aborted by user.");
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase using the credential
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        print("Google sign-in successful");

        // Check if the user exists in Firestore
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          // If the user doesn't exist, create a new profile
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'email': user.email,
            'name': user.displayName,
            'profileImage': user.photoURL ?? '', // Set the profile image if available
            'createdAt': FieldValue.serverTimestamp(),
          });

          print("New user profile created in Firestore");
        } else {
          // User already exists in Firestore, update if necessary
          print("User profile already exists in Firestore");
        }

      }
    } catch (e) {
      print("Error during Google sign-in: $e");
      // Handle errors appropriately in your UI
    }
  }



  // Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    notifyListeners();
  }

  bool get isAuthenticated => currentUser != null;
}

Future<Map<String, dynamic>?> fetchUserProfile(String uid) async {
  try {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return userDoc.data();
  } catch (e) {
    print('Error fetching user profile: $e');
    return null;
  }
}
