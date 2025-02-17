import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../auth/login_screen.dart';
import '../auth/email_verification_screen.dart';
import '../auth/country_select_screen.dart';
import '../auth/topics_screen.dart';
import '../auth/news_sources_screen.dart';
import '../auth/edit_profile_screen.dart';
import '../home/home_screen.dart';
import '../config/feature_flags.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<User?> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<UserCredential?> signUp(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
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
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();
      await _auth.signOut();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> getNextScreen() async {
    if (_user == null) {
      return LoginScreen.routeName;
    }

    try {
      // Fetch the latest user data from Firestore
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(_user!.uid).get();
      
      if (!userDoc.exists) {
        return CountrySelectScreen.routeName;
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      // Reload the user to get the latest email verification status
      await _user!.reload();
      _user = _auth.currentUser;

      if (!_user!.emailVerified && !FeatureFlags.isFeatureDisabled(FeatureFlags.EMAIL_VERIFICATION)) {
        return EmailVerificationScreen.routeName;
      }

      print(userData['followedTopics']);

      if (userData['country'] == null || userData['country'].toString().isEmpty) {
        return CountrySelectScreen.routeName;
      }
      if (userData['followedTopics'] == null || (userData['followedTopics'] as List).isEmpty) {
        return TopicsScreen.routeName;
      }
      if (!FeatureFlags.isFeatureDisabled(FeatureFlags.DISABLE_NEWS_SOURCES)) {
        if (userData['followedSources'] == null || (userData['followedSources'] as List).isEmpty) {
          return NewsSourcesScreen.routeName;
        }
      }
      if (userData['fullName'] == null || userData['fullName'].toString().isEmpty) {
        return EditProfileScreen.routeName;
      }
      return HomeScreen.routeName;
    } catch (e) {
      print('Error in getNextScreen: $e');
      return CountrySelectScreen.routeName;
    }
  }

  Future<void> checkEmailVerification() async {
    if (_user != null && !_user!.emailVerified && !FeatureFlags.isFeatureDisabled(FeatureFlags.EMAIL_VERIFICATION)) {
      await _user!.reload();
      _user = FirebaseAuth.instance.currentUser;
      notifyListeners();
    }
  }
}