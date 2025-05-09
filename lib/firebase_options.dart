// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        return windows;
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

  static FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBLPXSx83_5rBSr8XWN41WnQEYoaPfLjtM',
    appId: '1:899708379709:web:808bc5cc7ce74cbeb38054',
    messagingSenderId: '899708379709',
    projectId: 'pharmanow-754a7',
    authDomain: 'pharmanow-754a7.firebaseapp.com',
    storageBucket: 'pharmanow-754a7.firebasestorage.app',
    measurementId: 'G-J9Y4XV5MQ2',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAKWX44ZDBZuV9Yj_rp1kL4Ydn9HbQuzfg',
    appId: '1:899708379709:android:c0899fc0febcd747b38054',
    messagingSenderId: '899708379709',
    projectId: 'pharmanow-754a7',
    storageBucket: 'pharmanow-754a7.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBq9uimDRQ33liR8jMOy0JkJlttgO0Xhhg',
    appId: '1:899708379709:ios:76c13c27305280cdb38054',
    messagingSenderId: '899708379709',
    projectId: 'pharmanow-754a7',
    storageBucket: 'pharmanow-754a7.firebasestorage.app',
    iosBundleId: 'com.example.pharmaNow',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBLPXSx83_5rBSr8XWN41WnQEYoaPfLjtM',
    appId: '1:899708379709:web:231e1fd331ecb1e1b38054',
    messagingSenderId: '899708379709',
    projectId: 'pharmanow-754a7',
    authDomain: 'pharmanow-754a7.firebaseapp.com',
    storageBucket: 'pharmanow-754a7.firebasestorage.app',
    measurementId: 'G-M6RJ7T6RSM',
  );
}
