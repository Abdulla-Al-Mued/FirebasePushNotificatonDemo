import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';

class AuthProviderClass extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;


  User? get currentUser => _auth.currentUser;


  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _updateFCMToken();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> signUp(String name, String email, String password) async {
    try {
      // Create the user
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get FCM token for the new user
      String? token = await _messaging.getToken();

      // Add user details to Firestore
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'fcmToken': token,
      });

      // Send notification to all other users
      //await _sendNewUserNotification(name);

      return null;
    } catch (e) {
      print("AUTH EXCEPTION: "+e.toString());
      //return e.message;
    }
    return null;
  }


  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> _updateFCMToken() async {
    if (currentUser != null) {
      String? token = await _messaging.getToken();
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'fcmToken': token,
      });
    }
  }

  // Send notification to all users except the current one
  Future<void> _sendNewUserNotification(String name) async {
    // Get all users
    QuerySnapshot usersSnapshot = await _firestore.collection('users').get();

    // Extract FCM tokens, excluding the current user
    List<String> tokens = [];
    for (var doc in usersSnapshot.docs) {
      if (doc.id != currentUser!.uid && doc['fcmToken'] != null) {
        tokens.add(doc['fcmToken']);
      }
    }


    await _firestore.collection('notifications').add({
      'title': 'New User Joined',
      'body': '$name just joined our app!',
      'tokens': tokens,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

}