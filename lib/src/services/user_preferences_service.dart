import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/edit_profile_screen.dart';

class UserPreferencesService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<Map<String, dynamic>?> getUserPreferences() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final docSnapshot = await _firestore.collection('users').doc(user.uid).get();
        if (docSnapshot.exists) {
          return docSnapshot.data();
        }
      } catch (e) {
        print('Error getting user preferences: $e');
      }
    }
    return null;
  }

  static Future<String?> getNextScreen() async {
    final preferences = await getUserPreferences();
    
    if (preferences == null) {
      return null;
    }

    if (!preferences.containsKey('country') || preferences['country'] == null) {
      return '/country-select';
    }

    if (!preferences.containsKey('topics') || 
        preferences['topics'] == null || 
        (preferences['topics'] as List).isEmpty) {
      return '/topics';
    }

    if (!preferences.containsKey('followedSources') || 
        preferences['followedSources'] == null || 
        (preferences['followedSources'] as List).isEmpty) {
      return '/news-sources';
    }

    if (!preferences.containsKey('fullName') || 
        preferences['fullName'] == null || 
        preferences['fullName'].toString().isEmpty ||
        !preferences.containsKey('email') || 
        preferences['email'] == null || 
        preferences['email'].toString().isEmpty) {
      return EditProfileScreen.routeName;
    }

    return null;
  }
}