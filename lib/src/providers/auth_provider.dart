import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    FirebaseService.authStateChanges.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      await FirebaseService.signIn(email, password);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp(String email, String password, String username) async {
    try {
      _isLoading = true;
      notifyListeners();
      final user = await FirebaseService.signUp(email, password);
      if (user != null) {
        await FirebaseService.createUserDocument(user.uid, email, username);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();
      await FirebaseService.signOut();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> getNextScreen() async {
    if (_user == null) {
      return '/login';
    }

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).get();
    
    if (!userDoc.exists) {
      return '/edit-profile';
    }

    final userData = userDoc.data() as Map<String, dynamic>;

    if (userData['country'] == null) {
      return '/country-select';
    }

    if (userData['topics'] == null || (userData['topics'] as List).isEmpty) {
      return '/topics';
    }

    if (userData['followedSources'] == null || (userData['followedSources'] as List).isEmpty) {
      return '/news-sources';
    }

    if (userData['fullName'] == null || userData['fullName'].isEmpty) {
      return '/edit-profile';
    }

    return '/home';
  }
}