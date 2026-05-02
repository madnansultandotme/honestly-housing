import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/services/client_invitation_service.dart';

/// Dialog for inviting clients to a project
class ClientInvitationDialog extends StatefulWidget {
  final String projectId;
  final String projectName;
  final Function()? onClientAdded;

  const ClientInvitationDialog({
    super.key,
    required this.projectId,
    required this.projectName,
    this.onClientAdded,
  });

  @override
  State<ClientInvitationDialog> createState() => _ClientInvitationDialogState();
}

class _ClientInvitationDialogState extends State<ClientInvitationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _service = ClientInvitationService();
  
  bool _isLoading = false;
  String? _generatedPassword;
  bool _showSuccess = false;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _inviteClient() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _generatedPassword = null;
      _showSuccess = false;
    });

    final result = await _service.inviteClientToProject(
      clientEmail: _emailController.text.trim(),
      clientName: _nameController.text.trim(),
      projectId: widget.projectId,
      projectName: widget.projectName,
    );

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      // Show appropriate message for existing vs new users
      if (result['isNewUser'] == false) {
        if (mounted) {
          final userName = result['userName'] ?? 'Client';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      'Existing client "$userName" added to project',
                      style: TextStyle(fontSize: 14.0),
                    ),
                  ),
                ],
              ),
              backgroundColor: Color(0xFF4CAF50),
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        
        if (widget.onClientAdded != null) {
          widget.onClientAdded!();
        }
        
        // Close dialog and return success
        Navigator.of(context).pop(true);
        return;
      }
      
      // New user - show credentials
      setState(() {
        _showSuccess = true;
        _generatedPassword = result['password'];
      });
      
      if (widget.onClientAdded != null) {
        widget.onClientAdded!();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to invite client'),
            backgroundColor: Color(0xFFE05C5C),
          ),
        );
      }
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied to clipboard'),
        backgroundColor: Color(0xFFB8956A),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showSuccess && _generatedPassword != null) {
      return AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Color(0xFF4CAF50),
              size: 28.0,
            ),
            SizedBox(width: 12.0),
            Text(
              'Client Invited!',
              style: FlutterFlowTheme.of(context).headlineSmall.override(
                    font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                    color: Color(0xFF2C2C2C),
                    letterSpacing: 0.0,
                  ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Client account created successfully. Share these credentials with your client:',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(),
                      color: Color(0xFF5C5450),
                      letterSpacing: 0.0,
                    ),
              ),
              SizedBox(height: 16.0),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Color(0xFFF5EFE8),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: Color(0xFFD4C4B0),
                    width: 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Email:',
                          style: FlutterFlowTheme.of(context).bodySmall.override(
                                font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                color: Color(0xFF8B8680),
                                fontSize: 12.0,
                                letterSpacing: 0.0,
                              ),
                        ),
                        IconButton(
                          icon: Icon(Icons.copy, size: 18.0),
                          color: Color(0xFFB8956A),
                          onPressed: () => _copyToClipboard(_emailController.text.trim()),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      _emailController.text.trim(),
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                            color: Color(0xFF2C2C2C),
                            fontSize: 14.0,
                            letterSpacing: 0.0,
                          ),
                    ),
                    SizedBox(height: 12.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Password:',
                          style: FlutterFlowTheme.of(context).bodySmall.override(
                                font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                color: Color(0xFF8B8680),
                                fontSize: 12.0,
                                letterSpacing: 0.0,
                              ),
                        ),
                        IconButton(
                          icon: Icon(Icons.copy, size: 18.0),
                          color: Color(0xFFB8956A),
                          onPressed: () => _copyToClipboard(_generatedPassword!),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      _generatedPassword!,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.robotoMono(),
                            color: Color(0xFF2C2C2C),
                            fontSize: 14.0,
                            letterSpacing: 0.0,
                          ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              Container(
                padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Color(0xFFFFF8F3),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: Color(0xFFB8956A),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Color(0xFFB8956A),
                      size: 20.0,
                    ),
                    SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        'Save these credentials! They won\'t be shown again.',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              font: GoogleFonts.inter(),
                              color: Color(0xFF8B8680),
                              fontSize: 12.0,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          FFButtonWidget(
            onPressed: () => Navigator.of(context).pop(true),
            text: 'Done',
            options: FFButtonOptions(
              height: 44.0,
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              color: Color(0xFFB8956A),
              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                    font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    color: Colors.white,
                    letterSpacing: 0.0,
                  ),
              elevation: 0.0,
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ],
      );
    }

    return AlertDialog(
      title: Text(
        'Invite Client',
        style: FlutterFlowTheme.of(context).headlineSmall.override(
              font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
              color: Color(0xFF2C2C2C),
              letterSpacing: 0.0,
            ),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter client details to create their account and add them to this project.',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(),
                      color: Color(0xFF8B8680),
                      letterSpacing: 0.0,
                    ),
              ),
              SizedBox(height: 20.0),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Client Name',
                  hintText: 'e.g. John Smith',
                  labelStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(),
                        color: Color(0xFF8B8680),
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
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFFE05C5C),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFFE05C5C),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  filled: true,
                  fillColor: Color(0xFFFAF8F5),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter client name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Client Email',
                  hintText: 'client@example.com',
                  labelStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(),
                        color: Color(0xFF8B8680),
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
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFFE05C5C),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFFE05C5C),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  filled: true,
                  fillColor: Color(0xFFFAF8F5),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter client email';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: Text(
            'Cancel',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  color: Color(0xFF8B8680),
                  letterSpacing: 0.0,
                ),
          ),
        ),
        FFButtonWidget(
          onPressed: _isLoading ? null : _inviteClient,
          text: _isLoading ? 'Creating...' : 'Invite Client',
          icon: _isLoading
              ? SizedBox(
                  width: 20.0,
                  height: 20.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : null,
          options: FFButtonOptions(
            height: 44.0,
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            color: _isLoading ? Color(0xFFB8956A).withOpacity(0.7) : Color(0xFFB8956A),
            textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                  font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  color: Colors.white,
                  letterSpacing: 0.0,
                ),
            elevation: 0.0,
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ],
    );
  }
}
