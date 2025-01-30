import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static User? get currentUser => _auth.currentUser;

  /// Fetches all Google News categories from Firestore
  ///
  /// Returns a Stream of QuerySnapshot that contains the category documents
  /// Each document has:
  /// * id (String) - The unique identifier for the category
  /// * name (String) - The display name of the category
  /// * icon (String?) - Optional URL for the category icon
  static Stream<QuerySnapshot> getGNewsCategories() {
    try {
      return _firestore
          .collection('gnews_categories')
          .orderBy('name')
          .snapshots();
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(
        e,
        stack,
        reason: 'Error fetching GNews categories',
      );
      rethrow;
    }
  }

  /// Fetches all Google News categories from Firestore as a Future
  ///
  /// Returns a Future<List<Map<String, dynamic>>> containing the category data
  /// Each map has:
  /// * id (String) - The unique identifier for the category
  /// * name (String) - The display name of the category
  /// * icon (String?) - Optional URL for the category icon
  static Future<List<Map<String, dynamic>>> getGNewsCategoriesFuture() async {
    try {
      final snapshot = await _firestore
          .collection('gnews_categories')
          .orderBy('name')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] as String,
          'icon': data['icon'] as String?,
        };
      }).toList();
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(
        e,
        stack,
        reason: 'Error fetching GNews categories',
      );
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
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Error during sign up');
      print('Error during sign up: $e');
      rethrow;
    }
  }

  static Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Error during sign in');
      print('Error during sign in: $e');
      rethrow;
    }
  }

  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Error during sign out');
      print('Error during sign out: $e');
      rethrow;
    }
  }

  static Future<void> createUserDocument(String uid, String email, String username) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'email': email,
        'username': username,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Error creating user document');
      print('Error creating user document: $e');
      rethrow;
    }
  }

  static Future<void> logCustomError(String message, {Map<String, dynamic>? parameters}) async {
    await FirebaseCrashlytics.instance.recordError(
      Exception(message),
      StackTrace.current,
      reason: 'Custom error',
      information: parameters != null ? [parameters.toString()] : [],
    );
  }
}