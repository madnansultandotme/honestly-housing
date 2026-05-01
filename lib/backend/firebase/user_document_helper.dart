import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Creates a user document in Firestore if it doesn't exist
/// Updates lastLoginAt if it does exist
Future<void> maybeCreateUser(User user) async {
  final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
  final docSnapshot = await userDoc.get();

  if (!docSnapshot.exists) {
    // Create new user document with default values
    await userDoc.set({
      'uid': user.uid,
      'email': user.email ?? '',
      'displayName': user.displayName ?? user.email?.split('@')[0] ?? 'User',
      'role': 'client', // Default role - should be updated by admin
      'builderOrgId': null,
      'projectIds': [],
      'phone': user.phoneNumber ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
      'notificationPreferences': {
        'email': true,
        'push': true,
      },
    });
  } else {
    // Update last login timestamp
    await userDoc.update({
      'lastLoginAt': FieldValue.serverTimestamp(),
    });
  }
}

/// Updates user document fields
Future<void> updateUserDocument({
  String? email,
  String? displayName,
  String? photoUrl,
  String? phone,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final updates = <String, dynamic>{
    'updatedAt': FieldValue.serverTimestamp(),
  };

  if (email != null) updates['email'] = email;
  if (displayName != null) updates['displayName'] = displayName;
  if (photoUrl != null) updates['photoUrl'] = photoUrl;
  if (phone != null) updates['phone'] = phone;

  await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .update(updates);
}
