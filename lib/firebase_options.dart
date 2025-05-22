import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] untuk digunakan dengan aplikasi Anda.
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
          'DefaultFirebaseOptions telah dikonfigurasi untuk iOS dan Android saja.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions telah dikonfigurasi untuk iOS dan Android saja.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions telah dikonfigurasi untuk iOS dan Android saja.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions tidak dikonfigurasi untuk platform ini.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCDZkysGNSA6adZHQsKw0hY2uEgpcBRXHg',
    appId: '1:828382308592:android:1d2cf25e91ce54598a7a35',
    messagingSenderId: '828382308592',
    projectId: 'flutter-1f100',
    authDomain: 'YOUR_AUTH_DOMAIN',
    storageBucket: 'flutter-1f100.firebasestorage.app',
    measurementId: 'YOUR_MEASUREMENT_ID',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCDZkysGNSA6adZHQsKw0hY2uEgpcBRXHg',
    appId: '1:828382308592:android:1d2cf25e91ce54598a7a35',
    messagingSenderId: '828382308592',
    projectId: 'flutter-1f100',
    storageBucket: 'flutter-1f100.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCDZkysGNSA6adZHQsKw0hY2uEgpcBRXHg',
    appId: '1:828382308592:android:1d2cf25e91ce54598a7a35',
    messagingSenderId: '828382308592',
    projectId: 'flutter-1f100',
    storageBucket: 'flutter-1f100.firebasestorage.app',
    iosClientId: 'YOUR_IOS_CLIENT_ID',
    iosBundleId: 'YOUR_IOS_BUNDLE_ID',
  );
}