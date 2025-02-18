import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:provider/provider.dart';
import 'src/splash/splash_screen.dart';
import 'src/onboarding/onboarding_screen.dart';
import 'src/auth/login_screen.dart';
import 'src/auth/signup_screen.dart';
import 'src/home/home_screen.dart';
import 'src/providers/auth_provider.dart';
import 'src/services/user_preferences_service.dart';
import 'src/auth/country_select_screen.dart';
import 'src/auth/topics_screen.dart';
import 'src/auth/news_sources_screen.dart';
import 'src/auth/edit_profile_screen.dart';
import 'src/auth/profile_screen.dart';
import 'src/trending/trending_screen.dart';
import 'src/auth/email_verification_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'src/services/network_service.dart';
import 'src/config/feature_flags.dart';

void main() async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    
    // Initialize Firebase Crashlytics
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    
    WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    
    // Set the flag to use mock APIs
    NetworkService.setUseMockGoogleNewsApi(true);
    
    runApp(const MyApp());
  }, (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        Provider<FeatureFlags>.value(value: FeatureFlags()),
      ],
      child: MaterialApp(
        title: 'DashNews',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Montserrat',
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/signup': (context) => const SignupScreen(),
          '/login': (context) => const LoginScreen(),
          EmailVerificationScreen.routeName: (context) => const EmailVerificationScreen(),
          '/country-select': (context) => const CountrySelectScreen(),
          '/topics': (context) => const TopicsScreen(),
          '/news-sources': (context) => const NewsSourcesScreen(),
          ProfileScreen.routeName: (context) => const ProfileScreen(),
          '/edit-profile': (context) => EditProfileScreen(
            currentUsername: '',
            currentFullName: '',
            currentEmail: '',
            currentPhoneNumber: '',
          ),
          '/home': (context) => const HomeScreen(),
          TrendingScreen.routeName: (context) => const TrendingScreen(),
        },
      ),
    );
  }
}