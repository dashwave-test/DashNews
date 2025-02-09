import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../models/news_category.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Error signing in with email and password');
      rethrow;
    }
  }

  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Error signing out');
      rethrow;
    }
  }

  static Future<List<NewsCategory>> getGNewsCategoriesFuture() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('gnews_categories').get();
      return querySnapshot.docs.map((doc) => NewsCategory.fromFirestore(doc)).toList();
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Error fetching GNews categories');
      rethrow;
    }
  }

  static Future<void> updateUserFollowedTopics(String userId, List<String> followedTopics) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'followedTopics': followedTopics,
      });
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Error updating user followed topics');
      rethrow;
    }
  }

  static Future<List<String>> getUserFollowedTopics(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        return List<String>.from(userData['followedTopics'] ?? []);
      }
      return [];
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Error fetching user followed topics');
      rethrow;
    }
  }

  static Future<void> updateUserCountry(String userId, String country) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'country': country,
      });
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Error updating user country');
      rethrow;
    }
  }

  static Future<String?> getUserCountry(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        return userData['country'] as String?;
      }
      return null;
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Error fetching user country');
      rethrow;
    }
  }

  static Future<User?> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Error signing up');
      rethrow;
    }
  }

  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Error resetting password');
      rethrow;
    }
  }

  static Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).update(data);
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Error updating user profile');
      rethrow;
    }
  }

  static Future<void> createUserDocument(String userId, String email, String username) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'email': email,
        'username': username,
        'createdAt': FieldValue.serverTimestamp(),
        'followedSources': [],
        'followedTopics': [],
      });
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Error creating user document');
      rethrow;
    }
  }
}