import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../auth_manager.dart';
import '../base_auth_user_provider.dart';
import '../../flutter_flow/flutter_flow_util.dart';

import '/backend/backend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stream_transform/stream_transform.dart';
import 'firebase_auth_manager.dart';

export 'firebase_auth_manager.dart';

final _authManager = FirebaseAuthManager();
FirebaseAuthManager get authManager => _authManager;

// Current user document from Firestore
DocumentSnapshot? currentUserDocument;

String get currentUserEmail =>
    currentUserDocument?.get('email') ?? currentUser?.email ?? '';

String get currentUserUid => currentUser?.uid ?? '';

String get currentUserDisplayName =>
    currentUserDocument?.get('displayName') ?? currentUser?.displayName ?? '';

String get currentUserPhoto =>
    currentUserDocument?.get('photoUrl') ?? currentUser?.photoUrl ?? '';

String get currentPhoneNumber =>
    currentUserDocument?.get('phone') ?? currentUser?.phoneNumber ?? '';

String get currentJwtToken => _currentJwtToken ?? '';

bool get currentUserEmailVerified => currentUser?.emailVerified ?? false;

/// Create a Stream that listens to the current user's JWT Token, since Firebase
/// generates a new token every hour.
String? _currentJwtToken;
final jwtTokenStream = FirebaseAuth.instance
    .idTokenChanges()
    .map((user) async => _currentJwtToken = await user?.getIdToken())
    .asBroadcastStream();

/// Stream that combines auth state changes with user document updates
final authenticatedUserStream = FirebaseAuth.instance
    .authStateChanges()
    .asyncMap((user) async {
      if (user != null) {
        try {
          currentUserDocument = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
        } catch (e) {
          print('Error fetching user document: $e');
          currentUserDocument = null;
        }
      } else {
        currentUserDocument = null;
      }
      return user;
    })
    .asBroadcastStream();
