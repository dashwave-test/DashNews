import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up with email and password
  Future<UserCredential?> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create user document in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'username': email.split('@')[0],
        'fullName': '',
        'bio': '',
        'website': '',
        'phone': '',
        'followers': 0,
        'following': 0,
        'newsCount': 0,
        'profilePicture': '',
        'savedArticles': [],
        'followedTopics': [],
        'followedSources': [],
        'country': '',
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }

  // Get the next screen to show based on user's completion status
  Future<String> getNextScreen(String userId) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null && !currentUser.emailVerified) {
        return 'email_verification';
      }

      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        if (userData['country'] == null || userData['country'].toString().isEmpty) {
          return 'country';
        }
        if (userData['followedTopics'] == null || (userData['followedTopics'] as List).isEmpty) {
          return 'topics';
        }
        if (userData['followedSources'] == null || (userData['followedSources'] as List).isEmpty) {
          return 'news_sources';
        }
        if (userData['fullName'] == null || userData['fullName'].toString().isEmpty) {
          return 'edit-profile';
        }
        return 'home';
      }
      return 'country';
    } catch (e) {
      return 'country';
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update last login timestamp
      await _firestore.collection('users').doc(userCredential.user!.uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}