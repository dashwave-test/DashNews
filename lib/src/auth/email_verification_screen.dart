import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'country_select_screen.dart';
import '../config/feature_flags.dart';

class EmailVerificationScreen extends StatefulWidget {
  static const routeName = '/email-verification';

  const EmailVerificationScreen({Key? key}) : super(key: key);

  @override
  _EmailVerificationScreenState createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool isEmailVerified = false;
  Timer? timer;
  Timer? countdownTimer;
  late AuthProvider _authProvider;
  int _countdown = 30;

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    isEmailVerified = _authProvider.user?.emailVerified ?? false;

    if (!isEmailVerified && !FeatureFlags.isFeatureDisabled(FeatureFlags.EMAIL_VERIFICATION)) {
      sendVerificationEmail();
      startCountdown();
    } else {
      navigateToNextScreen();
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    countdownTimer?.cancel();
    super.dispose();
  }

  void startCountdown() {
    setState(() {
      _countdown = 30;
    });
    countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (_countdown > 0) {
          setState(() {
            _countdown--;
          });
        } else {
          countdownTimer?.cancel();
          checkEmailVerified();
        }
      },
    );
    timer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => checkEmailVerified(),
    );
  }

  Future<void> checkEmailVerified() async {
    await _authProvider.checkEmailVerification();

    setState(() {
      isEmailVerified = _authProvider.user?.emailVerified ?? false;
    });

    if (isEmailVerified || FeatureFlags.isFeatureDisabled(FeatureFlags.EMAIL_VERIFICATION)) {
      timer?.cancel();
      countdownTimer?.cancel();
      navigateToNextScreen();
    } else {
      startCountdown();
    }
  }

  Future<void> sendVerificationEmail() async {
    try {
      await _authProvider.user?.sendEmailVerification();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending verification email: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> navigateToNextScreen() async {
    String nextScreen = await _authProvider.getNextScreen();
    if (!mounted) return;
    
    switch (nextScreen) {
      case '/country-select':
        Navigator.of(context).pushReplacementNamed(CountrySelectScreen.routeName);
        break;
      case '/topics':
        // Navigate to topics selection screen
        break;
      case '/news-sources':
        // Navigate to news sources selection screen
        break;
      case '/edit-profile':
        // Navigate to edit profile screen
        break;
      case '/home':
        // Navigate to home screen
        break;
      default:
        Navigator.of(context).pushReplacementNamed(CountrySelectScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Verify Email'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'A verification email has been sent to your email address.',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              CircularProgressIndicator(
                value: _countdown / 30,
              ),
              const SizedBox(height: 24),
              Text(
                'Next check in $_countdown seconds',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF246BFD),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  sendVerificationEmail();
                  startCountdown();
                },
                child: const Text(
                  'Resend Email',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
}