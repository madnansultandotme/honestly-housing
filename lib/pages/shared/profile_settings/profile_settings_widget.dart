import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/auth/firebase_auth/auth_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'profile_settings_model.dart';
export 'profile_settings_model.dart';

/// Profile and Settings Screen
/// Allows users to view their profile and logout
class ProfileSettingsWidget extends StatefulWidget {
  const ProfileSettingsWidget({super.key});

  static String routeName = 'ProfileSettings';
  static String routePath = '/profileSettings';

  @override
  State<ProfileSettingsWidget> createState() => _ProfileSettingsWidgetState();
}

class _ProfileSettingsWidgetState extends State<ProfileSettingsWidget> {
  late ProfileSettingsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  String _userName = '';
  String _userEmail = '';
  String _userRole = '';
  String _userPhotoUrl = '';
  bool _isLoading = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProfileSettingsModel());
    _loadUserData();
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>?;
        final photoUrl = userData?['photoUrl'] as String? ?? '';
        print('DEBUG: User data loaded');
        print('DEBUG: PhotoUrl from Firestore: $photoUrl');
        setState(() {
          _userName = userData?['displayName'] as String? ?? 'User';
          _userEmail = userData?['email'] as String? ?? currentUserEmail;
          _userRole = userData?['role'] as String? ?? 'user';
          _userPhotoUrl = photoUrl;
          _isLoading = false;
        });
      } else {
        setState(() {
          _userName = 'User';
          _userEmail = currentUserEmail;
          _userRole = 'user';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _uploadPhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image == null) return;

      setState(() {
        _isUploading = true;
      });

      // Upload to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_avatars')
          .child('$currentUserUid.jpg');

      // Handle web vs mobile differently
      UploadTask uploadTask;
      if (kIsWeb) {
        // For web, read as bytes
        final bytes = await image.readAsBytes();
        uploadTask = storageRef.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      } else {
        // For mobile, use file path (this won't run on web)
        final bytes = await image.readAsBytes();
        uploadTask = storageRef.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      print('DEBUG: Upload complete');
      print('DEBUG: Download URL: $downloadUrl');

      // Update Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUid)
          .update({
        'photoUrl': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      print('DEBUG: Firestore updated with photoUrl');

      setState(() {
        _userPhotoUrl = downloadUrl;
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile photo updated successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Wait a moment for the snackbar to show, then pop back
        await Future.delayed(Duration(seconds: 1));
        if (mounted) {
          context.pop();
        }
      }
    } catch (e) {
      print('Error uploading photo: $e');
      setState(() {
        _isUploading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload photo. Please try again.'),
            backgroundColor: Color(0xFFE05C5C),
          ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Logout',
          style: FlutterFlowTheme.of(context).headlineSmall.override(
                font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                color: Color(0xFF2C2C2C),
                letterSpacing: 0.0,
              ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.inter(),
                color: Color(0xFF5C5450),
                letterSpacing: 0.0,
              ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'Cancel',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    color: Color(0xFF8B8680),
                    letterSpacing: 0.0,
                  ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              backgroundColor: Color(0xFFE05C5C),
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: Text(
              'Logout',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    color: Colors.white,
                    letterSpacing: 0.0,
                  ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      // Immediately navigate away to prevent UI hanging
      context.go('/loginPage');
      
      // Sign out in background
      try {
        await authManager.signOut();
      } catch (e) {
        print('Logout error: $e');
      }
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'builder':
        return 'Builder';
      case 'designer':
        return 'Designer';
      case 'client':
        return 'Client';
      default:
        return role.toUpperCase();
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    bool showArrow = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: Color(0xFFF5EFE8),
              width: 1.0,
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                  color: Color(0xFFF5EFE8),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? Color(0xFFB8956A),
                  size: 20.0,
                ),
              ),
              SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                            color: Color(0xFF2C2C2C),
                            fontSize: 15.0,
                            letterSpacing: 0.0,
                          ),
                    ),
                    if (subtitle != null)
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0.0, 2.0, 0.0, 0.0),
                        child: Text(
                          subtitle,
                          style: FlutterFlowTheme.of(context).bodySmall.override(
                                font: GoogleFonts.inter(),
                                color: Color(0xFF8B8680),
                                fontSize: 13.0,
                                letterSpacing: 0.0,
                              ),
                        ),
                      ),
                  ],
                ),
              ),
              if (showArrow)
                Icon(
                  Icons.chevron_right,
                  color: Color(0xFFD4C4B0),
                  size: 24.0,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Color(0xFF2C2C2C),
              size: 24.0,
            ),
            onPressed: () {
              context.pop();
            },
          ),
          title: Text(
            'Profile & Settings',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                  color: Color(0xFF2C2C2C),
                  fontSize: 20.0,
                  letterSpacing: 0.0,
                ),
          ),
          centerTitle: false,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB8956A)),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // Profile Header
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xFFF5EFE8),
                              width: 1.0,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              Builder(
                                builder: (context) {
                                  print('DEBUG: Building avatar with photoUrl: "$_userPhotoUrl"');
                                  print('DEBUG: isEmpty: ${_userPhotoUrl.isEmpty}');
                                  print('DEBUG: isNotEmpty: ${_userPhotoUrl.isNotEmpty}');
                                  return Stack(
                                children: [
                                  Container(
                                    width: 80.0,
                                    height: 80.0,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFD4C4B0),
                                      shape: BoxShape.circle,
                                    ),
                                    child: _userPhotoUrl.isNotEmpty
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(50.0),
                                            child: CachedNetworkImage(
                                              imageUrl: _userPhotoUrl,
                                              width: 80.0,
                                              height: 80.0,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) => Center(
                                                child: CircularProgressIndicator(
                                                  valueColor: AlwaysStoppedAnimation<Color>(
                                                    Color(0xFFB8956A),
                                                  ),
                                                ),
                                              ),
                                              errorWidget: (context, url, error) {
                                                print('DEBUG: CachedNetworkImage error: $error');
                                                return Center(
                                                  child: Text(
                                                    _userName.isNotEmpty
                                                        ? _userName[0].toUpperCase()
                                                        : 'U',
                                                    style: FlutterFlowTheme.of(context)
                                                        .headlineLarge
                                                        .override(
                                                          font: GoogleFonts.inter(
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                          color: Colors.white,
                                                          fontSize: 32.0,
                                                          letterSpacing: 0.0,
                                                        ),
                                                  ),
                                                );
                                              },
                                            ),
                                          )
                                        : Center(
                                            child: Text(
                                              _userName.isNotEmpty
                                                  ? _userName[0].toUpperCase()
                                                  : 'U',
                                              style: FlutterFlowTheme.of(context)
                                                  .headlineLarge
                                                  .override(
                                                    font: GoogleFonts.inter(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    color: Colors.white,
                                                    fontSize: 32.0,
                                                    letterSpacing: 0.0,
                                                  ),
                                            ),
                                          ),
                                  ),
                                  // Upload button overlay
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: InkWell(
                                      onTap: _isUploading ? null : _uploadPhoto,
                                      child: Container(
                                        width: 28.0,
                                        height: 28.0,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFB8956A),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2.0,
                                          ),
                                        ),
                                        child: _isUploading
                                            ? Padding(
                                                padding: EdgeInsets.all(6.0),
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2.0,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                                ),
                                              )
                                            : Icon(
                                                Icons.camera_alt,
                                                color: Colors.white,
                                                size: 14.0,
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                              },
                              ),
                              SizedBox(height: 16.0),
                              Text(
                                _userName,
                                style: FlutterFlowTheme.of(context)
                                    .headlineSmall
                                    .override(
                                      font: GoogleFonts.interTight(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      color: Color(0xFF2C2C2C),
                                      fontSize: 22.0,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                              SizedBox(height: 4.0),
                              Text(
                                _userEmail,
                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                      font: GoogleFonts.inter(),
                                      color: Color(0xFF8B8680),
                                      fontSize: 14.0,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                              SizedBox(height: 8.0),
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFFF5EDE3),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12.0, vertical: 6.0),
                                  child: Text(
                                    _getRoleDisplayName(_userRole),
                                    style: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                          ),
                                          color: Color(0xFFB8956A),
                                          fontSize: 12.0,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 8.0),

                      // Account Section
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(20.0, 16.0, 20.0, 8.0),
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            'ACCOUNT',
                            style: FlutterFlowTheme.of(context).bodySmall.override(
                                  font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                  color: Color(0xFF8B8680),
                                  fontSize: 11.0,
                                  letterSpacing: 0.5,
                                ),
                          ),
                        ),
                      ),

                      _buildSettingItem(
                        icon: Icons.person_outline,
                        title: 'Edit Profile',
                        subtitle: 'Update your name and photo',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Edit profile feature coming soon'),
                              backgroundColor: Color(0xFFB8956A),
                            ),
                          );
                        },
                      ),

                      _buildSettingItem(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        subtitle: 'Manage notification preferences',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Notification settings coming soon'),
                              backgroundColor: Color(0xFFB8956A),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 16.0),

                      // Support Section
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(20.0, 16.0, 20.0, 8.0),
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            'SUPPORT',
                            style: FlutterFlowTheme.of(context).bodySmall.override(
                                  font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                  color: Color(0xFF8B8680),
                                  fontSize: 11.0,
                                  letterSpacing: 0.5,
                                ),
                          ),
                        ),
                      ),

                      _buildSettingItem(
                        icon: Icons.help_outline,
                        title: 'Help & Support',
                        subtitle: 'Get help with the app',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Help center coming soon'),
                              backgroundColor: Color(0xFFB8956A),
                            ),
                          );
                        },
                      ),

                      _buildSettingItem(
                        icon: Icons.info_outline,
                        title: 'About',
                        subtitle: 'App version and information',
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(
                                'About',
                                style: FlutterFlowTheme.of(context)
                                    .headlineSmall
                                    .override(
                                      font: GoogleFonts.interTight(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      color: Color(0xFF2C2C2C),
                                      letterSpacing: 0.0,
                                    ),
                              ),
                              content: Text(
                                'Honestly Housing\nVersion 1.0.0\n\nA platform for managing home construction projects.',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.inter(),
                                      color: Color(0xFF5C5450),
                                      letterSpacing: 0.0,
                                    ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text(
                                    'Close',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                          ),
                                          color: Color(0xFFB8956A),
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 24.0),

                      // Logout Button
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 32.0),
                        child: InkWell(
                          onTap: _handleLogout,
                          child: Container(
                            width: double.infinity,
                            height: 52.0,
                            decoration: BoxDecoration(
                              color: Color(0xFFE05C5C),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.logout,
                                  color: Colors.white,
                                  size: 20.0,
                                ),
                                SizedBox(width: 8.0),
                                Text(
                                  'Logout',
                                  style: FlutterFlowTheme.of(context).titleSmall.override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        color: Colors.white,
                                        fontSize: 16.0,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
