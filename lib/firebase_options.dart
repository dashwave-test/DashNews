import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'No Web Firebase options have been configured. Contact support.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'MacOS Firebase options have not been configured. Contact support.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'Windows Firebase options have not been configured. Contact support.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'Linux Firebase options have not been configured. Contact support.',
        );
      default:
        throw UnsupportedError(
          'Unknown platform ${defaultTargetPlatform} firebase options have not been configured. Contact support.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBQWxvVUFVNDfFHPqWqDLvWBbziaXCZoro',
    appId: '1:1051521729842:android:c3a1a0b2b9e7c2a4e9c5b0',
    messagingSenderId: '1051521729842',
    projectId: 'dashwave-news-app',
    storageBucket: 'dashwave-news-app.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAWCQMvWQNGJnUJzQxWBNXdwVjLkNxGU0k',
    appId: '1:1051521729842:ios:3a1a0b2b9e7c2a4e9c5b0',
    messagingSenderId: '1051521729842',
    projectId: 'dashwave-news-app',
    storageBucket: 'dashwave-news-app.appspot.com',
    iosClientId: '1051521729842-abc123def456.apps.googleusercontent.com',
    iosBundleId: 'com.example.dashwaveNews',
  );
}