import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'src/splash/splash_screen.dart';
import 'src/auth/login_screen.dart';
import 'src/onboarding/onboarding_screen.dart';
import 'src/auth/signup_screen.dart';
import 'src/home/home_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DashWave News',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        primaryColor: const Color(0xFF246BFD),
      ),
      home: const SplashScreen(),
      routes: {
        LoginScreen.routeName: (context) => const LoginScreen(),
        OnboardingScreen.routeName: (context) => const OnboardingScreen(),
        SignupScreen.routeName: (context) => const SignupScreen(),
        HomeScreen.routeName: (context) => const HomeScreen(),
      },
    );
  }
}