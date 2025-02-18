import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/firebase_service.dart';
import '../services/shared_preferences_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Create a timer to ensure minimum 3 seconds display
    final splashTimer = Future.delayed(const Duration(seconds: 3));
    
    // Load data if user is logged in
    final dataFuture = Future(() async {
      if (authProvider.isAuthenticated) {
        await _loadGNewsCategories();
        await _loadBookmarkedNewsIDs();
      }
    });

    // Wait for both timer and data loading to complete
    await Future.wait([splashTimer, dataFuture]);
    
    if (mounted) {
      await _navigateToNextScreen();
    }
  }

  Future<void> _loadGNewsCategories() async {
    try {
      final categories = await FirebaseService.getGNewsCategoriesFuture();
      // Save categories locally for global use
      await SharedPreferencesManager.saveGNewsCategories(categories.map((c) => c.toString()).toList());
    } catch (e) {
      print('Error loading GNews categories: $e');
    }
  }

  Future<void> _loadBookmarkedNewsIDs() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userID = authProvider.userID;
      if (userID != null) {
        final bookmarkedNewsIDs = await FirebaseService.getAllBookmarkIDs(userID: userID);
        print("Bookmarked news IDS $bookmarkedNewsIDs");
        // Save bookmarked news IDs locally for global use
        await SharedPreferencesManager.saveBookmarkedNewsID(bookmarkedNewsIDs);
      }
    } catch (e) {
      print('Error loading bookmarked news IDs: $e');
    }
  }

  Future<void> _navigateToNextScreen() async {
    final isFirstLaunch = await SharedPreferencesManager.getIsFirstLaunch();

    if (isFirstLaunch) {
      await SharedPreferencesManager.setIsFirstLaunch(false);
    }

    if (isFirstLaunch) {
      Navigator.pushReplacementNamed(context, '/onboarding');
    } else {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final nextScreen = await authProvider.getNextScreen();
      Navigator.pushReplacementNamed(context, nextScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/app_logo.png',
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            Text(
              'DashNews',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 48,
                fontWeight: FontWeight.w600,
                color: Colors.black, // Changed to black
              ),
            ),
          ],
        ),
      ),
    );
  }
}