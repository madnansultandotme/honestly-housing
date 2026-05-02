import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/index.dart';

/// Widget that redirects to the appropriate dashboard based on user role
class RoleBasedRedirect extends StatefulWidget {
  const RoleBasedRedirect({super.key});

  @override
  State<RoleBasedRedirect> createState() => _RoleBasedRedirectState();
}

class _RoleBasedRedirectState extends State<RoleBasedRedirect> {
  bool _isLoading = true;
  String? _role;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    try {
      if (currentUserUid.isEmpty) {
        // Not logged in, will be handled by auth state
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUid)
          .get();

      if (userDoc.exists) {
        final role = userDoc.data()?['role'] as String?;
        setState(() {
          _role = role;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user role: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB8956A)),
          ),
        ),
      );
    }

    // Redirect based on role
    if (_role == 'builder' || _role == 'designer') {
      return BuilderDashboardWidget();
    } else if (_role == 'client') {
      return ClientDashboardWidgetModular();
    } else {
      // Default to login if role is not set
      return LoginPageWidget();
    }
  }
}
