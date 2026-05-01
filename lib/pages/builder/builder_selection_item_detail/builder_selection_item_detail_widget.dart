import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'builder_selection_item_detail_model.dart';
export 'builder_selection_item_detail_model.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BuilderSelectionItemDetailWidget extends StatefulWidget {
  const BuilderSelectionItemDetailWidget({
    super.key,
    required this.projectId,
    required this.itemId,
  });

  static String routeName = 'BuilderSelectionItemDetail';
  static String routePath = '/builderSelectionItemDetail';

  final String projectId;
  final String itemId;

  @override
  State<BuilderSelectionItemDetailWidget> createState() =>
      _BuilderSelectionItemDetailWidgetState();
}

class _BuilderSelectionItemDetailWidgetState
    extends State<BuilderSelectionItemDetailWidget> {
  late BuilderSelectionItemDetailModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSaving = false;
  bool _initialized = false;
  DateTime? _selectedDueDate;
  String _status = 'notStarted';
  String? _selectedRoom;

  final List<String> _statuses = [
    'notStarted',
    'needsBuilderInput',
    'awaitingClientApproval',
    'approved',
    'ordered',
    'installed',
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BuilderSelectionItemDetailModel());

    _model.nameController ??= TextEditingController();
    _model.nameFocusNode ??= FocusNode();

    _model.brandController ??= TextEditingController();
    _model.brandFocusNode ??= FocusNode();

    _model.allowanceController ??= TextEditingController();
    _model.allowanceFocusNode ??= FocusNode();

    _model.actualCostController ??= TextEditingController();
    _model.actualCostFocusNode ??= FocusNode();

    _model.notesController ??= TextEditingController();
    _model.notesFocusNode ??= FocusNode();

    _model.linkController ??= TextEditingController();
    _model.linkFocusNode ??= FocusNode();

    _model.roomController ??= TextEditingController();
    _model.roomFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  double _parseAmount(String raw) {
    final cleaned = raw.replaceAll(RegExp('[^0-9.]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'No due date';
    return DateFormat('MMM d, yyyy').format(date);
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('projects')
          .doc(widget.projectId)
          .collection('items')
          .doc(widget.itemId)
          .update({
        'name': _model.nameController.text.trim(),
        'brand': _model.brandController.text.trim(),
        'allowance': _parseAmount(_model.allowanceController.text),
        'actualCost': _parseAmount(_model.actualCostController.text),
        'notes': _model.notesController.text.trim(),
        'linkUrl': _model.linkController.text.trim(),
        'roomName': _selectedRoom ?? _model.roomController.text.trim(),
        'status': _status,
        'dueDate': _selectedDueDate != null
            ? Timestamp.fromDate(_selectedDueDate!)
            : null,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selection updated.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving changes: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    TextInputType keyboardType = TextInputType.text,
    String? hintText,
    int maxLines = 1,
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
          maxLines: maxLines,
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
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FlutterFlowIconButton(
                borderColor: Colors.transparent,
                borderRadius: 20.0,
                borderWidth: 1.0,
                buttonSize: 40.0,
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: Color(0xFF2C2C2C),
                  size: 24.0,
                ),
                onPressed: () => context.pop(),
              ),
              Text(
                'Selection Detail',
                style: FlutterFlowTheme.of(context).titleMedium.override(
                      font: GoogleFonts.interTight(
                        fontWeight: FontWeight.bold,
                        fontStyle: FlutterFlowTheme.of(context)
                            .titleMedium
                            .fontStyle,
                      ),
                      color: Color(0xFF2C2C2C),
                      fontSize: 18.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.bold,
                      fontStyle:
                          FlutterFlowTheme.of(context).titleMedium.fontStyle,
                    ),
              ),
            ].divide(SizedBox(width: 12.0)),
          ),
          centerTitle: false,
          elevation: 0.0,
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
+              .collection('projects')
+              .doc(widget.projectId)
+              .collection('items')
+              .doc(widget.itemId)
+              .snapshots(),
+          builder: (context, snapshot) {
+            if (!snapshot.hasData) {
+              return Center(
+                child: CircularProgressIndicator(
+                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB8956A)),
+                ),
+              );
+            }
+
+            if (!snapshot.data!.exists) {
+              return Center(
+                child: Text(
+                  'Selection not found',
+                  style: FlutterFlowTheme.of(context).bodyMedium.override(
+                        font: GoogleFonts.inter(),
+                        color: Color(0xFF8B8680),
+                        letterSpacing: 0.0,
+                      ),
+                ),
+              );
+            }
+
+            final data = snapshot.data!.data() as Map<String, dynamic>;
+            final categoryName = data['categoryName'] ?? 'Category';
+            final imageUrl = data['imageUrl'] as String?;
+            final locked = data['locked'] == true;
+
+            if (!_initialized) {
+              _model.nameController.text = data['name'] ?? '';
+              _model.brandController.text = data['brand'] ?? '';
+              _model.allowanceController.text =
+                  (data['allowance'] ?? '').toString();
+              _model.actualCostController.text =
+                  (data['actualCost'] ?? '').toString();
+              _model.notesController.text = data['notes'] ?? '';
+              _model.linkController.text = data['linkUrl'] ?? '';
+              _model.roomController.text = data['roomName'] ?? '';
+              _selectedRoom = data['roomName'] as String?;
+              _status = data['status'] ?? 'notStarted';
+              _selectedDueDate =
+                  (data['dueDate'] as Timestamp?)?.toDate();
+              _initialized = true;
+            }
+
+            return StreamBuilder<QuerySnapshot>(
+              stream: FirebaseFirestore.instance
+                  .collection('projects')
+                  .doc(widget.projectId)
+                  .collection('rooms')
+                  .orderBy('displayOrder')
+                  .snapshots(),
+              builder: (context, roomsSnapshot) {
+                final rooms = roomsSnapshot.hasData
+                    ? roomsSnapshot.data!.docs
+                        .map((doc) =>
+                            (doc.data() as Map<String, dynamic>)['name'] as String)
+                        .toList()
+                    : <String>[];
+
+                return SingleChildScrollView(
+                  child: Padding(
+                    padding:
+                        EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 32.0),
+                    child: Column(
+                      crossAxisAlignment: CrossAxisAlignment.start,
+                      children: [
+                        Container(
+                          width: double.infinity,
+                          decoration: BoxDecoration(
+                            color: Colors.white,
+                            borderRadius: BorderRadius.circular(16.0),
+                            border: Border.all(
+                              color: Color(0xFFD4C4B0),
+                              width: 1.0,
+                            ),
+                            boxShadow: [
+                              BoxShadow(
+                                blurRadius: 12.0,
+                                color: Color(0x14000000),
+                                offset: Offset(0.0, 4.0),
+                              )
+                            ],
+                          ),
+                          child: Padding(
+                            padding: EdgeInsets.all(16.0),
+                            child: Column(
+                              crossAxisAlignment: CrossAxisAlignment.start,
+                              children: [
+                                Text(
+                                  categoryName.toString().toUpperCase(),
+                                  style: FlutterFlowTheme.of(context)
+                                      .labelSmall
+                                      .override(
+                                        font: GoogleFonts.inter(
+                                          fontWeight: FontWeight.bold,
+                                        ),
+                                        color: Color(0xFFB8956A),
+                                        letterSpacing: 1.0,
+                                      ),
+                                ),
+                                SizedBox(height: 8.0),
+                                if (imageUrl != null && imageUrl.isNotEmpty)
+                                  ClipRRect(
+                                    borderRadius: BorderRadius.circular(12.0),
+                                    child: Image.network(
+                                      imageUrl,
+                                      width: double.infinity,
+                                      height: 200.0,
+                                      fit: BoxFit.cover,
+                                    ),
+                                  )
+                                else
+                                  Container(
+                                    width: double.infinity,
+                                    height: 200.0,
+                                    decoration: BoxDecoration(
+                                      color: Color(0xFFF5F0EB),
+                                      borderRadius: BorderRadius.circular(12.0),
+                                    ),
+                                    child: Icon(
+                                      Icons.image_rounded,
+                                      color: Color(0xFFD4C4B0),
+                                      size: 48.0,
+                                    ),
+                                  ),
+                                if (locked)
+                                  Padding(
+                                    padding: EdgeInsetsDirectional.fromSTEB(
+                                        0.0, 12.0, 0.0, 0.0),
+                                    child: Container(
+                                      decoration: BoxDecoration(
+                                        color: Color(0xFFFCE8EC),
+                                        borderRadius: BorderRadius.circular(8.0),
+                                      ),
+                                      child: Padding(
+                                        padding: EdgeInsets.all(8.0),
+                                        child: Row(
+                                          children: [
+                                            Icon(
+                                              Icons.lock_rounded,
+                                              color: Color(0xFFCF6679),
+                                              size: 16.0,
+                                            ),
+                                            SizedBox(width: 6.0),
+                                            Text(
+                                              'Approved and locked',
+                                              style: FlutterFlowTheme.of(context)
+                                                  .bodySmall
+                                                  .override(
+                                                    font: GoogleFonts.inter(
+                                                      fontWeight: FontWeight.w600,
+                                                    ),
+                                                    color: Color(0xFFCF6679),
+                                                  ),
+                                            ),
+                                          ],
+                                        ),
+                                      ),
+                                    ),
+                                  ),
+                              ].divide(SizedBox(height: 12.0)),
+                            ),
+                          ),
+                        ),
+                        SizedBox(height: 20.0),
+                        _buildTextField(
+                          label: 'Item Name',
+                          controller: _model.nameController,
+                          focusNode: _model.nameFocusNode,
+                          hintText: 'e.g. Kitchen Faucet',
+                        ),
+                        _buildTextField(
+                          label: 'Brand / Model',
+                          controller: _model.brandController,
+                          focusNode: _model.brandFocusNode,
+                          hintText: 'e.g. Delta Trinsic',
+                        ),
+                        Row(
+                          children: [
+                            Expanded(
+                              child: _buildTextField(
+                                label: 'Allowance',
+                                controller: _model.allowanceController,
+                                focusNode: _model.allowanceFocusNode,
+                                keyboardType: TextInputType.number,
+                                hintText: '0.00',
+                              ),
+                            ),
+                            SizedBox(width: 12.0),
+                            Expanded(
+                              child: _buildTextField(
+                                label: 'Actual Cost',
+                                controller: _model.actualCostController,
+                                focusNode: _model.actualCostFocusNode,
+                                keyboardType: TextInputType.number,
+                                hintText: '0.00',
+                              ),
+                            ),
+                          ],
+                        ),
+                        _buildTextField(
+                          label: 'Product Link',
+                          controller: _model.linkController,
+                          focusNode: _model.linkFocusNode,
+                          keyboardType: TextInputType.url,
+                          hintText: 'https://',
+                        ),
+                        Column(
+                          crossAxisAlignment: CrossAxisAlignment.start,
+                          children: [
+                            Text(
+                              'Status',
+                              style: FlutterFlowTheme.of(context)
+                                  .labelMedium
+                                  .override(
+                                    font: GoogleFonts.inter(
+                                      fontWeight: FontWeight.w600,
+                                    ),
+                                    color: Color(0xFF5C5450),
+                                    fontSize: 13.0,
+                                    letterSpacing: 0.3,
+                                  ),
+                            ),
+                            Container(
+                              width: double.infinity,
+                              decoration: BoxDecoration(
+                                color: Color(0xFFFAF8F5),
+                                borderRadius: BorderRadius.circular(12.0),
+                                border: Border.all(
+                                  color: Color(0xFFD4C4B0),
+                                  width: 1.5,
+                                ),
+                              ),
+                              child: DropdownButtonHideUnderline(
+                                child: DropdownButton<String>(
+                                  value: _status,
+                                  isExpanded: true,
+                                  items: _statuses
+                                      .map(
+                                        (status) => DropdownMenuItem(
+                                          value: status,
+                                          child: Padding(
+                                            padding: EdgeInsetsDirectional.fromSTEB(
+                                                12.0, 0.0, 12.0, 0.0),
+                                            child: Text(status),
+                                          ),
+                                        ),
+                                      )
+                                      .toList(),
+                                  onChanged: (value) {
+                                    if (value == null) return;
+                                    setState(() {
+                                      _status = value;
+                                    });
+                                  },
+                                ),
+                              ),
+                            ),
+                          ].divide(SizedBox(height: 6.0)),
+                        ),
+                        Column(
+                          crossAxisAlignment: CrossAxisAlignment.start,
+                          children: [
+                            Text(
+                              'Due Date',
+                              style: FlutterFlowTheme.of(context)
+                                  .labelMedium
+                                  .override(
+                                    font: GoogleFonts.inter(
+                                      fontWeight: FontWeight.w600,
+                                    ),
+                                    color: Color(0xFF5C5450),
+                                    fontSize: 13.0,
+                                    letterSpacing: 0.3,
+                                  ),
+                            ),
+                            InkWell(
+                              onTap: _pickDueDate,
+                              child: Container(
+                                width: double.infinity,
+                                decoration: BoxDecoration(
+                                  color: Color(0xFFFAF8F5),
+                                  borderRadius: BorderRadius.circular(12.0),
+                                  border: Border.all(
+                                    color: Color(0xFFD4C4B0),
+                                    width: 1.5,
+                                  ),
+                                ),
+                                child: Padding(
+                                  padding: EdgeInsetsDirectional.fromSTEB(
+                                      16.0, 16.0, 16.0, 16.0),
+                                  child: Row(
+                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
+                                    children: [
+                                      Text(
+                                        _formatDate(_selectedDueDate),
+                                        style: FlutterFlowTheme.of(context)
+                                            .bodyMedium
+                                            .override(
+                                              font: GoogleFonts.inter(),
+                                              color: Color(0xFF2C2420),
+                                            ),
+                                      ),
+                                      Icon(
+                                        Icons.calendar_today_rounded,
+                                        color: Color(0xFFB8956A),
+                                        size: 18.0,
+                                      ),
+                                    ],
+                                  ),
+                                ),
+                              ),
+                            ),
+                          ].divide(SizedBox(height: 6.0)),
+                        ),
+                        if (rooms.isNotEmpty)
+                          Column(
+                            crossAxisAlignment: CrossAxisAlignment.start,
+                            children: [
+                              Text(
+                                'Room Assignment',
+                                style: FlutterFlowTheme.of(context)
+                                    .labelMedium
+                                    .override(
+                                      font: GoogleFonts.inter(
+                                        fontWeight: FontWeight.w600,
+                                      ),
+                                      color: Color(0xFF5C5450),
+                                      fontSize: 13.0,
+                                      letterSpacing: 0.3,
+                                    ),
+                              ),
+                              Container(
+                                width: double.infinity,
+                                decoration: BoxDecoration(
+                                  color: Color(0xFFFAF8F5),
+                                  borderRadius: BorderRadius.circular(12.0),
+                                  border: Border.all(
+                                    color: Color(0xFFD4C4B0),
+                                    width: 1.5,
+                                  ),
+                                ),
+                                child: DropdownButtonHideUnderline(
+                                  child: DropdownButton<String>(
+                                    value: _selectedRoom,
+                                    isExpanded: true,
+                                    hint: Padding(
+                                      padding: EdgeInsetsDirectional.fromSTEB(
+                                          12.0, 0.0, 12.0, 0.0),
+                                      child: Text('Select room'),
+                                    ),
+                                    items: rooms
+                                        .map(
+                                          (room) => DropdownMenuItem(
+                                            value: room,
+                                            child: Padding(
+                                              padding:
+                                                  EdgeInsetsDirectional.fromSTEB(
+                                                      12.0, 0.0, 12.0, 0.0),
+                                              child: Text(room),
+                                            ),
+                                          ),
+                                        )
+                                        .toList(),
+                                    onChanged: (value) {
+                                      setState(() {
+                                        _selectedRoom = value;
+                                      });
+                                    },
+                                  ),
+                                ),
+                              ),
+                            ].divide(SizedBox(height: 6.0)),
+                          ),
+                        _buildTextField(
+                          label: 'Notes',
+                          controller: _model.notesController,
+                          focusNode: _model.notesFocusNode,
+                          maxLines: 4,
+                          hintText: 'Add notes for the client or team',
+                        ),
+                        SizedBox(height: 12.0),
+                        FFButtonWidget(
+                          onPressed: _isSaving ? null : _saveChanges,
+                          text: _isSaving ? 'Saving...' : 'Save Changes',
+                          options: FFButtonOptions(
+                            width: double.infinity,
+                            height: 52.0,
+                            color: Color(0xFFB8956A),
+                            textStyle: FlutterFlowTheme.of(context)
+                                .titleSmall
+                                .override(
+                                  font: GoogleFonts.interTight(
+                                    fontWeight: FontWeight.bold,
+                                  ),
+                                  color: Colors.white,
+                                ),
+                            elevation: 0.0,
+                            borderRadius: BorderRadius.circular(12.0),
+                          ),
+                        ),
+                      ].divide(SizedBox(height: 12.0)),
+                    ),
+                  ),
+                );
+              },
+            );
+          },
         ),
       ),
     );
   }
 }
