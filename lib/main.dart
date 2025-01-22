import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'DashWave News',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Roboto',
        ),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            if (authProvider.isLoading) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            if (authProvider.isAuthenticated) {
              return FutureBuilder<String?>(
                future: UserPreferencesService.getNextScreen(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasData && snapshot.data != null) {
                    switch (snapshot.data) {
                      case '/country-select':
                        return const CountrySelectScreen();
                      case '/topics':
                        return const TopicsScreen();
                      case '/news-sources':
                        return const NewsSourcesScreen();
                      case ProfileScreen.routeName:
                        return const ProfileScreen();
                      case '/edit-profile':
                        return const EditProfileScreen(
                          currentUsername: '',
                          currentFullName: '',
                          currentEmail: '',
                          currentPhoneNumber: '',
                        );
                      default:
                        return const HomeScreen();
                    }
                  }

                  return const HomeScreen();
                },
              );
            }
            
            return const SplashScreen();
          },
        ),
        routes: {
          '/onboarding': (context) => const OnboardingScreen(),
          '/signup': (context) => const SignupScreen(),
          '/login': (context) => const LoginScreen(),
          '/country-select': (context) => const CountrySelectScreen(),
          '/topics': (context) => const TopicsScreen(),
          '/news-sources': (context) => const NewsSourcesScreen(),
          ProfileScreen.routeName: (context) => const ProfileScreen(),
          '/edit-profile': (context) => const EditProfileScreen(
            currentUsername: '',
            currentFullName: '',
            currentEmail: '',
            currentPhoneNumber: '',
          ),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}