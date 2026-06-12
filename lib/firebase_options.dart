// File ini di-generate otomatis oleh FlutterFire CLI.
// Jalankan: flutterfire configure
// Lalu replace isi file ini dengan hasil generate-nya.

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions tidak tersedia untuk platform ini.',
        );
    }
  }

  // =============================================
  // GANTI NILAI-NILAI INI DENGAN KONFIGURASI
  // FIREBASE PROJECT KAMU SENDIRI!
  // Cara: jalankan `flutterfire configure` di terminal
  // =============================================

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: 'YOUR_WEB_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCDmf4Mkbmk0LrLFa_c5tpkAFLwbilgRFg',
    appId: '1:938019782155:android:7ead75ee7e2a55ca62510e',
    messagingSenderId: '938019782155',
    projectId: 'db-jurnalcuan',
    authDomain: 'db-jurnalcuan.firebaseapp.com',
    storageBucket: 'db-jurnalcuan.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    iosBundleId: 'com.example.jurnalCuan',
  );
}