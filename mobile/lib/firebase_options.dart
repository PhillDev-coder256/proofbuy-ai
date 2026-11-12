import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      case TargetPlatform.linux:
        return linux;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDXL46uWHXvifF7l7Oles5Lqp0qUKSkMKg',
    appId: '1:822500637310:web:d1084211d83045b940362f',
    messagingSenderId: '822500637310',
    projectId: 'proofbuyai',
    authDomain: 'proofbuyai.firebaseapp.com',
    storageBucket: 'proofbuyai.firebasestorage.app',
    measurementId: 'G-4DVKRG1269',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyADYPvgxHx7O8d37WTjnMXO2oWjVYydInI',
    appId: '1:822500637310:android:ad448197e4810ea940362f',
    messagingSenderId: '822500637310',
    projectId: 'proofbuyai',
    storageBucket: 'proofbuyai.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBzgRN9Y9MAfIQPRwcjic6c78aZaT6jp8w',
    appId: '1:822500637310:ios:31a090c5600e8d2d40362f',
    messagingSenderId: '822500637310',
    projectId: 'proofbuyai',
    storageBucket: 'proofbuyai.firebasestorage.app',
    iosClientId: '822500637310-qpebctht4avia9g94qnafss4m51fb6uv.apps.googleusercontent.com',
    iosBundleId: 'com.proofbuy.proofbuyAi',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBzgRN9Y9MAfIQPRwcjic6c78aZaT6jp8w',
    appId: '1:822500637310:ios:31a090c5600e8d2d40362f',
    messagingSenderId: '822500637310',
    projectId: 'proofbuyai',
    storageBucket: 'proofbuyai.firebasestorage.app',
    iosClientId: '822500637310-qpebctht4avia9g94qnafss4m51fb6uv.apps.googleusercontent.com',
    iosBundleId: 'com.proofbuy.proofbuyAi',
  );
  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyDXL46uWHXvifF7l7Oles5Lqp0qUKSkMKg',
    appId: '1:822500637310:linux:placeholder',
    messagingSenderId: '822500637310',
    projectId: 'proofbuyai',
    storageBucket: 'proofbuyai.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDXL46uWHXvifF7l7Oles5Lqp0qUKSkMKg',
    appId: '1:822500637310:web:4750fe69a577eae840362f',
    messagingSenderId: '822500637310',
    projectId: 'proofbuyai',
    authDomain: 'proofbuyai.firebaseapp.com',
    storageBucket: 'proofbuyai.firebasestorage.app',
    measurementId: 'G-NWTGFSXWXT',
  );
}
