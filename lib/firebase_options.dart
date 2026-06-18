// =============================================================
// FILE: lib/firebase_options.dart
// ⚠️ WAJIB DIGANTI! Jalankan: flutterfire configure
// File ini akan otomatis di-overwrite dengan nilai asli.
// JANGAN jalankan app sebelum file ini diganti dengan benar.
// =============================================================

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) throw UnsupportedError('Web belum disetup');
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError('Platform tidak didukung');
    }
  }

  // GANTI SEMUA NILAI INI dari Firebase Console > Project Settings
  static const FirebaseOptions android = FirebaseOptions(
    apiKey:            'GANTI_API_KEY',
    appId:             'GANTI_APP_ID',
    messagingSenderId: 'GANTI_SENDER_ID',
    projectId:         'GANTI_PROJECT_ID',
    storageBucket:     'GANTI_STORAGE_BUCKET',
  );
}
