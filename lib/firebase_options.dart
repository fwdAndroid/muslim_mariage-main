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
        return macos;
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCDoQvqoI4PiuFoB6EY2BIHgD9nlZH2LVo',
    appId: '1:563542385957:web:4aea8a4e0b9220c57f26cc',
    messagingSenderId: '563542385957',
    projectId: 'osarmayalsia',
    authDomain: 'osarmayalsia.firebaseapp.com',
    storageBucket: 'osarmayalsia.appspot.com',
    measurementId: 'G-1L416FH32N',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB5GHMhawsVYY3QAbV-PU5HtN1i5M_WW48',
    appId: '1:563542385957:android:8770efb9f8af6f1f7f26cc',
    messagingSenderId: '563542385957',
    projectId: 'osarmayalsia',
    storageBucket: 'osarmayalsia.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCRoa9SjHnm-vDk6wQECsVLcn7n4t27WDU',
    appId: '1:563542385957:ios:b17efe61fc5ced637f26cc',
    messagingSenderId: '563542385957',
    projectId: 'osarmayalsia',
    storageBucket: 'osarmayalsia.appspot.com',
    androidClientId: '563542385957-3iip7qfmaa5kd98ipgoqsebkv4m8uvv1.apps.googleusercontent.com',
    iosClientId: '563542385957-967k3v460vlg3hlc1pl421152jp32ugh.apps.googleusercontent.com',
    iosBundleId: 'com.example.muslimMariage',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCRoa9SjHnm-vDk6wQECsVLcn7n4t27WDU',
    appId: '1:563542385957:ios:b17efe61fc5ced637f26cc',
    messagingSenderId: '563542385957',
    projectId: 'osarmayalsia',
    storageBucket: 'osarmayalsia.appspot.com',
    androidClientId: '563542385957-3iip7qfmaa5kd98ipgoqsebkv4m8uvv1.apps.googleusercontent.com',
    iosClientId: '563542385957-967k3v460vlg3hlc1pl421152jp32ugh.apps.googleusercontent.com',
    iosBundleId: 'com.example.muslimMariage',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCDoQvqoI4PiuFoB6EY2BIHgD9nlZH2LVo',
    appId: '1:563542385957:web:45895aa751942df77f26cc',
    messagingSenderId: '563542385957',
    projectId: 'osarmayalsia',
    authDomain: 'osarmayalsia.firebaseapp.com',
    storageBucket: 'osarmayalsia.appspot.com',
    measurementId: 'G-DSL2N61S1C',
  );
}
