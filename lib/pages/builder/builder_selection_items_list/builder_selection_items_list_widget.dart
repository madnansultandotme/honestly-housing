import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'builder_selection_items_list_model.dart';
export 'builder_selection_items_list_model.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BuilderSelectionItemsListWidget extends StatefulWidget {
  const BuilderSelectionItemsListWidget({
    super.key,
    required this.projectId,
  });

  static String routeName = 'BuilderSelectionItemsList';
  static String routePath = '/builderSelectionItemsList';

  final String projectId;

  @override
  State<BuilderSelectionItemsListWidget> createState() =>
      _BuilderSelectionItemsListWidgetState();
}

class _BuilderSelectionItemsListWidgetState
    extends State<BuilderSelectionItemsListWidget> {
  late BuilderSelectionItemsListModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  String _selectedFilter = 'All';

  final List<String> _filters = [
    'All',
    'Awaiting Approval',
    'Approved',
    'Ordered',
    'Installed',
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BuilderSelectionItemsListModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  String _normalizeStatus(String? status) {
    return (status ?? 'notStarted').toLowerCase().replaceAll(' ', '');
  }

  bool _matchesFilter(String? status) {
    if (_selectedFilter == 'All') return true;
    final normalized = _normalizeStatus(status);
    if (_selectedFilter == 'Awaiting Approval') {
      return normalized == 'awaitingclientapproval' ||
          normalized == 'needsbuilderinput' ||
          normalized == 'pendingreview';
    }
    if (_selectedFilter == 'Approved') {
      return normalized == 'approved';
    }
    if (_selectedFilter == 'Ordered') {
      return normalized == 'ordered';
    }
    if (_selectedFilter == 'Installed') {
      return normalized == 'installed';
    }
    return true;
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'No due date';
    return DateFormat('MMM d, yyyy').format(timestamp.toDate());
  }

  Color _statusColor(String? status) {
    switch (_normalizeStatus(status)) {
      case 'approved':
        return Colors.green;
      case 'awaitingclientapproval':
      case 'needsbuilderinput':
      case 'pendingreview':
        return Color(0xFFB8956A);
      case 'ordered':
        return Colors.blue;
      case 'installed':
        return Color(0xFF7CB342);
      default:
        return Color(0xFF8B8680);
    }
  }

  String _statusLabel(String? status) {
    switch (_normalizeStatus(status)) {
      case 'approved':
        return 'Approved';
      case 'awaitingclientapproval':
        return 'Awaiting Client Approval';
      case 'needsbuilderinput':
        return 'Needs Builder Input';
      case 'pendingreview':
        return 'Pending Review';
      case 'ordered':
        return 'Ordered';
      case 'installed':
        return 'Installed';
      default:
        return 'Not Started';
    }
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _selectedFilter = label;
        });
      },
      selectedColor: Color(0xFFF5EDE3),
      checkmarkColor: Color(0xFFB8956A),
      labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
            font: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
            ),
            color: isSelected ? Color(0xFFB8956A) : Color(0xFF8B8680),
            fontSize: 12.0,
            letterSpacing: 0.0,
            fontWeight: FontWeight.w600,
            fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
          ),
      backgroundColor: Color(0xFFF5F0EB),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(
          color: isSelected ? Color(0xFFB8956A) : Color(0xFFD4C4B0),
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
                'Selections',
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
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(20.0, 12.0, 20.0, 0.0),
              child: Wrap(
                spacing: 10.0,
                runSpacing: 10.0,
                children: _filters.map(_buildFilterChip).toList(),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('projects')
                    .doc(widget.projectId)
                    .collection('items')
                    .orderBy('dueDate', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFFB8956A)),
                      ),
                    );
                  }

                  final items = snapshot.data!.docs
                      .where((doc) =>
                          _matchesFilter((doc.data() as Map<String, dynamic>)[
                              'status']))
                      .toList();

                  if (items.isEmpty) {
                    return Center(
                      child: Text(
                        'No selections found',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.inter(),
                              color: Color(0xFF8B8680),
                              letterSpacing: 0.0,
                            ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsetsDirectional.fromSTEB(20.0, 16.0, 20.0, 20.0),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final doc = items[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final name = data['name'] ?? 'Selection Item';
                      final categoryName = data['categoryName'] ?? 'Category';
                      final status = data['status'] as String?;
                      final dueDate = data['dueDate'] as Timestamp?;
                      final roomName = data['roomName'] as String?;

                      return Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
                        child: InkWell(
                          onTap: () {
                            context.pushNamed(
                              'BuilderSelectionItemDetail',
                              queryParameters: {
                                'projectId': widget.projectId,
                                'itemId': doc.id,
                              },
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 8.0,
                                  color: Color(0x14000000),
                                  offset: Offset(0.0, 2.0),
                                )
                              ],
                              borderRadius: BorderRadius.circular(14.0),
                              border: Border.all(
                                color: Color(0xFFD4C4B0),
                                width: 1.0,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        categoryName.toString().toUpperCase(),
                                        style: FlutterFlowTheme.of(context)
                                            .labelSmall
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight: FontWeight.bold,
                                              ),
                                              color: Color(0xFFB8956A),
                                              letterSpacing: 1.0,
                                            ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: _statusColor(status)
                                              .withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsetsDirectional.fromSTEB(
                                              8.0, 4.0, 8.0, 4.0),
                                          child: Text(
                                            _statusLabel(status),
                                            style: FlutterFlowTheme.of(context)
                                                .labelSmall
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  color: _statusColor(status),
                                                  fontSize: 11.0,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 6.0, 0.0, 0.0),
                                    child: Text(
                                      name,
                                      style: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .override(
                                            font: GoogleFonts.interTight(
                                              fontWeight: FontWeight.w600,
                                            ),
                                            color: Color(0xFF2C2C2C),
                                          ),
                                    ),
                                  ),
                                  if (roomName != null && roomName.isNotEmpty)
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 4.0, 0.0, 0.0),
                                      child: Text(
                                        'Room: $roomName',
                                        style: FlutterFlowTheme.of(context)
                                            .bodySmall
                                            .override(
                                              font: GoogleFonts.inter(),
                                              color: Color(0xFF8B8680),
                                            ),
                                      ),
                                    ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 10.0, 0.0, 0.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today_rounded,
                                              color: Color(0xFF8B8680),
                                              size: 14.0,
                                            ),
                                            Text(
                                              _formatDate(dueDate),
                                              style: FlutterFlowTheme.of(context)
                                                  .bodySmall
                                                  .override(
                                                    font: GoogleFonts.inter(),
                                                    color: Color(0xFF8B8680),
                                                  ),
                                            ),
                                          ].divide(SizedBox(width: 6.0)),
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              color: Color(0xFFB8956A),
                                              size: 14.0,
                                            ),
                                            Text(
                                              'Manage',
                                              style: FlutterFlowTheme.of(context)
                                                  .bodySmall
                                                  .override(
                                                    font: GoogleFonts.inter(
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                    color: Color(0xFFB8956A),
                                                  ),
                                            ),
                                          ].divide(SizedBox(width: 6.0)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
