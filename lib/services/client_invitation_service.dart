import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

/// Service to handle client account creation and project invitation
class ClientInvitationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Generate a random password for the client
  String _generatePassword() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%';
    final random = Random.secure();
    return List.generate(12, (index) => chars[random.nextInt(chars.length)]).join();
  }

  /// Create client account and add to project
  /// Returns: Map with 'success', 'password', 'userId', and 'message'
  Future<Map<String, dynamic>> inviteClientToProject({
    required String clientEmail,
    required String clientName,
    required String projectId,
    required String projectName,
    String? invitedBy,
  }) async {
    try {
      print('========================================');
      print('INVITE CLIENT TO PROJECT - START');
      print('========================================');
      print('Client Email: $clientEmail');
      print('Client Name: $clientName');
      print('Project ID: $projectId');
      print('Project Name: $projectName');
      print('Invited By: $invitedBy');
      print('Current Auth User: ${_auth.currentUser?.uid}');
      print('Current Auth Email: ${_auth.currentUser?.email}');
      print('----------------------------------------');
      
      // Validate email
      if (clientEmail.isEmpty || !clientEmail.contains('@')) {
        return {
          'success': false,
          'message': 'Invalid email address',
        };
      }

      print('Searching for existing user with email: ${clientEmail.toLowerCase().trim()}');
      
      // Check if user already exists in Firestore
      final existingUserQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: clientEmail.toLowerCase().trim())
          .limit(1)
          .get();

      print('Query completed. Found ${existingUserQuery.docs.length} users');
      
      String userId;
      String password = '';
      bool isNewUser = false;

      if (existingUserQuery.docs.isNotEmpty) {
        // User exists in Firestore - just add to project
        userId = existingUserQuery.docs.first.id;
        final userData = existingUserQuery.docs.first.data();
        
        print('=== Existing user found ===');
        print('User ID: $userId');
        print('User email: ${userData['email']}');
        print('User role: ${userData['role']}');
        print('Current auth user: ${_auth.currentUser?.uid}');
        print('Current auth email: ${_auth.currentUser?.email}');
        
        // Verify user is a client
        if (userData['role'] != 'client') {
          return {
            'success': false,
            'message': 'This email is registered as a ${userData['role']}. Cannot add to project.',
          };
        }

        // Check if already in project
        final userProjectIds = (userData['projectIds'] as List?)?.cast<String>() ?? [];
        print('User current projects: $userProjectIds');
        
        if (userProjectIds.contains(projectId)) {
          return {
            'success': false,
            'message': 'This client is already added to this project.',
          };
        }

        try {
          // Add project to user's projectIds
          print('Updating user document to add project $projectId...');
          await _firestore.collection('users').doc(userId).update({
            'projectIds': FieldValue.arrayUnion([projectId]),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          print('✓ User document updated');

          // Add user to project's clientIds
          print('Updating project document to add client $userId...');
          await _firestore.collection('projects').doc(projectId).update({
            'clientIds': FieldValue.arrayUnion([userId]),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          print('✓ Project document updated');
          print('=== Existing user added successfully ===');
        } catch (e) {
          print('=== ERROR adding existing user ===');
          print('Error: $e');
          print('Error type: ${e.runtimeType}');
          if (e is FirebaseException) {
            print('Firebase error code: ${e.code}');
            print('Firebase error message: ${e.message}');
          }
          print('================================');
          throw e;
        }

        return {
          'success': true,
          'userId': userId,
          'isNewUser': false,
          'existingUser': true,
          'userName': userData['displayName'] ?? clientName,
          'message': 'Existing client "${userData['displayName'] ?? clientName}" added to project successfully',
        };
      } else {
        // Check if user exists in Firebase Auth but not in Firestore
        bool authUserExists = false;
        try {
          // Try to fetch sign-in methods for this email
          final signInMethods = await _auth.fetchSignInMethodsForEmail(
            clientEmail.toLowerCase().trim(),
          );
          authUserExists = signInMethods.isNotEmpty;
        } catch (e) {
          // If error, assume user doesn't exist
          authUserExists = false;
        }

        if (authUserExists) {
          // User exists in Auth but not in Firestore
          // This is an edge case - user might have been created but Firestore doc failed
          return {
            'success': false,
            'message': 'This email is already registered. Please ask the user to sign in first, or contact support.',
          };
        }

        // Create new user account
        isNewUser = true;
        password = _generatePassword();
        
        // Create Firebase Auth account
        UserCredential userCredential;
        try {
          userCredential = await _auth.createUserWithEmailAndPassword(
            email: clientEmail.toLowerCase().trim(),
            password: password,
          );
          userId = userCredential.user!.uid;
          
          // DON'T sign out yet - create the Firestore document while authenticated as the new user
          
        } catch (authError) {
          if (authError.toString().contains('email-already-in-use')) {
            return {
              'success': false,
              'message': 'Email already in use. Please use a different email.',
            };
          }
          throw authError;
        }

        // Create user document in Firestore while authenticated as the new user
        try {
          print('=== Starting Firestore operations ===');
          print('Current auth user: ${_auth.currentUser?.uid}');
          print('Current auth email: ${_auth.currentUser?.email}');
          print('Creating user document for userId: $userId');
          print('Project ID: $projectId');
          
          await _firestore.collection('users').doc(userId).set({
            'uid': userId,
            'email': clientEmail.toLowerCase().trim(),
            'displayName': clientName.trim(),
            'role': 'client',
            'projectIds': [projectId],
            'invitedBy': invitedBy,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
            'onboardingComplete': false,
          });
          print('✓ User document created successfully');

          // Add client to project
          print('Adding client to project...');
          print('Updating project/$projectId with clientIds: [$userId]');
          
          await _firestore.collection('projects').doc(projectId).update({
            'clientIds': FieldValue.arrayUnion([userId]),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          print('✓ Client added to project successfully');
          
          // NOW sign out the newly created user
          print('Signing out new user...');
          await _auth.signOut();
          print('✓ Signed out new user');
          print('=== Firestore operations completed ===');
          
        } catch (firestoreError) {
          // If Firestore operations fail, sign out and report error
          print('=== FIRESTORE ERROR ===');
          print('Error: $firestoreError');
          print('Error type: ${firestoreError.runtimeType}');
          print('Error code: ${(firestoreError as dynamic).code}');
          print('Error message: ${(firestoreError as dynamic).message}');
          print('Current auth user when error occurred: ${_auth.currentUser?.uid}');
          print('======================');
          
          try {
            await _auth.signOut();
          } catch (signOutError) {
            print('Error signing out after failure: $signOutError');
          }
          
          throw firestoreError;
        }

        return {
          'success': true,
          'userId': userId,
          'password': password,
          'isNewUser': true,
          'message': 'Client account created and added to project successfully',
        };
      }
    } catch (e) {
      print('Error inviting client: $e');
      return {
        'success': false,
        'message': 'Failed to invite client: ${e.toString()}',
      };
    }
  }

  /// Remove client from project
  Future<Map<String, dynamic>> removeClientFromProject({
    required String userId,
    required String projectId,
  }) async {
    try {
      // Remove project from user's projectIds
      await _firestore.collection('users').doc(userId).update({
        'projectIds': FieldValue.arrayRemove([projectId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Remove user from project's clientIds
      await _firestore.collection('projects').doc(projectId).update({
        'clientIds': FieldValue.arrayRemove([userId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'message': 'Client removed from project successfully',
      };
    } catch (e) {
      print('Error removing client: $e');
      return {
        'success': false,
        'message': 'Failed to remove client: ${e.toString()}',
      };
    }
  }

  /// Get all clients for a project
  Future<List<Map<String, dynamic>>> getProjectClients(String projectId) async {
    try {
      final projectDoc = await _firestore.collection('projects').doc(projectId).get();
      
      if (!projectDoc.exists) {
        return [];
      }

      final clientIds = (projectDoc.data()?['clientIds'] as List?)?.cast<String>() ?? [];
      
      if (clientIds.isEmpty) {
        return [];
      }

      final clients = <Map<String, dynamic>>[];
      
      for (final clientId in clientIds) {
        final userDoc = await _firestore.collection('users').doc(clientId).get();
        if (userDoc.exists) {
          clients.add({
            'id': clientId,
            ...userDoc.data()!,
          });
        }
      }

      return clients;
    } catch (e) {
      print('Error getting project clients: $e');
      return [];
    }
  }
}
