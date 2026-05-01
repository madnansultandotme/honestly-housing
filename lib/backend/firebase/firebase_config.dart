import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyBJ9n3Mjqx0Ol6FSg35i8fTFRxnnRjzHmE",
            authDomain: "honestlyhousing-4d7f0.firebaseapp.com",
            projectId: "honestlyhousing-4d7f0",
            storageBucket: "honestlyhousing-4d7f0.firebasestorage.app",
            messagingSenderId: "656663435593",
            appId: "1:656663435593:web:db9225035ee4c73ec4e298",
            measurementId: "G-H602PEL8RZ"));
  } else {
    await Firebase.initializeApp();
  }
}
