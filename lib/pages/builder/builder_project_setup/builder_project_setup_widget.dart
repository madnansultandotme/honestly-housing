import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';
import 'widgets/client_invitation_dialog.dart';
import '/services/client_invitation_service.dart';
import 'builder_project_setup_model.dart';
export 'builder_project_setup_model.dart';

class BuilderProjectSetupWidget extends StatefulWidget {
  const BuilderProjectSetupWidget({super.key});

  static String routeName = 'BuilderProjectSetup';
  static String routePath = '/builderProjectSetup';

  @override
  State<BuilderProjectSetupWidget> createState() => _BuilderProjectSetupWidgetState();
}

class _BuilderProjectSetupWidgetState extends State<BuilderProjectSetupWidget> {
  late BuilderProjectSetupModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  
  int _currentStep = 0;
  bool _isSaving = false;
  String? _savedProjectId;
  final _clientService = ClientInvitationService();
  
  // Client invitation data
  String? _selectedClientId;
  String? _selectedClientEmail;
  bool _skipClientInvitation = false;
  
  // Form data
  final _projectNameController = TextEditingController();
  final _clientNameController = TextEditingController();
  final _sqFtController = TextEditingController();
  final _budgetController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _officesController = TextEditingController();
  final _fixturesController = TextEditingController();
  
  final List<String> _categoryOptions = [
    'Flooring', 'Lighting', 'Plumbing', 'Paint', 'Tile', 'Countertops', 'Hardware',
  ];
  final List<String> _roomOptions = [
    'Primary Bedroom', 'Bedroom 2', 'Bedroom 3', 'Bedroom 4',
    'Primary Bathroom', 'Bathroom 2', 'Bathroom 3', 'Half Bath',
    'Kitchen', 'Laundry', 'Pantry', 'Mudroom', 'Living Room', 'Dining Room', 'Office',
  ];
  
  List<String> _selectedCategories = [];
  List<String> _selectedRooms = [];
  Map<String, Map<String, dynamic>> _categoryAllowances = {};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BuilderProjectSetupModel());
    _selectedCategories = List<String>.from(_categoryOptions);
    _initializeCategoryAllowances();
  }

  void _initializeCategoryAllowances() {
    for (final category in _selectedCategories) {
      if (!_categoryAllowances.containsKey(category)) {
        _categoryAllowances[category] = {'type': 'fixed', 'amount': 0.0};
      }
    }
    _categoryAllowances.removeWhere((key, value) => !_selectedCategories.contains(key));
  }

  @override
  void dispose() {
    _projectNameController.dispose();
    _clientNameController.dispose();
    _sqFtController.dispose();
    _budgetController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _officesController.dispose();
    _fixturesController.dispose();
    _model.dispose();
    super.dispose();
  }

  Future<void> _saveProject() async {
    if (_isSaving) return;
    
    final projectName = _projectNameController.text.trim();
    if (projectName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a project name.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUserUid).get();
      final builderOrgId = userDoc.data()?['builderOrgId'] as String?;

      final projectRef = FirebaseFirestore.instance.collection('projects').doc();
      _savedProjectId = projectRef.id;

      // Step 1: Create the project document and update user in a batch
      final batch1 = FirebaseFirestore.instance.batch();
      
      batch1.set(projectRef, {
        'name': projectName,
        'clientName': _clientNameController.text.trim(),
        'totalSqFt': double.tryParse(_sqFtController.text) ?? 0.0,
        'totalBudget': double.tryParse(_budgetController.text) ?? 0.0,
        'bedrooms': int.tryParse(_bedroomsController.text) ?? 0,
        'bathrooms': int.tryParse(_bathroomsController.text) ?? 0,
        'offices': int.tryParse(_officesController.text) ?? 0,
        'fixtures': int.tryParse(_fixturesController.text) ?? 0,
        'builderOrgId': builderOrgId,
        'status': 'active',
        'clientIds': [],
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': currentUserUid,
      });

      batch1.update(
        FirebaseFirestore.instance.collection('users').doc(currentUserUid),
        {'projectIds': FieldValue.arrayUnion([projectRef.id])},
      );

      await batch1.commit();

      // Step 2: Now add subcollections (categories and rooms)
      final batch2 = FirebaseFirestore.instance.batch();

      for (var i = 0; i < _selectedCategories.length; i++) {
        final categoryRef = projectRef.collection('categories').doc();
        batch2.set(categoryRef, {
          'name': _selectedCategories[i],
          'required': true,
          'displayOrder': i,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      for (var i = 0; i < _selectedRooms.length; i++) {
        final roomRef = projectRef.collection('rooms').doc();
        batch2.set(roomRef, {
          'name': _selectedRooms[i],
          'displayOrder': i,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch2.commit();

      // Step 3: Handle client invitation if provided
      if (!_skipClientInvitation && _selectedClientEmail != null && _selectedClientEmail!.isNotEmpty) {
        try {
          final result = await _clientService.inviteClientToProject(
            clientEmail: _selectedClientEmail!,
            clientName: _clientNameController.text.trim().isNotEmpty 
                ? _clientNameController.text.trim() 
                : 'Client',
            projectId: projectRef.id,
            projectName: projectName,
          );
          
          if (result['success'] == true) {
            print('Client invited successfully: ${result['message']}');
          } else {
            print('Client invitation failed: ${result['message']}');
          }
        } catch (e) {
          print('Error inviting client: $e');
          // Don't fail the whole operation if client invitation fails
        }
      }

      setState(() => _isSaving = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Project saved successfully.'), backgroundColor: Colors.green),
      );

      // Navigate back to Builder Projects page
      context.goNamed('BuilderProjects');
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildProjectDetailsStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Project Details', style: FlutterFlowTheme.of(context).headlineSmall.override(
            font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
            color: Color(0xFF2C2C2C),
          )),
          SizedBox(height: 24.0),
          _buildTextField('PROJECT NAME', _projectNameController, 'e.g. Riverside Modern Home'),
          SizedBox(height: 16.0),
          _buildTextField('CLIENT NAME', _clientNameController, 'e.g. James & Sarah Whitmore'),
          SizedBox(height: 16.0),
          Row(
            children: [
              Expanded(child: _buildTextField('TOTAL SQ FT', _sqFtController, '2,400')),
              SizedBox(width: 16.0),
              Expanded(child: _buildTextField('TOTAL BUDGET', _budgetController, '\$450,000')),
            ],
          ),
          SizedBox(height: 16.0),
          Row(
            children: [
              Expanded(child: _buildTextField('BEDROOMS', _bedroomsController, '4')),
              SizedBox(width: 12.0),
              Expanded(child: _buildTextField('BATHROOMS', _bathroomsController, '3')),
              SizedBox(width: 12.0),
              Expanded(child: _buildTextField('OFFICES', _officesController, '1')),
              SizedBox(width: 12.0),
              Expanded(child: _buildTextField('FIXTURES', _fixturesController, '12')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Selection Categories', style: FlutterFlowTheme.of(context).headlineSmall.override(
            font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
            color: Color(0xFF2C2C2C),
          )),
          SizedBox(height: 8.0),
          Text('Select all that apply', style: FlutterFlowTheme.of(context).bodySmall.override(
            font: GoogleFonts.inter(),
            color: Color(0xFF8B8680),
          )),
          SizedBox(height: 24.0),
          Wrap(
            spacing: 10.0,
            runSpacing: 10.0,
            children: _categoryOptions.map((category) {
              final isSelected = _selectedCategories.contains(category);
              return FilterChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (value) {
                  setState(() {
                    if (value) {
                      _selectedCategories.add(category);
                    } else {
                      _selectedCategories.remove(category);
                    }
                    _initializeCategoryAllowances();
                  });
                },
                selectedColor: Color(0xFFF5EDE3),
                checkmarkColor: Color(0xFFB8956A),
                labelStyle: TextStyle(
                  color: isSelected ? Color(0xFFB8956A) : Color(0xFF8B8680),
                  fontWeight: FontWeight.w600,
                ),
                backgroundColor: Color(0xFFF5F0EB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  side: BorderSide(color: isSelected ? Color(0xFFB8956A) : Color(0xFFD4C4B0)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomsStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Rooms', style: FlutterFlowTheme.of(context).headlineSmall.override(
            font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
            color: Color(0xFF2C2C2C),
          )),
          SizedBox(height: 8.0),
          Text('Choose rooms for this project', style: FlutterFlowTheme.of(context).bodySmall.override(
            font: GoogleFonts.inter(),
            color: Color(0xFF8B8680),
          )),
          SizedBox(height: 24.0),
          Wrap(
            spacing: 10.0,
            runSpacing: 10.0,
            children: _roomOptions.map((room) {
              final isSelected = _selectedRooms.contains(room);
              return FilterChip(
                label: Text(room),
                selected: isSelected,
                onSelected: (value) {
                  setState(() {
                    if (value) {
                      _selectedRooms.add(room);
                    } else {
                      _selectedRooms.remove(room);
                    }
                  });
                },
                selectedColor: Color(0xFFF5EDE3),
                checkmarkColor: Color(0xFFB8956A),
                labelStyle: TextStyle(
                  color: isSelected ? Color(0xFFB8956A) : Color(0xFF8B8680),
                  fontWeight: FontWeight.w600,
                ),
                backgroundColor: Color(0xFFF5F0EB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  side: BorderSide(color: isSelected ? Color(0xFFB8956A) : Color(0xFFD4C4B0)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildClientInvitationStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Invite Client', style: FlutterFlowTheme.of(context).headlineSmall.override(
            font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
            color: Color(0xFF2C2C2C),
          )),
          SizedBox(height: 8.0),
          Text('Add a client to this project (optional)', style: FlutterFlowTheme.of(context).bodySmall.override(
            font: GoogleFonts.inter(),
            color: Color(0xFF8B8680),
          )),
          SizedBox(height: 24.0),
          
          // Skip option
          CheckboxListTile(
            title: Text('Skip for now - I\'ll add a client later', style: TextStyle(
              color: Color(0xFF2C2C2C),
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            )),
            value: _skipClientInvitation,
            onChanged: (value) {
              setState(() {
                _skipClientInvitation = value ?? false;
                if (_skipClientInvitation) {
                  _selectedClientId = null;
                  _selectedClientEmail = null;
                }
              });
            },
            activeColor: Color(0xFFB8956A),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          
          if (!_skipClientInvitation) ...[
            SizedBox(height: 24.0),
            Text('CLIENT EMAIL', style: TextStyle(
              color: Color(0xFF8B8680),
              fontSize: 11.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            )),
            SizedBox(height: 8.0),
            TextField(
              onChanged: (value) {
                setState(() {
                  _selectedClientEmail = value.trim();
                });
              },
              decoration: InputDecoration(
                hintText: 'client@example.com',
                hintStyle: TextStyle(color: Color(0xFFBDB8B4)),
                filled: true,
                fillColor: Color(0xFFFAF8F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Color(0xFFD4C4B0), width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Color(0xFFD4C4B0), width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Color(0xFFB8956A), width: 1.5),
                ),
                contentPadding: EdgeInsets.all(16.0),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16.0),
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Color(0xFFF5EDE3),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFFB8956A), size: 20.0),
                  SizedBox(width: 12.0),
                  Expanded(
                    child: Text(
                      'If the client doesn\'t have an account, they\'ll receive an invitation email to sign up.',
                      style: TextStyle(
                        color: Color(0xFF8B8680),
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(
          color: Color(0xFF8B8680),
          fontSize: 11.0,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        )),
        SizedBox(height: 8.0),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Color(0xFFBDB8B4)),
            filled: true,
            fillColor: Color(0xFFFAF8F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Color(0xFFD4C4B0), width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Color(0xFFD4C4B0), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Color(0xFFB8956A), width: 1.5),
            ),
            contentPadding: EdgeInsets.all(16.0),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF2C2C2C)),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Project Setup', style: TextStyle(
              color: Color(0xFF2C2825),
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
            )),
            Text('Step ${_currentStep + 1} of 4', style: TextStyle(
              color: Color(0xFF8B8680),
              fontSize: 12.0,
            )),
          ],
        ),
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentStep + 1) / 4,
            backgroundColor: Color(0xFFF5EFE8),
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB8956A)),
          ),
          Expanded(
            child: IndexedStack(
              index: _currentStep,
              children: [
                _buildProjectDetailsStep(),
                _buildCategoriesStep(),
                _buildRoomsStep(),
                _buildClientInvitationStep(),
              ],
            ),
          ),
          // Navigation buttons
          Container(
            padding: EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 10.0,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: FFButtonWidget(
                      onPressed: () => setState(() => _currentStep--),
                      text: 'Back',
                      options: FFButtonOptions(
                        height: 48.0,
                        color: Color(0xFFF5EFE8),
                        textStyle: TextStyle(
                          color: Color(0xFF8B8680),
                          fontWeight: FontWeight.w600,
                        ),
                        elevation: 0.0,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                if (_currentStep > 0) SizedBox(width: 12.0),
                Expanded(
                  child: FFButtonWidget(
                    onPressed: _currentStep < 3
                        ? () => setState(() => _currentStep++)
                        : _saveProject,
                    text: _currentStep < 3 ? 'Continue' : (_isSaving ? 'Saving...' : 'Save Project'),
                    options: FFButtonOptions(
                      height: 48.0,
                      color: Color(0xFFB8956A),
                      textStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      elevation: 0.0,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
