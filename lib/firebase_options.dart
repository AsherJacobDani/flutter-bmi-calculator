// File generated based on Firebase project: bmi-calculator-8cdf5
// Android package: com.asher.bmi
// iOS bundle ID: com.asher.bmi

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macOS - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  /// Firebase options for Android (package: com.asher.bmi)
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB4ZkPLo9BlN-3cULHyhUGkKINKPFoDKH8',
    appId: '1:259802315789:android:6688fb7c6cda732773a944',
    messagingSenderId: '259802315789',
    projectId: 'bmi-calculator-8cdf5',
    storageBucket: 'bmi-calculator-8cdf5.firebasestorage.app',
  );

  /// Firebase options for iOS (bundle ID: com.asher.bmi)
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBtM9L5qOfb4dQmZWpT8_NrKuwqrK-00ts',
    appId: '1:259802315789:ios:f89e0e4199577b3673a944',
    messagingSenderId: '259802315789',
    projectId: 'bmi-calculator-8cdf5',
    storageBucket: 'bmi-calculator-8cdf5.firebasestorage.app',
    iosBundleId: 'com.asher.bmi',
  );
}
