import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'auth/login_screen.dart';
import 'auth/news_sources_screen.dart';
import 'auth/profile_screen.dart';
import 'auth/topics_screen.dart';
import 'home/home_screen.dart';
import 'notifications/notification_screen.dart';
import 'search/search_screen.dart';
import 'trending/trending_screen.dart';
import 'article/article_details_screen.dart';
import 'article/comments_screen.dart';
import 'settings/settings_controller.dart';
import 'splash/splash_screen.dart';
import 'settings/settings_screen.dart';
import 'onboarding/onboarding_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.settingsController});

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: settingsController,
      child: AnimatedBuilder(
        animation: settingsController,
        builder: (BuildContext context, Widget? child) {
          return MaterialApp(
            restorationScopeId: 'app',
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
            ],
            onGenerateTitle: (BuildContext context) => 'Flutter Demo',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              primaryColor: const Color(0xFF246BFD),
              scaffoldBackgroundColor: Colors.white,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 0,
              ),
              navigationBarTheme: NavigationBarThemeData(
                backgroundColor: Colors.white,
                indicatorColor: const Color(0xFF246BFD).withOpacity(0.1),
                labelTextStyle: MaterialStateProperty.all(
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
              cardColor: Colors.white,
              dividerColor: Colors.grey[200],
            ),
            darkTheme: ThemeData.dark().copyWith(
              primaryColor: const Color(0xFF246BFD),
              scaffoldBackgroundColor: const Color(0xFF1E1E1E),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF1E1E1E),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              navigationBarTheme: NavigationBarThemeData(
                backgroundColor: const Color(0xFF1E1E1E),
                indicatorColor: const Color(0xFF246BFD).withOpacity(0.1),
                labelTextStyle: MaterialStateProperty.all(
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
              cardColor: const Color(0xFF2C2C2C),
              dividerColor: Colors.white24,
              textTheme: const TextTheme(
                bodyLarge: TextStyle(color: Colors.white),
                bodyMedium: TextStyle(color: Colors.white),
                titleLarge: TextStyle(color: Colors.white),
                titleMedium: TextStyle(color: Colors.white),
                titleSmall: TextStyle(color: Colors.white),
              ),
            ),
            themeMode: settingsController.themeMode,
            initialRoute: SplashScreen.routeName,
            onGenerateRoute: (RouteSettings routeSettings) {
              return MaterialPageRoute<void>(
                settings: routeSettings,
                builder: (BuildContext context) {
                  switch (routeSettings.name) {
                    case SplashScreen.routeName:
                      return const SplashScreen();
                    case OnboardingScreen.routeName:
                      return const OnboardingScreen();
                    case LoginScreen.routeName:
                      return const LoginScreen();
                    case TopicsScreen.routeName:
                      return const TopicsScreen();
                    case NewsSourcesScreen.routeName:
                      return const NewsSourcesScreen();
                    case ProfileScreen.routeName:
                      return const ProfileScreen();
                    case HomeScreen.routeName:
                      return const HomeScreen();
                    case NotificationScreen.routeName:
                      return const NotificationScreen();
                    case SearchScreen.routeName:
                      return const SearchScreen();
                    case TrendingScreen.routeName:
                      return const TrendingScreen();
                    case ArticleDetailsScreen.routeName:
                      return const ArticleDetailsScreen();
                    case CommentsScreen.routeName:
                      return const CommentsScreen();
                    case SettingsScreen.routeName:
                      return const SettingsScreen();
                    default:
                      return const SplashScreen();
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}