import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/auth/firebase_auth/auth_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'builder_projects_model.dart';
export 'builder_projects_model.dart';

/// # Builder Projects
///
/// Build project list page for Builder role showing all projects in their
/// organization.
///
/// Display all projects filtered by builderOrgId. Each project card shows
/// project name, client name, and due count. Use **status_badge** to display
/// project status. Tap opens Builder Project Detail. Add "New Project" button
/// for creating projects. Query projects by builderOrgId. Design with card
/// list on white (#FFFFFF), soft taupe (#D4C4B0) borders, brass accent
/// (#B8956A) for New Project button and interactive elements, warm neutral
/// gray (#8B8680) for secondary text. Apply rounded cards with professional
/// spacing for clear visual hierarchy.
class BuilderProjectsWidget extends StatefulWidget {
  const BuilderProjectsWidget({super.key});

  static String routeName = 'BuilderProjects';
  static String routePath = '/builderProjects';

  @override
  State<BuilderProjectsWidget> createState() => _BuilderProjectsWidgetState();
}

class _BuilderProjectsWidgetState extends State<BuilderProjectsWidget> {
  late BuilderProjectsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  
  String? _builderOrgId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BuilderProjectsModel());
    _loadBuilderOrg();
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  Future<void> _loadBuilderOrg() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUid)
          .get();
      
      if (userDoc.exists) {
        setState(() {
          _builderOrgId = userDoc.data()?['builderOrgId'] as String?;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading builder org: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
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
          title: Text(
            'Projects',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(
                    fontWeight: FontWeight.bold,
                    fontStyle:
                        FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                  ),
                  color: Color(0xFF2C2C2C),
                  fontSize: 22.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.bold,
                  fontStyle:
                      FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                ),
          ),
          actions: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  FFButtonWidget(
                    onPressed: () {
                      context.pushNamed('BuilderProjectSetup');
                    },
                    text: 'New Project',
                    options: FFButtonOptions(
                      height: 38.0,
                      padding:
                          EdgeInsetsDirectional.fromSTEB(14.0, 0.0, 14.0, 0.0),
                      iconPadding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      color: Color(0xFFB8956A),
                      textStyle:
                          FlutterFlowTheme.of(context).titleSmall.override(
                                font: GoogleFonts.interTight(
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .fontStyle,
                                ),
                                color: Colors.white,
                                fontSize: 13.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w600,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .fontStyle,
                              ),
                      elevation: 0.0,
                      borderSide: BorderSide(
                        color: Colors.transparent,
                        width: 0.0,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ],
              ),
            ),
          ],
          centerTitle: false,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: double.infinity,
                height: 1.0,
                decoration: BoxDecoration(
                  color: Color(0xFFD4C4B0),
                ),
              ),
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFB8956A),
                        ),
                      )
                    : _builderOrgId == null || _builderOrgId!.isEmpty
                        ? Center(
                            child: Text(
                              'No organization assigned',
                              style: FlutterFlowTheme.of(context).bodyMedium,
                            ),
                          )
                        : StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('projects')
                                .where('builderOrgId', isEqualTo: _builderOrgId)
                                .orderBy('createdAt', descending: true)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Center(
                                  child: Text('Error: ${snapshot.error}'),
                                );
                              }

                              if (!snapshot.hasData) {
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFFB8956A),
                                  ),
                                );
                              }

                              final projects = snapshot.data!.docs;

                              if (projects.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.folder_open_outlined,
                                        size: 64.0,
                                        color: Color(0xFFD4C4B0),
                                      ),
                                      SizedBox(height: 16.0),
                                      Text(
                                        'No projects yet',
                                        style: FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .override(
                                              font: GoogleFonts.interTight(),
                                              color: Color(0xFF8B8680),
                                            ),
                                      ),
                                      SizedBox(height: 8.0),
                                      Text(
                                        'Create your first project to get started',
                                        style: FlutterFlowTheme.of(context)
                                            .bodySmall
                                            .override(
                                              font: GoogleFonts.inter(),
                                              color: Color(0xFF8B8680),
                                            ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    16.0, 16.0, 16.0, 24.0),
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  itemCount: projects.length,
                                  itemBuilder: (context, index) {
                                    final projectDoc = projects[index];
                                    final projectData =
                                        projectDoc.data() as Map<String, dynamic>;
                                    final projectId = projectDoc.id;
                                    final projectName =
                                        projectData['name'] as String? ?? 'Untitled Project';
                                    final clientId =
                                        projectData['clientId'] as String? ?? '';
                                    final status =
                                        projectData['status'] as String? ?? 'unknown';

                                    // Get status color and label
                                    Color statusColor;
                                    Color statusBgColor;
                                    String statusLabel;
                                    switch (status) {
                                      case 'active':
                                        statusColor = Colors.green;
                                        statusBgColor = Color(0xFFF0F9F0);
                                        statusLabel = 'Active';
                                        break;
                                      case 'completed':
                                        statusColor = Color(0xFF2196F3);
                                        statusBgColor = Color(0xFFE3F2FD);
                                        statusLabel = 'Completed';
                                        break;
                                      case 'archived':
                                        statusColor = Color(0xFF8B8680);
                                        statusBgColor = Color(0xFFF5F5F5);
                                        statusLabel = 'Archived';
                                        break;
                                      default:
                                        statusColor = Color(0xFFB8956A);
                                        statusBgColor = Color(0xFFF5EDE3);
                                        statusLabel = 'Setup';
                                    }

                                    return Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 0.0, 0.0, 12.0),
                                      child: InkWell(
                                        onTap: () {
                                          context.pushNamed(
                                            'BuilderProjectDetails',
                                            queryParameters: {
                                              'projectId': serializeParam(
                                                projectId,
                                                ParamType.String,
                                              ),
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
                                                color: Color(0x0D000000),
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
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisSize: MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize.max,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            projectName,
                                                            maxLines: 1,
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .titleMedium
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .interTight(
                                                                    fontWeight:
                                                                        FontWeight.bold,
                                                                  ),
                                                                  color: Color(0xFF2C2C2C),
                                                                  fontSize: 16.0,
                                                                ),
                                                            overflow:
                                                                TextOverflow.ellipsis,
                                                          ),
                                                          if (clientId.isNotEmpty)
                                                            Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(0.0,
                                                                          4.0, 0.0, 0.0),
                                                              child: FutureBuilder<
                                                                  DocumentSnapshot>(
                                                                future: FirebaseFirestore
                                                                    .instance
                                                                    .collection('users')
                                                                    .doc(clientId)
                                                                    .get(),
                                                                builder: (context,
                                                                    clientSnapshot) {
                                                                  String clientName = 'Loading...';
                                                                  if (clientSnapshot.hasData && clientSnapshot.data != null && clientSnapshot.data!.exists) {
                                                                    final cData = clientSnapshot.data!.data() as Map<String, dynamic>?;
                                                                    clientName = cData?['display_name'] as String? ?? 'Unknown Client';
                                                                  }
                                                                  return Text(
                                                                    'Client: $clientName',
                                                                    style: FlutterFlowTheme
                                                                            .of(context)
                                                                        .bodySmall
                                                                        .override(
                                                                          font: GoogleFonts
                                                                              .inter(),
                                                                          color: Color(
                                                                              0xFF8B8680),
                                                                          fontSize: 13.0,
                                                                        ),
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsetsDirectional
                                                          .fromSTEB(
                                                              10.0, 0.0, 10.0, 0.0),
                                                      child: Container(
                                                        height: 26.0,
                                                        decoration: BoxDecoration(
                                                          color: statusBgColor,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  20.0),
                                                        ),
                                                        child: Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  0.0, 0.0),
                                                          child: Padding(
                                                            padding: EdgeInsets.all(8.0),
                                                            child: Text(
                                                              statusLabel,
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmall
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .inter(
                                                                      fontWeight:
                                                                          FontWeight.w600,
                                                                    ),
                                                                    color: statusColor,
                                                                    fontSize: 11.0,
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(0.0, 12.0, 0.0, 0.0),
                                                  child: Divider(
                                                    height: 16.0,
                                                    thickness: 1.0,
                                                    color: Color(0xFFD4C4B0),
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisSize: MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Row(
                                                      mainAxisSize: MainAxisSize.max,
                                                      children: [
                                                        Container(
                                                          width: 28.0,
                                                          height: 28.0,
                                                          decoration: BoxDecoration(
                                                            color: Color(0xFFF5EDE3),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    8.0),
                                                          ),
                                                          child: Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    0.0, 0.0),
                                                            child: Icon(
                                                              Icons
                                                                  .assignment_outlined,
                                                              color: Color(0xFFB8956A),
                                                              size: 14.0,
                                                            ),
                                                          ),
                                                        ),
                                                        FutureBuilder<QuerySnapshot>(
                                                          future: FirebaseFirestore
                                                              .instance
                                                              .collection('projects')
                                                              .doc(projectId)
                                                              .collection('items')
                                                              .where('status',
                                                                  isEqualTo:
                                                                      'awaitingClientApproval')
                                                              .get(),
                                                          builder: (context,
                                                              itemsSnapshot) {
                                                            final dueCount =
                                                                itemsSnapshot.hasData
                                                                    ? itemsSnapshot
                                                                        .data!.docs.length
                                                                    : 0;
                                                            return Column(
                                                              mainAxisSize:
                                                                  MainAxisSize.max,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  'Pending',
                                                                  style: FlutterFlowTheme
                                                                          .of(context)
                                                                      .labelSmall
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .inter(),
                                                                        color: Color(
                                                                            0xFF8B8680),
                                                                        fontSize: 10.0,
                                                                      ),
                                                                ),
                                                                Text(
                                                                  '$dueCount items',
                                                                  style: FlutterFlowTheme
                                                                          .of(context)
                                                                      .labelMedium
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .inter(
                                                                          fontWeight:
                                                                              FontWeight
                                                                                  .w600,
                                                                        ),
                                                                        color: Color(
                                                                            0xFF2C2C2C),
                                                                        fontSize: 12.0,
                                                                      ),
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        ),
                                                      ].divide(SizedBox(width: 6.0)),
                                                    ),
                                                    Row(
                                                      mainAxisSize: MainAxisSize.max,
                                                      children: [
                                                        Text(
                                                          'View Details',
                                                          style: FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .override(
                                                                font:
                                                                    GoogleFonts.inter(
                                                                  fontWeight:
                                                                      FontWeight.w600,
                                                                ),
                                                                color:
                                                                    Color(0xFFB8956A),
                                                                fontSize: 12.0,
                                                              ),
                                                        ),
                                                        Icon(
                                                          Icons
                                                              .arrow_forward_ios_rounded,
                                                          color: Color(0xFFB8956A),
                                                          size: 14.0,
                                                        ),
                                                      ].divide(SizedBox(width: 4.0)),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
