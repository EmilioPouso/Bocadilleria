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
        return android;
      case TargetPlatform.macOS:
        return android;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA5xEEmDM8vmyZ81YyhcyXGfaw5LDqDZe8',
    appId: '1:1054240625208:web:9be70b32fdcac8d11f8ccd',
    messagingSenderId: '1054240625208',
    projectId: 'bocadilleria-a5c81',
    authDomain: 'bocadilleria-a5c81.firebaseapp.com',
    storageBucket: 'bocadilleria-a5c81.firebasestorage.app',
    measurementId: 'G-XXXXXXXXXX',
    databaseURL:
        'https://bocadilleria-a5c81-default-rtdb.europe-west1.firebasedatabase.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA5xEEmDM8vmyZ81YyhcyXGfaw5LDqDZe8',
    appId: '1:1054240625208:android:9be70b32fdcac8d11f8ccd',
    messagingSenderId: '1054240625208',
    projectId: 'bocadilleria-a5c81',
    storageBucket: 'bocadilleria-a5c81.firebasestorage.app',
    databaseURL:
        'https://bocadilleria-a5c81-default-rtdb.europe-west1.firebasedatabase.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA5xEEmDM8vmyZ81YyhcyXGfaw5LDqDZe8',
    appId: '1:1054240625208:web:9be70b32fdcac8d11f8ccd',
    messagingSenderId: '1054240625208',
    projectId: 'bocadilleria-a5c81',
    authDomain: 'bocadilleria-a5c81.firebaseapp.com',
    storageBucket: 'bocadilleria-a5c81.firebasestorage.app',
    databaseURL:
        'https://bocadilleria-a5c81-default-rtdb.europe-west1.firebasedatabase.app',
  );
}
