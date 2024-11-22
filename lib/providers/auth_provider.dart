import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Future<Map<String, dynamic>?> signInWithEmailPassword(String email, String password) async {
    try {
   
      final UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

    
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


  Future<void> registerWithEmailPassword(String name, String email, String password) async {
    try {
    
      final UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

  
      final uid = userCredential.user!.uid;

     
      print("User ID: $uid");

    
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
      notifyListeners();
    } catch (e) {
      throw Exception("Failed to register: ${e.toString()}");
    }
  }
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
    
        print("Sign-in aborted by user.");
        return;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        print("Google sign-in successful");
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'email': user.email,
            'name': user.displayName,
            'profileImage': user.photoURL ?? '', 
            'createdAt': FieldValue.serverTimestamp(),
          });

          print("New user profile created in Firestore");
        } else {
         
          print("User profile already exists in Firestore");
        }

      }
    } catch (e) {
      print("Error during Google sign-in: $e");
  
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
