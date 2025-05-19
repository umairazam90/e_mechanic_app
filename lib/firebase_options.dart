import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

final class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:

      case TargetPlatform.iOS:

      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
      apiKey: "AIzaSyDXkns_nWrD6kqHt_9DnG7bhTmImgTNwio",
      authDomain: "e-mechanic-3e163.firebaseapp.com",
      projectId: "e-mechanic-3e163",
      storageBucket: "e-mechanic-3e163.firebasestorage.app",
      messagingSenderId: "552160032324",
      appId: "1:552160032324:web:1ade55f1f33358ae652e11"
  );
}