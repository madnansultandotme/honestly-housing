import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/auth/firebase_auth/auth_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '/pages/builder/builder_project_setup/widgets/client_invitation_dialog.dart';
import 'builder_project_details_model.dart';
export 'builder_project_details_model.dart';

/// # Builder Project Detail
///
/// Build project overview for Builder role with management capabilities.
///
/// Show project info, client details, room counts (bedrooms, bathrooms,
/// fixtures). Use **progress_bar** for selection completion,
/// **due_this_week_list** for upcoming deadlines, **status_badge** for status
/// counts. Add "Edit Setup" button to navigate to Builder Project Setup. Add
/// "Add Options" button for uploading curated options. Show client approval
/// status and pending decisions. Query projects, rooms, items, dueDates.
/// Design on white (#FFFFFF) with brass accent (#B8956A) for action buttons
/// and progress, soft taupe (#D4C4B0) status chips, warm neutral gray
/// (#8B8680) for dates. Apply professional spacing.
class BuilderProjectDetailsWidget extends StatefulWidget {
  const BuilderProjectDetailsWidget({
    super.key,
    this.projectId,
  });

  static String routeName = 'BuilderProjectDetails';
  static String routePath = '/builderProjectDetails';

  final String? projectId;

  @override
  State<BuilderProjectDetailsWidget> createState() =>
      _BuilderProjectDetailsWidgetState();
}

class _BuilderProjectDetailsWidgetState
    extends State<BuilderProjectDetailsWidget> {
  late BuilderProjectDetailsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BuilderProjectDetailsModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectId = widget.projectId ?? '';

    Future<void> _exportMaterialsList() async {
      try {
        final itemsSnap = await FirebaseFirestore.instance
            .collection('projects')
            .doc(projectId)
            .collection('items')
            .where('status', whereIn: ['approved', 'ordered', 'installed'])
            .get();

        if (itemsSnap.docs.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No approved items to export.'),
              backgroundColor: Color(0xFF8B8680),
            ),
          );
          return;
        }

        final csvRows = [
          'Item Name,Category,Brand,Link,Allowance,Actual Cost,Status',
        ];

        for (final doc in itemsSnap.docs) {
          final d = doc.data();
          final name = (d['name'] ?? '').toString().replaceAll(',', ' ');
          final cat = (d['categoryName'] ?? '').toString().replaceAll(',', ' ');
          final brand = (d['brand'] ?? '').toString().replaceAll(',', ' ');
          final link = (d['linkUrl'] ?? '').toString();
          final allowance = (d['allowance'] ?? 0).toString();
          final cost = (d['actualCost'] ?? 0).toString();
          final status = (d['status'] ?? '').toString();
          csvRows.add('$name,$cat,$brand,$link,$allowance,$cost,$status');
        }

        final csvString = csvRows.join('\n');
        await Clipboard.setData(ClipboardData(text: csvString));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Materials list copied to clipboard (${itemsSnap.docs.length} items)'),
            backgroundColor: Color(0xFFB8956A),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    
    if (projectId.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text('No project ID provided'),
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('projects')
          .doc(projectId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        if (!snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFFB8956A),
              ),
            ),
          );
        }

        if (!snapshot.data!.exists) {
          return Scaffold(
            body: Center(
              child: Text('Project not found'),
            ),
          );
        }

        final projectData = snapshot.data!.data() as Map<String, dynamic>;
        final projectName = projectData['name'] as String? ?? 'Untitled Project';
        final status = projectData['status'] as String? ?? 'unknown';
        final clientIds = (projectData['clientIds'] as List?)?.cast<String>() ?? [];
        final clientId = clientIds.isNotEmpty ? clientIds.first : '';
        final address = projectData['address'] as String? ?? '';
        final startDate = (projectData['startDate'] as Timestamp?)?.toDate();
        final targetDate = (projectData['targetCompletionDate'] as Timestamp?)?.toDate();

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
          title: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      projectName,
                      style:
                          FlutterFlowTheme.of(context).headlineMedium.override(
                                font: GoogleFonts.interTight(
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .headlineMedium
                                      .fontStyle,
                                ),
                                color: Color(0xFF1A1A1A),
                                fontSize: 22.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.bold,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .headlineMedium
                                    .fontStyle,
                              ),
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0xFFF0EAE2),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  10.0, 4.0, 10.0, 4.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 7.0,
                                    height: 7.0,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFB8956A),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        5.0, 0.0, 5.0, 0.0),
                                    child: Text(
                                      'In Progress',
                                      style: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.w600,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmall
                                                      .fontStyle,
                                            ),
                                            color: Color(0xFFB8956A),
                                            fontSize: 11.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .labelSmall
                                                    .fontStyle,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Text(
                            'ID #${projectId.substring(0, 12).toUpperCase()}',
                            style: FlutterFlowTheme.of(context)
                                .labelSmall
                                .override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .labelSmall
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .labelSmall
                                        .fontStyle,
                                  ),
                                  color: Color(0xFF8B8680),
                                  fontSize: 11.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .labelSmall
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .labelSmall
                                      .fontStyle,
                                ),
                          ),
                        ].divide(SizedBox(width: 6.0)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 0.0,
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20.0, 16.0, 20.0, 0.0),
                child: InkWell(
                  onTap: () {
                    context.pushNamed(
                      'BuilderSelectionItemsList',
                      queryParameters: {
                        'projectId': projectId,
                      },
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xFFB8956A),
                      borderRadius: BorderRadius.circular(14.0),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 12.0,
                          color: Color(0x1A000000),
                          offset: Offset(0.0, 4.0),
                        )
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                          16.0, 14.0, 16.0, 14.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Manage Selections',
                            style: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  font: GoogleFonts.interTight(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  color: Colors.white,
                                  letterSpacing: 0.0,
                                ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white,
                            size: 20.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 20.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xFF1A1A1A),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 20.0,
                        color: Color(0x1A000000),
                        offset: Offset(
                          0.0,
                          6.0,
                        ),
                      )
                    ],
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'CLIENT',
                                    style: FlutterFlowTheme.of(context)
                                        .labelSmall
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .labelSmall
                                                    .fontStyle,
                                          ),
                                          color: Color(0xFF8B8680),
                                          fontSize: 10.0,
                                          letterSpacing: 1.5,
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelSmall
                                                  .fontStyle,
                                        ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 4.0, 0.0, 0.0),
                                    child: FutureBuilder<DocumentSnapshot>(
                                      future: clientId.isNotEmpty
                                          ? FirebaseFirestore.instance.collection('users').doc(clientId).get()
                                          : null,
                                      builder: (context, userSnap) {
                                        final hasClient = clientId.isNotEmpty && userSnap.hasData && userSnap.data!.exists;
                                        final clientName = hasClient
                                            ? (userSnap.data!.data() as Map<String, dynamic>)['display_name'] ?? 'Client'
                                            : 'No Client Assigned';
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              clientName,
                                              style: FlutterFlowTheme.of(context)
                                                  .titleMedium
                                                  .override(
                                                    font: GoogleFonts.interTight(
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                    color: Colors.white,
                                                    fontSize: 16.0,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                            if (!hasClient)
                                              Padding(
                                                padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                                                child: InkWell(
                                                  onTap: () async {
                                                    final result = await showDialog<bool>(
                                                      context: context,
                                                      barrierDismissible: false,
                                                      builder: (dialogContext) => ClientInvitationDialog(
                                                        projectId: projectId,
                                                        projectName: projectName,
                                                      ),
                                                    );
                                                    // Dialog returns true if client was added successfully
                                                    if (result == true) {
                                                      // The StreamBuilder will automatically refresh
                                                      print('Client added successfully');
                                                    }
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFFB8956A),
                                                      borderRadius: BorderRadius.circular(8.0),
                                                    ),
                                                    child: Padding(
                                                      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons.person_add,
                                                            color: Colors.white,
                                                            size: 14.0,
                                                          ),
                                                          SizedBox(width: 6.0),
                                                          Text(
                                                            'Add Client',
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 12.0,
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 4.0, 0.0, 0.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Icon(
                                          Icons.location_on_outlined,
                                          color: Color(0xFF8B8680),
                                          size: 13.0,
                                        ),
                                        Text(
                                          address.isNotEmpty ? address : 'No address set',
                                          style: FlutterFlowTheme.of(context)
                                              .labelSmall
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelSmall
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelSmall
                                                          .fontStyle,
                                                ),
                                                color: Color(0xFF8B8680),
                                                fontSize: 12.0,
                                                letterSpacing: 0.0,
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .fontStyle,
                                              ),
                                        ),
                                      ].divide(SizedBox(width: 4.0)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  12.0, 10.0, 12.0, 10.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFF2C2C2C),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'CONTRACT',
                                        style: FlutterFlowTheme.of(context)
                                            .labelSmall
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .fontStyle,
                                              ),
                                              color: Color(0xFF8B8680),
                                              fontSize: 9.0,
                                              letterSpacing: 1.2,
                                              fontWeight: FontWeight.w600,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmall
                                                      .fontStyle,
                                            ),
                                      ),
                                      Text(
                                        '\$${NumberFormat('#,###').format(projectData['totalBudget'] ?? 0)}',
                                        style: FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .override(
                                              font: GoogleFonts.interTight(
                                                fontWeight: FontWeight.bold,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleMedium
                                                        .fontStyle,
                                              ),
                                              color: Color(0xFFB8956A),
                                              fontSize: 18.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.bold,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .titleMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                    ].divide(SizedBox(height: 2.0)),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          thickness: 1.0,
                          color: Color(0xFF2C2C2C),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'START DATE',
                                  style: FlutterFlowTheme.of(context)
                                      .labelSmall
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelSmall
                                                  .fontStyle,
                                        ),
                                        color: Color(0xFF8B8680),
                                        fontSize: 9.0,
                                        letterSpacing: 1.2,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelSmall
                                            .fontStyle,
                                      ),
                                ),
                                Text(
                                  startDate != null ? DateFormat('MMM dd, yyyy').format(startDate) : 'Not set',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w500,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        color: Colors.white,
                                        fontSize: 13.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                ),
                              ].divide(SizedBox(height: 2.0)),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'COMPLETION',
                                  style: FlutterFlowTheme.of(context)
                                      .labelSmall
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelSmall
                                                  .fontStyle,
                                        ),
                                        color: Color(0xFF8B8680),
                                        fontSize: 9.0,
                                        letterSpacing: 1.2,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelSmall
                                            .fontStyle,
                                      ),
                                ),
                                Text(
                                  targetDate != null ? DateFormat('MMM dd, yyyy').format(targetDate) : 'Not set',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w500,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        color: Colors.white,
                                        fontSize: 13.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                ),
                              ].divide(SizedBox(height: 2.0)),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'DAYS LEFT',
                                  style: FlutterFlowTheme.of(context)
                                      .labelSmall
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelSmall
                                                  .fontStyle,
                                        ),
                                        color: Color(0xFF8B8680),
                                        fontSize: 9.0,
                                        letterSpacing: 1.2,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelSmall
                                            .fontStyle,
                                      ),
                                ),
                                Text(
                                  targetDate != null 
                                      ? '${targetDate.difference(DateTime.now()).inDays} days'
                                      : 'N/A',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        color: Color(0xFFB8956A),
                                        fontSize: 13.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                ),
                              ].divide(SizedBox(height: 2.0)),
                            ),
                          ],
                        ),
                      ].divide(SizedBox(height: 16.0)),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 20.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 8.0,
                        color: Color(0x0A000000),
                        offset: Offset(
                          0.0,
                          2.0,
                        ),
                      )
                    ],
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                      color: Color(0xFFEDE8E2),
                      width: 1.0,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('projects')
                              .doc(projectId)
                              .collection('items')
                              .snapshots(),
                          builder: (context, itemsSnapshot) {
                            final totalItems = itemsSnapshot.hasData ? itemsSnapshot.data!.docs.length : 0;
                            final selectedItems = itemsSnapshot.hasData
                                ? itemsSnapshot.data!.docs.where((doc) {
                                    final status = (doc.data() as Map<String, dynamic>)['status'] as String?;
                                    return status == 'approved' || status == 'ordered' || status == 'installed';
                                  }).length
                                : 0;
                            final pendingItems = itemsSnapshot.hasData
                                ? itemsSnapshot.data!.docs.where((doc) {
                                    final status = (doc.data() as Map<String, dynamic>)['status'] as String?;
                                    return status == 'awaitingClientApproval' || status == 'pending';
                                  }).length
                                : 0;
                            final progress = totalItems > 0 ? (selectedItems / totalItems) : 0.0;
                            final progressPercent = (progress * 100).toInt();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Selection Progress',
                                      style: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .override(
                                            font: GoogleFonts.interTight(
                                              fontWeight: FontWeight.bold,
                                              fontStyle: FlutterFlowTheme.of(context)
                                                  .titleSmall
                                                  .fontStyle,
                                            ),
                                            color: Color(0xFF1A1A1A),
                                            fontSize: 14.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FlutterFlowTheme.of(context)
                                                .titleSmall
                                                .fontStyle,
                                          ),
                                    ),
                                    Text(
                                      '$progressPercent% Complete',
                                      style: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.bold,
                                              fontStyle: FlutterFlowTheme.of(context)
                                                  .labelSmall
                                                  .fontStyle,
                                            ),
                                            color: Color(0xFFB8956A),
                                            fontSize: 13.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FlutterFlowTheme.of(context)
                                                .labelSmall
                                                .fontStyle,
                                          ),
                                    ),
                                  ],
                                ),
                                Container(
                                  width: double.infinity,
                                  height: 8.0,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF0EAE2),
                                    borderRadius: BorderRadius.circular(100.0),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: progress,
                                    child: Container(
                                      height: 8.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xFFB8956A),
                                        borderRadius: BorderRadius.circular(100.0),
                                      ),
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '$selectedItems of $totalItems items selected',
                                      style: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FlutterFlowTheme.of(context)
                                                  .labelSmall
                                                  .fontWeight,
                                              fontStyle: FlutterFlowTheme.of(context)
                                                  .labelSmall
                                                  .fontStyle,
                                            ),
                                            color: Color(0xFF8B8680),
                                            fontSize: 11.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FlutterFlowTheme.of(context)
                                                .labelSmall
                                                .fontWeight,
                                            fontStyle: FlutterFlowTheme.of(context)
                                                .labelSmall
                                                .fontStyle,
                                          ),
                                    ),
                                    Text(
                                      '$pendingItems pending',
                                      style: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FlutterFlowTheme.of(context)
                                                  .labelSmall
                                                  .fontWeight,
                                              fontStyle: FlutterFlowTheme.of(context)
                                                  .labelSmall
                                                  .fontStyle,
                                            ),
                                            color: Color(0xFFC0392B),
                                            fontSize: 11.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FlutterFlowTheme.of(context)
                                                .labelSmall
                                                .fontWeight,
                                            fontStyle: FlutterFlowTheme.of(context)
                                                .labelSmall
                                                .fontStyle,
                                          ),
                                    ),
                                  ],
                                ),
                              ].divide(SizedBox(height: 14.0)),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: MediaQuery.sizeOf(context).width * 0.3,
                      decoration: BoxDecoration(
                        color: Color(0xFFF7F4F0),
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bed_outlined,
                              color: Color(0xFFB8956A),
                              size: 24.0,
                            ),
                            SizedBox(height: 4.0),
                            Text(
                              '${projectData['bedrooms'] ?? 0}',
                              style: FlutterFlowTheme.of(context)
                                  .titleLarge
                                  .override(
                                    font: GoogleFonts.interTight(
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleLarge
                                          .fontStyle,
                                    ),
                                    color: Color(0xFF1A1A1A),
                                    fontSize: 22.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleLarge
                                        .fontStyle,
                                  ),
                            ),
                            SizedBox(height: 2.0),
                            Text(
                              'Bedrooms',
                              style: FlutterFlowTheme.of(context)
                                  .labelSmall
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .fontStyle,
                                    ),
                                    color: Color(0xFF8B8680),
                                    fontSize: 11.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .labelSmall
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .labelSmall
                                        .fontStyle,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.sizeOf(context).width * 0.3,
                      decoration: BoxDecoration(
                        color: Color(0xFFF7F4F0),
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bathtub_outlined,
                              color: Color(0xFFB8956A),
                              size: 24.0,
                            ),
                            SizedBox(height: 4.0),
                            Text(
                              '${projectData['bathrooms'] ?? 0}',
                              style: FlutterFlowTheme.of(context)
                                  .titleLarge
                                  .override(
                                    font: GoogleFonts.interTight(
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleLarge
                                          .fontStyle,
                                    ),
                                    color: Color(0xFF1A1A1A),
                                    fontSize: 22.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleLarge
                                        .fontStyle,
                                  ),
                            ),
                            SizedBox(height: 2.0),
                            Text(
                              'Bathrooms',
                              style: FlutterFlowTheme.of(context)
                                  .labelSmall
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .fontStyle,
                                    ),
                                    color: Color(0xFF8B8680),
                                    fontSize: 11.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .labelSmall
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .labelSmall
                                        .fontStyle,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.sizeOf(context).width * 0.3,
                      decoration: BoxDecoration(
                        color: Color(0xFFF7F4F0),
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.electrical_services_outlined,
                              color: Color(0xFFB8956A),
                              size: 24.0,
                            ),
                            SizedBox(height: 4.0),
                            Text(
                              '${projectData['fixtures'] ?? 0}',
                              style: FlutterFlowTheme.of(context)
                                  .titleLarge
                                  .override(
                                    font: GoogleFonts.interTight(
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleLarge
                                          .fontStyle,
                                    ),
                                    color: Color(0xFF1A1A1A),
                                    fontSize: 22.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleLarge
                                        .fontStyle,
                                  ),
                            ),
                            SizedBox(height: 2.0),
                            Text(
                              'Fixtures',
                              style: FlutterFlowTheme.of(context)
                                  .labelSmall
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .fontStyle,
                                    ),
                                    color: Color(0xFF8B8680),
                                    fontSize: 11.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .labelSmall
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .labelSmall
                                        .fontStyle,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 20.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 8.0,
                        color: Color(0x0A000000),
                        offset: Offset(
                          0.0,
                          2.0,
                        ),
                      )
                    ],
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                      color: Color(0xFFEDE8E2),
                      width: 1.0,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Client Approval Status',
                              style: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    font: GoogleFonts.interTight(
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                    color: Color(0xFF1A1A1A),
                                    fontSize: 14.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontStyle,
                                  ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFFFF3CD),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    10.0, 4.0, 10.0, 4.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.schedule_rounded,
                                      color: Color(0xFFD4A017),
                                      size: 12.0,
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          4.0, 0.0, 4.0, 0.0),
                                      child: Text(
                                        'In Progress',
                                        style: FlutterFlowTheme.of(context)
                                            .labelSmall
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .fontStyle,
                                              ),
                                              color: Color(0xFFD4A017),
                                              fontSize: 11.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w600,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmall
                                                      .fontStyle,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('projects')
                              .doc(projectId)
                              .collection('items')
                              .snapshots(),
                          builder: (context, approvalSnap) {
                            int approved = 0;
                            int pending = 0;
                            int revisions = 0;
                            if (approvalSnap.hasData) {
                              for (final doc in approvalSnap.data!.docs) {
                                final d = doc.data() as Map<String, dynamic>;
                                final s = (d['status'] ?? '').toString().toLowerCase();
                                if (s == 'approved' || s == 'ordered' || s == 'installed') {
                                  approved++;
                                } else if (s == 'awaitingclientapproval') {
                                  pending++;
                                } else if (s == 'needsbuilderinput') {
                                  revisions++;
                                }
                              }
                            }
                            return Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: MediaQuery.sizeOf(context).width * 0.25,
                                  height: 70.0,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF0FAF0),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('$approved', style: FlutterFlowTheme.of(context).titleLarge.override(font: GoogleFonts.interTight(fontWeight: FontWeight.bold), color: Color(0xFF27AE60), fontSize: 22.0, letterSpacing: 0.0, fontWeight: FontWeight.bold)),
                                        Text('Approved', style: FlutterFlowTheme.of(context).labelSmall.override(font: GoogleFonts.inter(fontWeight: FontWeight.w600), color: Color(0xFF27AE60), fontSize: 10.0, letterSpacing: 0.0, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.sizeOf(context).width * 0.25,
                                  height: 70.0,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFFFF8F0),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('$pending', style: FlutterFlowTheme.of(context).titleLarge.override(font: GoogleFonts.interTight(fontWeight: FontWeight.bold), color: Color(0xFFE67E22), fontSize: 22.0, letterSpacing: 0.0, fontWeight: FontWeight.bold)),
                                        Text('Pending', style: FlutterFlowTheme.of(context).labelSmall.override(font: GoogleFonts.inter(fontWeight: FontWeight.w600), color: Color(0xFFE67E22), fontSize: 10.0, letterSpacing: 0.0, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.sizeOf(context).width * 0.25,
                                  height: 70.0,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFFFF0F0),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('$revisions', style: FlutterFlowTheme.of(context).titleLarge.override(font: GoogleFonts.interTight(fontWeight: FontWeight.bold), color: Color(0xFFC0392B), fontSize: 22.0, letterSpacing: 0.0, fontWeight: FontWeight.bold)),
                                        Text('Revisions', style: FlutterFlowTheme.of(context).labelSmall.override(font: GoogleFonts.inter(fontWeight: FontWeight.w600), color: Color(0xFFC0392B), fontSize: 10.0, letterSpacing: 0.0, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                ),
                              ].divide(SizedBox(width: 10.0)),
                            );
                          },
                        ),
                        Divider(
                          thickness: 1.0,
                          color: Color(0xFFF0EAE2),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PENDING DECISIONS',
                              style: FlutterFlowTheme.of(context)
                                  .labelSmall
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .fontStyle,
                                    ),
                                    color: Color(0xFF8B8680),
                                    fontSize: 10.0,
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .labelSmall
                                        .fontStyle,
                                  ),
                            ),
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('projects')
                                  .doc(projectId)
                                  .collection('items')
                                  .where('status', isEqualTo: 'awaitingClientApproval')
                                  .limit(5)
                                  .snapshots(),
                              builder: (context, itemsSnapshot) {
                                if (!itemsSnapshot.hasData || itemsSnapshot.data!.docs.isEmpty) {
                                  return Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8.0),
                                    child: Text(
                                      'No pending decisions',
                                      style: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .override(
                                            font: GoogleFonts.inter(),
                                            color: Color(0xFF8B8680),
                                            fontSize: 12.0,
                                          ),
                                    ),
                                  );
                                }

                                return Column(
                                  children: itemsSnapshot.data!.docs.map((doc) {
                                    final itemData = doc.data() as Map<String, dynamic>;
                                    final itemName = itemData['name'] as String? ?? 'Unnamed Item';
                                    final dueDate = (itemData['dueDate'] as Timestamp?)?.toDate();
                                    
                                    String dueDateText = 'No due date';
                                    Color dueDateColor = Color(0xFF8B8680);
                                    
                                    if (dueDate != null) {
                                      final now = DateTime.now();
                                      final difference = dueDate.difference(now).inDays;
                                      
                                      if (difference < 0) {
                                        dueDateText = 'Overdue';
                                        dueDateColor = Color(0xFFC0392B);
                                      } else if (difference == 0) {
                                        dueDateText = 'Due Today';
                                        dueDateColor = Color(0xFFC0392B);
                                      } else if (difference == 1) {
                                        dueDateText = 'Due Tomorrow';
                                        dueDateColor = Color(0xFFE67E22);
                                      } else if (difference <= 7) {
                                        final weekday = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][dueDate.weekday - 1];
                                        dueDateText = 'Due $weekday';
                                        dueDateColor = Color(0xFF8B8680);
                                      } else {
                                        dueDateText = DateFormat('MMM dd').format(dueDate);
                                        dueDateColor = Color(0xFF8B8680);
                                      }
                                    }

                                    return Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Container(
                                                width: 8.0,
                                                height: 8.0,
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFE67E22),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              SizedBox(width: 8.0),
                                              Expanded(
                                                child: Text(
                                                  itemName,
                                                  style: FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        font: GoogleFonts.inter(),
                                                        color: Color(0xFF1A1A1A),
                                                        fontSize: 13.0,
                                                        letterSpacing: 0.0,
                                                      ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          dueDateText,
                                          style: FlutterFlowTheme.of(context)
                                              .labelSmall
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                color: dueDateColor,
                                                fontSize: 11.0,
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                      ],
                                    );
                                  }).toList().fold<List<Widget>>(
                                    [],
                                    (list, widget) {
                                      if (list.isNotEmpty) {
                                        list.add(SizedBox(height: 4.0));
                                      }
                                      list.add(widget);
                                      return list;
                                    },
                                  ),
                                );
                              },
                            ),
                          ].divide(SizedBox(height: 14.0)),
                        ),
                      ].divide(SizedBox(height: 14.0)),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 20.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 8.0,
                        color: Color(0x0A000000),
                        offset: Offset(
                          0.0,
                          2.0,
                        ),
                      )
                    ],
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                      color: Color(0xFFEDE8E2),
                      width: 1.0,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Due This Week',
                              style: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    font: GoogleFonts.interTight(
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                    color: Color(0xFF1A1A1A),
                                    fontSize: 14.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontStyle,
                                  ),
                            ),
                            Text(
                              'View All',
                              style: FlutterFlowTheme.of(context)
                                  .labelSmall
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .fontStyle,
                                    ),
                                    color: Color(0xFFB8956A),
                                    fontSize: 12.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .labelSmall
                                        .fontStyle,
                                  ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              14.0, 0.0, 14.0, 0.0),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Color(0xFFFFF8F3),
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                color: Color(0xFFF0D9C4),
                                width: 1.0,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 36.0,
                                          height: 36.0,
                                          decoration: BoxDecoration(
                                            color: Color(0xFFB8956A),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                        ),
                                      ].divide(SizedBox(width: 12.0)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ].divide(SizedBox(height: 12.0)),
                    ),
                  ),
                ),
              ),
              // Export Materials Button
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
                child: InkWell(
                  onTap: _exportMaterialsList,
                  child: Container(
                    width: double.infinity,
                    height: 52.0,
                    decoration: BoxDecoration(
                      color: Color(0xFFF5F0EB),
                      borderRadius: BorderRadius.circular(14.0),
                      border: Border.all(
                        color: Color(0xFFD4C4B0),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.download_rounded,
                          color: Color(0xFFB8956A),
                          size: 20.0,
                        ),
                        SizedBox(width: 8.0),
                        Text(
                          'Export Materials List (CSV)',
                          style: FlutterFlowTheme.of(context).labelMedium.override(
                                font: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                ),
                                color: Color(0xFFB8956A),
                                fontSize: 13.0,
                                letterSpacing: 0.3,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ]
                .addToStart(SizedBox(height: 16.0))
                .addToEnd(SizedBox(height: 32.0)),
          ),
        ),
      ),
    );
      },
    );
  }
}
