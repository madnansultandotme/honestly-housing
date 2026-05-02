import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'signup_flow_model.dart';
export 'signup_flow_model.dart';

class SignupFlowWidget extends StatefulWidget {
  const SignupFlowWidget({super.key});

  static String routeName = 'SignupFlow';
  static String routePath = '/signupFlow';

  @override
  State<SignupFlowWidget> createState() => _SignupFlowWidgetState();
}

class _SignupFlowWidgetState extends State<SignupFlowWidget> {
  late SignupFlowModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  int _stepIndex = 0;
  String? _role;
  bool? _worksWithBuilder;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SignupFlowModel());

    _model.nameController ??= TextEditingController();
    _model.nameFocusNode ??= FocusNode();

    _model.emailController ??= TextEditingController();
    _model.emailFocusNode ??= FocusNode();

    _model.passwordController ??= TextEditingController();
    _model.passwordFocusNode ??= FocusNode();

    _model.confirmPasswordController ??= TextEditingController();
    _model.confirmPasswordFocusNode ??= FocusNode();

    _model.orgNameController ??= TextEditingController();
    _model.orgNameFocusNode ??= FocusNode();

    _model.phoneController ??= TextEditingController();
    _model.phoneFocusNode ??= FocusNode();

    _model.cityController ??= TextEditingController();
    _model.cityFocusNode ??= FocusNode();

    _model.budgetController ??= TextEditingController();
    _model.budgetFocusNode ??= FocusNode();

    _model.timelineController ??= TextEditingController();
    _model.timelineFocusNode ??= FocusNode();

    _model.styleController ??= TextEditingController();
    _model.styleFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  bool get _isHomeowner => _role == 'homeowner';

  bool get _needsOnboarding =>
      _role == 'homeowner' && _worksWithBuilder == false;

  String _displayRole(String role) {
    switch (role) {
      case 'builder':
        return 'Builder';
      case 'designer':
        return 'Designer';
      case 'homeowner':
        return 'Home Owner';
      default:
        return 'Role';
    }
  }

  Future<void> _handleContinueFromRole() async {
    if (_role == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a role to continue.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_isHomeowner && _worksWithBuilder == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please tell us if you are working with a builder.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_isHomeowner && _worksWithBuilder == true) {
      context.goNamed('LoginPage');
      return;
    }

    setState(() {
      _stepIndex = 1;
    });
  }

  Future<void> _createAccount() async {
    if (_isSubmitting) return;

    final name = _model.nameController!.text.trim();
    final email = _model.emailController!.text.trim();
    final password = _model.passwordController!.text;
    final confirmPassword = _model.confirmPasswordController!.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please complete all required fields.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Passwords do not match.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_role == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a role to continue.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    User? createdUser;
    
    try {
      final user = await authManager.createAccountWithEmail(
        context,
        email,
        password,
      );

      if (user == null) {
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      createdUser = user;

      String? builderOrgId;
      if (_role == 'builder' || _role == 'designer') {
        final orgName = _model.orgNameController!.text.trim();
        if (orgName.isNotEmpty) {
          final orgRef =
              FirebaseFirestore.instance.collection('builderOrgs').doc();
          await orgRef.set({
            'name': orgName,
            'ownerId': user.uid,
            'createdAt': FieldValue.serverTimestamp(),
          });
          builderOrgId = orgRef.id;
        }
      }

      final roleValue = _role == 'homeowner' ? 'client' : _role!;

      // Try to create user document in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(
            createUsersRecordData(
              uid: user.uid,
              email: email,
              displayName: name,
              role: roleValue,
              builderOrgId: builderOrgId,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );

      // Success! Clear the createdUser reference
      createdUser = null;

      if (_needsOnboarding) {
        setState(() {
          _stepIndex = 2;
          _isSubmitting = false;
        });
      } else {
        if (roleValue == 'builder' || roleValue == 'designer') {
          context.goNamed('BuilderDashboard');
        } else {
          context.goNamed('ClientDashboard');
        }
      }
    } catch (e) {
      // If user was created but Firestore write failed, delete the auth user
      if (createdUser != null) {
        try {
          await createdUser.delete();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Account creation failed. Please check your permissions and try again.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
        } catch (deleteError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Account created but setup failed. Please contact support.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
        }
      } else {
        // Show user-friendly error message
        String errorMessage = 'Sign up failed. Please try again.';
        if (e.toString().contains('email-already-in-use')) {
          errorMessage = 'This email is already registered. Please use a different email or try logging in.';
        } else if (e.toString().contains('weak-password')) {
          errorMessage = 'Password is too weak. Please use a stronger password.';
        } else if (e.toString().contains('invalid-email')) {
          errorMessage = 'Invalid email address. Please check and try again.';
        } else if (e.toString().contains('permission') || e.toString().contains('PERMISSION_DENIED')) {
          errorMessage = 'Permission error. Please contact support to enable your account.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
      
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _saveOnboarding() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUid)
          .update({
        'phone': _model.phoneController!.text.trim(),
        'city': _model.cityController!.text.trim(),
        'budgetRange': _model.budgetController!.text.trim(),
        'timeline': _model.timelineController!.text.trim(),
        'stylePreference': _model.styleController!.text.trim(),
        'onboardingComplete': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      context.goNamed('ClientDashboard');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Onboarding failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Widget _buildRoleCard(String role, String subtitle, IconData icon) {
    final isSelected = _role == role;
    return InkWell(
      onTap: () {
        setState(() {
          _role = role;
          if (role != 'homeowner') {
            _worksWithBuilder = null;
          }
        });
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFF5EFE8) : Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: isSelected ? Color(0xFFB8956A) : Color(0xFFD4C4B0),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 10.0,
              color: Color(0x14000000),
              offset: Offset(0.0, 2.0),
            )
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 44.0,
                height: 44.0,
                decoration: BoxDecoration(
                  color: Color(0xFFF8F3ED),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: Color(0xFFD4C4B0),
                  ),
                ),
                child: Icon(
                  icon,
                  color: Color(0xFFB8956A),
                  size: 22.0,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 0.0, 0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _displayRole(role),
                        style: FlutterFlowTheme.of(context).titleMedium.override(
                              font: GoogleFonts.interTight(
                                fontWeight: FontWeight.bold,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .titleMedium
                                    .fontStyle,
                              ),
                              color: Color(0xFF2C2C2C),
                              fontSize: 16.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.bold,
                              fontStyle:
                                  FlutterFlowTheme.of(context).titleMedium.fontStyle,
                            ),
                      ),
                      Text(
                        subtitle,
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              font: GoogleFonts.inter(),
                              color: Color(0xFF8B8680),
                              letterSpacing: 0.0,
                            ),
                      ),
                    ].divide(SizedBox(height: 4.0)),
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFFB8956A),
                  size: 20.0,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: FlutterFlowTheme.of(context).labelMedium.override(
                font: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontStyle: FlutterFlowTheme.of(context)
                      .labelMedium
                      .fontStyle,
                ),
                color: Color(0xFF5C5450),
                fontSize: 13.0,
                letterSpacing: 0.3,
                fontWeight: FontWeight.w600,
                fontStyle:
                    FlutterFlowTheme.of(context).labelMedium.fontStyle,
              ),
        ),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          autofocus: false,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(),
                  color: Color(0xFFBDB8B4),
                  letterSpacing: 0.0,
                ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Color(0xFFD4C4B0),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(12.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Color(0xFFB8956A),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(12.0),
            ),
            filled: true,
            fillColor: Color(0xFFFAF8F5),
            contentPadding:
                EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
          ),
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.inter(),
                color: Color(0xFF2C2420),
                letterSpacing: 0.0,
              ),
          keyboardType: keyboardType,
          cursorColor: Color(0xFFB8956A),
        ),
      ].divide(SizedBox(height: 6.0)),
    );
  }

  Widget _buildRoleStep() {
    return Column(
      children: [
        Text(
          'Choose Your Role',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                font: GoogleFonts.interTight(
                  fontWeight: FontWeight.bold,
                  fontStyle:
                      FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                ),
                color: Color(0xFF2C2420),
                fontSize: 24.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.bold,
                fontStyle:
                    FlutterFlowTheme.of(context).headlineMedium.fontStyle,
              ),
        ),
        Text(
          'Select the profile that matches your role in the project.',
          textAlign: TextAlign.center,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.inter(),
                color: Color(0xFF8B8680),
                letterSpacing: 0.0,
              ),
        ),
        SizedBox(height: 24.0),
        _buildRoleCard(
          'builder',
          'Manage projects, approvals, and client selections.',
          Icons.construction_rounded,
        ),
        SizedBox(height: 16.0),
        _buildRoleCard(
          'designer',
          'Collaborate on selections and approvals.',
          Icons.palette_rounded,
        ),
        SizedBox(height: 16.0),
        _buildRoleCard(
          'homeowner',
          'Review options and approve selections.',
          Icons.home_rounded,
        ),
        if (_isHomeowner) ...[
          SizedBox(height: 20.0),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: Color(0xFFD4C4B0),
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Are you working with a builder?',
                    style: FlutterFlowTheme.of(context).titleMedium.override(
                          font: GoogleFonts.interTight(
                            fontWeight: FontWeight.bold,
                            fontStyle: FlutterFlowTheme.of(context)
                                .titleMedium
                                .fontStyle,
                          ),
                          color: Color(0xFF2C2C2C),
                          letterSpacing: 0.0,
                        ),
                  ),
                  SizedBox(height: 12.0),
                  Row(
                    children: [
                      Expanded(
                        child: FFButtonWidget(
                          onPressed: () {
                            setState(() {
                              _worksWithBuilder = true;
                            });
                          },
                          text: 'Yes',
                          options: FFButtonOptions(
                            height: 44.0,
                            color: _worksWithBuilder == true
                                ? Color(0xFFB8956A)
                                : Color(0xFFF5EFE8),
                            textStyle:
                                FlutterFlowTheme.of(context).labelLarge.override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      color: _worksWithBuilder == true
                                          ? Colors.white
                                          : Color(0xFF8B8680),
                                    ),
                            elevation: 0.0,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.0),
                      Expanded(
                        child: FFButtonWidget(
                          onPressed: () {
                            setState(() {
                              _worksWithBuilder = false;
                            });
                          },
                          text: 'No',
                          options: FFButtonOptions(
                            height: 44.0,
                            color: _worksWithBuilder == false
                                ? Color(0xFFB8956A)
                                : Color(0xFFF5EFE8),
                            textStyle:
                                FlutterFlowTheme.of(context).labelLarge.override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      color: _worksWithBuilder == false
                                          ? Colors.white
                                          : Color(0xFF8B8680),
                                    ),
                            elevation: 0.0,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_worksWithBuilder == true) ...[
                    SizedBox(height: 12.0),
                    Text(
                      'Great! Use the login credentials provided by your builder.',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            font: GoogleFonts.inter(),
                            color: Color(0xFF8B8680),
                            letterSpacing: 0.0,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
        SizedBox(height: 24.0),
        FFButtonWidget(
          onPressed: _handleContinueFromRole,
          text: _isHomeowner && _worksWithBuilder == true
              ? 'Go to Login'
              : 'Continue',
          options: FFButtonOptions(
            width: double.infinity,
            height: 52.0,
            color: Color(0xFFB8956A),
            textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                  font: GoogleFonts.interTight(
                    fontWeight: FontWeight.bold,
                  ),
                  color: Colors.white,
                ),
            elevation: 0.0,
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ].divide(SizedBox(height: 12.0)),
    );
  }

  Widget _buildCreateAccountStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create Your Account',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                font: GoogleFonts.interTight(
                  fontWeight: FontWeight.bold,
                  fontStyle:
                      FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                ),
                color: Color(0xFF2C2420),
                fontSize: 24.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.bold,
                fontStyle:
                    FlutterFlowTheme.of(context).headlineMedium.fontStyle,
              ),
        ),
        Text(
          'Set up your profile so we can personalize your experience.',
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.inter(),
                color: Color(0xFF8B8680),
                letterSpacing: 0.0,
              ),
        ),
        SizedBox(height: 20.0),
        _buildTextField(
          label: 'Full Name',
          controller: _model.nameController!,
          focusNode: _model.nameFocusNode!,
          hintText: 'e.g. Morgan Lee',
        ),
        _buildTextField(
          label: 'Email Address',
          controller: _model.emailController!,
          focusNode: _model.emailFocusNode!,
          keyboardType: TextInputType.emailAddress,
          hintText: 'name@example.com',
        ),
        _buildTextField(
          label: 'Password',
          controller: _model.passwordController!,
          focusNode: _model.passwordFocusNode!,
          obscureText: true,
          hintText: 'Create a password',
        ),
        _buildTextField(
          label: 'Confirm Password',
          controller: _model.confirmPasswordController!,
          focusNode: _model.confirmPasswordFocusNode!,
          obscureText: true,
          hintText: 'Re-enter password',
        ),
        if (_role == 'builder' || _role == 'designer')
          _buildTextField(
            label: 'Company Name (optional)',
            controller: _model.orgNameController!,
            focusNode: _model.orgNameFocusNode!,
            hintText: 'e.g. Atelier Homes',
          ),
        SizedBox(height: 12.0),
        Row(
          children: [
            Expanded(
              child: FFButtonWidget(
                onPressed: () {
                  setState(() {
                    _stepIndex = 0;
                  });
                },
                text: 'Back',
                options: FFButtonOptions(
                  height: 48.0,
                  color: Color(0xFFF5EFE8),
                  textStyle: FlutterFlowTheme.of(context)
                      .labelLarge
                      .override(
                        font: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                        ),
                        color: Color(0xFF8B8680),
                      ),
                  elevation: 0.0,
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            SizedBox(width: 12.0),
            Expanded(
              child: FFButtonWidget(
                onPressed: _isSubmitting ? null : _createAccount,
                text: _isSubmitting ? 'Creating...' : 'Create Account',
                icon: _isSubmitting
                    ? SizedBox(
                        width: 20.0,
                        height: 20.0,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : null,
                options: FFButtonOptions(
                  height: 48.0,
                  color: _isSubmitting 
                      ? Color(0xFFB8956A).withOpacity(0.7)
                      : Color(0xFFB8956A),
                  textStyle: FlutterFlowTheme.of(context)
                      .labelLarge
                      .override(
                        font: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                        ),
                        color: Colors.white,
                      ),
                  elevation: 0.0,
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ],
        ),
      ].divide(SizedBox(height: 12.0)),
    );
  }

  Widget _buildOnboardingStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tell Us About Your Project',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                font: GoogleFonts.interTight(
                  fontWeight: FontWeight.bold,
                  fontStyle:
                      FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                ),
                color: Color(0xFF2C2420),
                fontSize: 24.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.bold,
                fontStyle:
                    FlutterFlowTheme.of(context).headlineMedium.fontStyle,
              ),
        ),
        Text(
          'Answer a few questions to personalize your curated selections.',
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.inter(),
                color: Color(0xFF8B8680),
                letterSpacing: 0.0,
              ),
        ),
        SizedBox(height: 20.0),
        _buildTextField(
          label: 'Phone Number',
          controller: _model.phoneController!,
          focusNode: _model.phoneFocusNode!,
          keyboardType: TextInputType.phone,
          hintText: '(555) 555-5555',
        ),
        _buildTextField(
          label: 'City / State',
          controller: _model.cityController!,
          focusNode: _model.cityFocusNode!,
          hintText: 'Austin, TX',
        ),
        _buildTextField(
          label: 'Target Budget Range',
          controller: _model.budgetController!,
          focusNode: _model.budgetFocusNode!,
          hintText: 'e.g. 350k - 500k',
        ),
        _buildTextField(
          label: 'Project Timeline',
          controller: _model.timelineController!,
          focusNode: _model.timelineFocusNode!,
          hintText: 'e.g. Move-in by Spring 2027',
        ),
        _buildTextField(
          label: 'Style Preferences',
          controller: _model.styleController!,
          focusNode: _model.styleFocusNode!,
          hintText: 'e.g. Modern, warm neutrals',
        ),
        SizedBox(height: 12.0),
        Row(
          children: [
            Expanded(
              child: FFButtonWidget(
                onPressed: () {
                  setState(() {
                    _stepIndex = 1;
                  });
                },
                text: 'Back',
                options: FFButtonOptions(
                  height: 48.0,
                  color: Color(0xFFF5EFE8),
                  textStyle: FlutterFlowTheme.of(context)
                      .labelLarge
                      .override(
                        font: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                        ),
                        color: Color(0xFF8B8680),
                      ),
                  elevation: 0.0,
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            SizedBox(width: 12.0),
            Expanded(
              child: FFButtonWidget(
                onPressed: _isSubmitting ? null : _saveOnboarding,
                text: _isSubmitting ? 'Saving...' : 'Finish',
                icon: _isSubmitting
                    ? SizedBox(
                        width: 20.0,
                        height: 20.0,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : null,
                options: FFButtonOptions(
                  height: 48.0,
                  color: _isSubmitting 
                      ? Color(0xFFB8956A).withOpacity(0.7)
                      : Color(0xFFB8956A),
                  textStyle: FlutterFlowTheme.of(context)
                      .labelLarge
                      .override(
                        font: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                        ),
                        color: Colors.white,
                      ),
                  elevation: 0.0,
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ],
        ),
      ].divide(SizedBox(height: 12.0)),
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
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 20.0,
            borderWidth: 1.0,
            buttonSize: 40.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: Color(0xFF2C2C2C),
              size: 24.0,
            ),
            onPressed: () {
              if (_stepIndex > 0) {
                setState(() {
                  _stepIndex -= 1;
                });
              } else {
                context.pop();
              }
            },
          ),
          title: Text(
            'Create Profile',
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  font: GoogleFonts.interTight(
                    fontWeight: FontWeight.bold,
                    fontStyle:
                        FlutterFlowTheme.of(context).titleMedium.fontStyle,
                  ),
                  color: Color(0xFF2C2C2C),
                  fontSize: 18.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.bold,
                  fontStyle:
                      FlutterFlowTheme.of(context).titleMedium.fontStyle,
                ),
          ),
          centerTitle: false,
          elevation: 0.0,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 40.0),
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(maxWidth: 560.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 30.0,
                      color: Color(0x14000000),
                      offset: Offset(0.0, 10.0),
                    )
                  ],
                  borderRadius: BorderRadius.circular(24.0),
                  border: Border.all(
                    color: Color(0xFFD4C4B0),
                    width: 1.0,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(24.0, 28.0, 24.0, 28.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      if (_stepIndex == 0) _buildRoleStep(),
                      if (_stepIndex == 1) _buildCreateAccountStep(),
                      if (_stepIndex == 2) _buildOnboardingStep(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
