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

  double _parseAllowanceAmount(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  Future<String?> _loadBuilderOrgId() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserUid)
        .get();
    return userDoc.data()?['builderOrgId'] as String?;
  }

  Future<void> _saveAsTemplate() async {
    final templateNameController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Save as Template'),
          content: TextField(
            controller: templateNameController,
            decoration: InputDecoration(
              hintText: 'Template name (e.g. Luxury 4BR)',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text('Save'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    final templateName = templateNameController.text.trim();
    if (templateName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a template name.'), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      final builderOrgId = await _loadBuilderOrgId();
      if (builderOrgId == null || builderOrgId.isEmpty) {
        throw Exception('Builder organization not found');
      }

      final categories = _selectedCategories.map((category) {
        final allowance = _categoryAllowances[category] ?? {'type': 'fixed', 'amount': 0.0};
        return {
          'name': category,
          'allowanceType': allowance['type'] ?? 'fixed',
          'allowanceAmount': allowance['amount'] ?? 0.0,
          'required': true,
        };
      }).toList();

      await FirebaseFirestore.instance
          .collection('builderOrgs')
          .doc(builderOrgId)
          .collection('templates')
          .add({
        'name': templateName,
        'description': 'Saved from project setup',
        'rooms': {
          'bedrooms': int.tryParse(_bedroomsController.text) ?? 0,
          'bathrooms': int.tryParse(_bathroomsController.text) ?? 0,
          'offices': int.tryParse(_officesController.text) ?? 0,
        },
        'fixtureCounts': {
          'lightingFixtures': int.tryParse(_fixturesController.text) ?? 0,
          'plumbingFixtures': int.tryParse(_fixturesController.text) ?? 0,
        },
        'selectedRooms': _selectedRooms,
        'categories': categories,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'createdBy': currentUserUid,
        'usageCount': 0,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Template saved.'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving template: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _loadTemplate() async {
    try {
      final builderOrgId = await _loadBuilderOrgId();
      if (builderOrgId == null || builderOrgId.isEmpty) {
        throw Exception('Builder organization not found');
      }

      final templatesSnap = await FirebaseFirestore.instance
          .collection('builderOrgs')
          .doc(builderOrgId)
          .collection('templates')
          .orderBy('createdAt', descending: true)
          .get();

      if (templatesSnap.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No templates found.'), backgroundColor: Color(0xFF8B8680)),
        );
        return;
      }

      final selectedTemplate = await showDialog<DocumentSnapshot<Map<String, dynamic>>>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text('Load Template'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: templatesSnap.docs.length,
                separatorBuilder: (_, __) => Divider(height: 1),
                itemBuilder: (context, index) {
                  final doc = templatesSnap.docs[index];
                  final data = doc.data();
                  return ListTile(
                    title: Text(data['name']?.toString() ?? 'Unnamed Template'),
                    subtitle: Text(data['description']?.toString() ?? 'Project setup template'),
                    onTap: () => Navigator.pop(dialogContext, doc),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text('Cancel'),
              ),
            ],
          );
        },
      );

      if (selectedTemplate == null) return;

      final data = selectedTemplate.data() ?? {};
      final roomsMap = (data['rooms'] as Map<String, dynamic>?) ?? {};
      final categoriesList = (data['categories'] as List?) ?? [];
      final selectedRooms = (data['selectedRooms'] as List?)?.map((e) => e.toString()).toList() ?? <String>[];

      final loadedCategories = <String>[];
      final loadedAllowances = <String, Map<String, dynamic>>{};
      for (final c in categoriesList) {
        if (c is Map<String, dynamic>) {
          final name = (c['name'] ?? '').toString();
          if (name.isEmpty) continue;
          loadedCategories.add(name);
          loadedAllowances[name] = {
            'type': (c['allowanceType'] ?? 'fixed').toString(),
            'amount': (c['allowanceAmount'] is num) ? (c['allowanceAmount'] as num).toDouble() : 0.0,
          };
        }
      }

      setState(() {
        _bedroomsController.text = (roomsMap['bedrooms'] ?? 0).toString();
        _bathroomsController.text = (roomsMap['bathrooms'] ?? 0).toString();
        _officesController.text = (roomsMap['offices'] ?? 0).toString();
        _fixturesController.text = ((data['fixtureCounts'] as Map<String, dynamic>?)?['lightingFixtures'] ?? 0).toString();
        _selectedRooms = selectedRooms;
        _selectedCategories = loadedCategories.isEmpty ? List<String>.from(_categoryOptions) : loadedCategories;
        _categoryAllowances = loadedAllowances;
        _initializeCategoryAllowances();
      });

      await selectedTemplate.reference.update({
        'usageCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Template loaded.'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading template: $e'), backgroundColor: Colors.red),
      );
    }
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
        'categoryAllowances': _categoryAllowances,
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
        final categoryName = _selectedCategories[i];
        final allowanceConfig = _categoryAllowances[categoryName] ??
            {'type': 'fixed', 'amount': 0.0};
        final categoryRef = projectRef.collection('categories').doc();
        batch2.set(categoryRef, {
          'name': categoryName,
          'required': true,
          'allowanceType': allowanceConfig['type'] ?? 'fixed',
          'allowanceAmount': allowanceConfig['amount'] ?? 0.0,
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
            invitedBy: currentUserUid,
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
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _loadTemplate,
                  icon: Icon(Icons.upload_file_rounded, color: Color(0xFFB8956A), size: 18.0),
                  label: Text('Load Template', style: TextStyle(color: Color(0xFFB8956A), fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Color(0xFFD4C4B0), width: 1.2),
                    backgroundColor: Color(0xFFFDFBF8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                  ),
                ),
              ),
              SizedBox(width: 10.0),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _saveAsTemplate,
                  icon: Icon(Icons.save_as_rounded, color: Colors.white, size: 18.0),
                  label: Text('Save Template', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFB8956A),
                    elevation: 0.0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                  ),
                ),
              ),
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
          if (_selectedCategories.isNotEmpty) ...[
            SizedBox(height: 24.0),
            Text(
              'Category Budgets',
              style: FlutterFlowTheme.of(context).titleMedium.override(
                font: GoogleFonts.interTight(fontWeight: FontWeight.w700),
                color: Color(0xFF2C2C2C),
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Set fixed allowance or price per sq ft for each selected category.',
              style: FlutterFlowTheme.of(context).bodySmall.override(
                font: GoogleFonts.inter(),
                color: Color(0xFF8B8680),
              ),
            ),
            SizedBox(height: 12.0),
            ..._selectedCategories.map((category) {
              final config = _categoryAllowances[category] ??
                  {'type': 'fixed', 'amount': 0.0};
              final type = (config['type'] ?? 'fixed').toString();
              final amount = (config['amount'] ?? 0.0).toString();
              final isFixed = type == 'fixed';
              return Container(
                margin: EdgeInsets.only(bottom: 12.0),
                padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Color(0xFFFAF8F5),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: Color(0xFFE6DDD2), width: 1.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: TextStyle(
                        color: Color(0xFF2C2C2C),
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: Text('Fixed Allowance'),
                            selected: isFixed,
                            onSelected: (_) {
                              setState(() {
                                _categoryAllowances[category] = {
                                  'type': 'fixed',
                                  'amount': config['amount'] ?? 0.0,
                                };
                              });
                            },
                            selectedColor: Color(0xFFF5EDE3),
                            labelStyle: TextStyle(
                              color: isFixed ? Color(0xFFB8956A) : Color(0xFF8B8680),
                              fontWeight: FontWeight.w600,
                              fontSize: 12.0,
                            ),
                            side: BorderSide(
                              color: isFixed ? Color(0xFFB8956A) : Color(0xFFD4C4B0),
                            ),
                            backgroundColor: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Expanded(
                          child: ChoiceChip(
                            label: Text('Price / sq ft'),
                            selected: !isFixed,
                            onSelected: (_) {
                              setState(() {
                                _categoryAllowances[category] = {
                                  'type': 'perSqFt',
                                  'amount': config['amount'] ?? 0.0,
                                };
                              });
                            },
                            selectedColor: Color(0xFFF5EDE3),
                            labelStyle: TextStyle(
                              color: !isFixed ? Color(0xFFB8956A) : Color(0xFF8B8680),
                              fontWeight: FontWeight.w600,
                              fontSize: 12.0,
                            ),
                            side: BorderSide(
                              color: !isFixed ? Color(0xFFB8956A) : Color(0xFFD4C4B0),
                            ),
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.0),
                    TextFormField(
                      key: ValueKey('${category}_$type'),
                      initialValue: amount == '0.0' ? '' : amount,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) {
                        setState(() {
                          _categoryAllowances[category] = {
                            'type': type,
                            'amount': _parseAllowanceAmount(value),
                          };
                        });
                      },
                      decoration: InputDecoration(
                        labelText: isFixed ? 'Allowance Amount' : 'Rate per sq ft',
                        hintText: isFixed ? '\$0.00' : '\$0.00 / sq ft',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Color(0xFFD4C4B0), width: 1.3),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Color(0xFFD4C4B0), width: 1.3),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Color(0xFFB8956A), width: 1.3),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
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
