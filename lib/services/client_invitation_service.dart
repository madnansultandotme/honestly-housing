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
  }) async {
    try {
      // Validate email
      if (clientEmail.isEmpty || !clientEmail.contains('@')) {
        return {
          'success': false,
          'message': 'Invalid email address',
        };
      }

      // Check if user already exists
      final existingUserQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: clientEmail.toLowerCase().trim())
          .limit(1)
          .get();

      String userId;
      String password = '';
      bool isNewUser = false;

      if (existingUserQuery.docs.isNotEmpty) {
        // User exists - just add to project
        userId = existingUserQuery.docs.first.id;
        final userData = existingUserQuery.docs.first.data();
        
        // Verify user is a client
        if (userData['role'] != 'client') {
          return {
            'success': false,
            'message': 'This email is registered as a ${userData['role']}. Cannot add to project.',
          };
        }

        // Check if already in project
        final userProjectIds = (userData['projectIds'] as List?)?.cast<String>() ?? [];
        if (userProjectIds.contains(projectId)) {
          return {
            'success': false,
            'message': 'This client is already added to this project.',
          };
        }

        // Add project to user's projectIds
        await _firestore.collection('users').doc(userId).update({
          'projectIds': FieldValue.arrayUnion([projectId]),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Add user to project's clientIds
        await _firestore.collection('projects').doc(projectId).update({
          'clientIds': FieldValue.arrayUnion([userId]),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        return {
          'success': true,
          'userId': userId,
          'isNewUser': false,
          'existingUser': true,
          'userName': userData['displayName'] ?? clientName,
          'message': 'Existing client "${userData['displayName'] ?? clientName}" added to project successfully',
        };
      } else {
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
        } catch (authError) {
          if (authError.toString().contains('email-already-in-use')) {
            return {
              'success': false,
              'message': 'Email already in use. Please use a different email.',
            };
          }
          throw authError;
        }

        // Create user document in Firestore
        await _firestore.collection('users').doc(userId).set({
          'uid': userId,
          'email': clientEmail.toLowerCase().trim(),
          'displayName': clientName.trim(),
          'role': 'client',
          'projectIds': [projectId],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'onboardingComplete': false,
        });

        // Add client to project
        await _firestore.collection('projects').doc(projectId).update({
          'clientIds': FieldValue.arrayUnion([userId]),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Sign out the newly created user (so builder stays logged in)
        await _auth.signOut();

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
