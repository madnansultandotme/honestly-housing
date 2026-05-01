import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/auth/firebase_auth/auth_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'clients_projects_model.dart';
export 'clients_projects_model.dart';

/// # Client Projects
///
/// Build project list page for Client role showing only their assigned
/// projects.
///
/// Display projects filtered by user.projectIds (typically 1 project). Each
/// project card shows project name, builder name, and progress summary. Use
/// **status_badge** to display overall project status. Use **progress_bar**
/// to show selection completion. Tap opens Client Project Detail. Query
/// projects by user.projectIds. Design with card list on white (#FFFFFF),
/// soft taupe (#D4C4B0) borders, brass accent (#B8956A) for interactive
/// elements, warm neutral gray (#8B8680) for secondary text. Apply rounded
/// cards with professional spacing.
class ClientsProjectsWidget extends StatefulWidget {
  const ClientsProjectsWidget({super.key});

  static String routeName = 'ClientsProjects';
  static String routePath = '/clientsProjects';

  @override
  State<ClientsProjectsWidget> createState() => _ClientsProjectsWidgetState();
}

class _ClientsProjectsWidgetState extends State<ClientsProjectsWidget> {
  late ClientsProjectsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  
  List<String> _projectIds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ClientsProjectsModel());
    _loadUserProjects();
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  Future<void> _loadUserProjects() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUid)
          .get();
      
      if (userDoc.exists) {
        final projectIds = (userDoc.data()?['projectIds'] as List?)?.cast<String>() ?? [];
        setState(() {
          _projectIds = projectIds;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading user projects: $e');
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
            'My Projects',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(
                    fontWeight: FontWeight.bold,
                    fontStyle:
                        FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                  ),
                  color: Color(0xFF2C2C2C),
                  fontSize: 24.0,
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
                  Container(
                    width: 38.0,
                    height: 38.0,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1656442908424-71a6e5052fb9?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3Nzc2NDQyMDB8&ixlib=rb-4.1.0&q=80&w=1080',
                      fit: BoxFit.cover,
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
              Divider(
                height: 1.0,
                thickness: 1.0,
                color: Color(0xFFD4C4B0),
              ),
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFB8956A),
                        ),
                      )
                    : _projectIds.isEmpty
                        ? Center(
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
                                  'No projects assigned',
                                  style: FlutterFlowTheme.of(context).titleMedium.override(
                                        font: GoogleFonts.interTight(),
                                        color: Color(0xFF8B8680),
                                      ),
                                ),
                              ],
                            ),
                          )
                        : StreamBuilder<List<DocumentSnapshot>>(
                            stream: Stream.fromFutures(
                              _projectIds.map((projectId) =>
                                FirebaseFirestore.instance
                                    .collection('projects')
                                    .doc(projectId)
                                    .get()
                              ).toList(),
                            ),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFFB8956A),
                                  ),
                                );
                              }

                              final projects = snapshot.data!.where((doc) => doc.exists).toList();

                              return Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                child: ListView.builder(
                                  itemCount: projects.length,
                                  itemBuilder: (context, index) {
                                    final projectDoc = projects[index];
                                    final projectData = projectDoc.data() as Map<String, dynamic>;
                                    final projectId = projectDoc.id;
                                    final projectName = projectData['name'] as String? ?? 'Untitled Project';
                                    final builderOrgId = projectData['builderOrgId'] as String? ?? '';
                                    final status = projectData['status'] as String? ?? 'unknown';
                                    final progress = projectData['progress'] as Map<String, dynamic>?;
                                    final totalItems = progress?['totalItems'] as int? ?? 0;
                                    final completedItems = progress?['completedItems'] as int? ?? 0;
                                    final pendingItems = progress?['pendingItems'] as int? ?? 0;
                                    final completionPercent = totalItems > 0 ? (completedItems / totalItems) : 0.0;

                                    return Padding(
                                      padding: EdgeInsets.all(20.0),
                                      child: InkWell(
                                        onTap: () {
                                          context.pushNamed(
                                            'ClientProjectDetai',
                                            queryParameters: {
                                              'projectId': serializeParam(projectId, ParamType.String),
                                            },
                                          );
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                blurRadius: 12.0,
                                                color: Color(0x1A000000),
                                                offset: Offset(0.0, 4.0),
                                              )
                                            ],
                                            borderRadius: BorderRadius.circular(16.0),
                                            border: Border.all(
                                              color: Color(0xFFD4C4B0),
                                              width: 1.5,
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
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize.max,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            projectName,
                                                            style: FlutterFlowTheme.of(context)
                                                                .titleLarge
                                                                .override(
                                                                  font: GoogleFonts.interTight(
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                                  color: Color(0xFF2C2C2C),
                                                                  fontSize: 18.0,
                                                                ),
                                                          ),
                                                          if (builderOrgId.isNotEmpty)
                                                            FutureBuilder<DocumentSnapshot>(
                                                              future: FirebaseFirestore.instance
                                                                  .collection('builderOrgs')
                                                                  .doc(builderOrgId)
                                                                  .get(),
                                                              builder: (context, orgSnapshot) {
                                                                final builderName = orgSnapshot.hasData
                                                                    ? (orgSnapshot.data()?.data() as Map<String, dynamic>?)?['name'] as String? ?? 'Unknown Builder'
                                                                    : 'Loading...';
                                                                return Text(
                                                                  'Builder: $builderName',
                                                                  style: FlutterFlowTheme.of(context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        font: GoogleFonts.inter(),
                                                                        color: Color(0xFF8B8680),
                                                                        fontSize: 13.0,
                                                                      ),
                                                                );
                                                              },
                                                            ),
                                                        ].divide(SizedBox(height: 4.0)),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsetsDirectional.fromSTEB(10.0, 6.0, 10.0, 6.0),
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          color: status == 'active' ? Color(0xFFF0F7EE) : Color(0xFFF5EDE3),
                                                          borderRadius: BorderRadius.circular(20.0),
                                                        ),
                                                        child: Padding(
                                                          padding: EdgeInsets.all(8.0),
                                                          child: Text(
                                                            status == 'active' ? 'In Progress' : status == 'completed' ? 'Completed' : 'Setup',
                                                            style: FlutterFlowTheme.of(context)
                                                                .labelSmall
                                                                .override(
                                                                  font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                                                  color: status == 'active' ? Colors.green : Color(0xFFB8956A),
                                                                  fontSize: 11.0,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Divider(
                                                  height: 1.0,
                                                  thickness: 1.0,
                                                  color: Color(0xFFD4C4B0),
                                                ),
                                                Column(
                                                  mainAxisSize: MainAxisSize.max,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisSize: MainAxisSize.max,
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text(
                                                          'Selection Completion',
                                                          style: FlutterFlowTheme.of(context)
                                                              .bodySmall
                                                              .override(
                                                                font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                                                                color: Color(0xFF8B8680),
                                                                fontSize: 13.0,
                                                              ),
                                                        ),
                                                        Text(
                                                          '${(completionPercent * 100).toStringAsFixed(0)}%',
                                                          style: FlutterFlowTheme.of(context)
                                                              .bodySmall
                                                              .override(
                                                                font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                                                color: Color(0xFFB8956A),
                                                                fontSize: 13.0,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                    LinearPercentIndicator(
                                                      percent: completionPercent,
                                                      width: MediaQuery.sizeOf(context).width * 0.85,
                                                      lineHeight: 8.0,
                                                      animation: true,
                                                      animateFromLastPercent: true,
                                                      progressColor: Color(0xFFB8956A),
                                                      backgroundColor: Color(0xFFD4C4B0),
                                                      barRadius: Radius.circular(100.0),
                                                      padding: EdgeInsets.zero,
                                                    ),
                                                  ].divide(SizedBox(height: 8.0)),
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
                                                          'PENDING SELECTIONS',
                                                          style: FlutterFlowTheme.of(context)
                                                              .labelSmall
                                                              .override(
                                                                font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                                                color: Color(0xFF8B8680),
                                                                fontSize: 10.0,
                                                                letterSpacing: 0.8,
                                                              ),
                                                        ),
                                                        Text(
                                                          '$pendingItems items awaiting',
                                                          style: FlutterFlowTheme.of(context)
                                                              .bodyMedium
                                                              .override(
                                                                font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                                                color: Color(0xFF2C2C2C),
                                                                fontSize: 14.0,
                                                              ),
                                                        ),
                                                      ].divide(SizedBox(height: 2.0)),
                                                    ),
                                                  ],
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    context.pushNamed(
                                                      'ClientProjectDetai',
                                                      queryParameters: {
                                                        'projectId': serializeParam(projectId, ParamType.String),
                                                      },
                                                    );
                                                  },
                                                  child: Container(
                                                    width: double.infinity,
                                                    height: 44.0,
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFFB8956A),
                                                      borderRadius: BorderRadius.circular(12.0),
                                                    ),
                                                    child: Padding(
                                                      padding: EdgeInsets.all(12.0),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.max,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Text(
                                                            'View Project Details',
                                                            style: FlutterFlowTheme.of(context)
                                                                .titleSmall
                                                                .override(
                                                                  font: GoogleFonts.interTight(fontWeight: FontWeight.w600),
                                                                  color: Colors.white,
                                                                  fontSize: 14.0,
                                                                ),
                                                          ),
                                                          Icon(
                                                            Icons.arrow_forward_rounded,
                                                            color: Colors.white,
                                                            size: 16.0,
                                                          ),
                                                        ].divide(SizedBox(width: 8.0)),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ].divide(SizedBox(height: 16.0)),
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
                                            style: FlutterFlowTheme.of(context)
                                                .titleLarge
                                                .override(
                                                  font: GoogleFonts.interTight(
                                                    fontWeight: FontWeight.bold,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .titleLarge
                                                            .fontStyle,
                                                  ),
                                                  color: Color(0xFF2C2C2C),
                                                  fontSize: 18.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .titleLarge
                                                          .fontStyle,
                                                ),
                                          ),
                                          Text(
                                            'Builder: Summit Build Group',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  color: Color(0xFF8B8680),
                                                  fontSize: 13.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.normal,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                          ),
                                        ].divide(SizedBox(height: 4.0)),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          10.0, 6.0, 10.0, 6.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFFFF8E1),
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            'Planning',
                                            style: FlutterFlowTheme.of(context)
                                                .labelSmall
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight: FontWeight.bold,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelSmall
                                                            .fontStyle,
                                                  ),
                                                  color: Color(0xFFFF8F00),
                                                  fontSize: 11.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelSmall
                                                          .fontStyle,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(
                                  height: 1.0,
                                  thickness: 1.0,
                                  color: Color(0xFFD4C4B0),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Selection Completion',
                                          style: FlutterFlowTheme.of(context)
                                              .bodySmall
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodySmall
                                                          .fontStyle,
                                                ),
                                                color: Color(0xFF8B8680),
                                                fontSize: 13.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w500,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodySmall
                                                        .fontStyle,
                                              ),
                                        ),
                                        Text(
                                          '22%',
                                          style: FlutterFlowTheme.of(context)
                                              .bodySmall
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodySmall
                                                          .fontStyle,
                                                ),
                                                color: Color(0xFFB8956A),
                                                fontSize: 13.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.bold,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodySmall
                                                        .fontStyle,
                                              ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      width: double.infinity,
                                      height: 8.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xFFD4C4B0),
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                      ),
                                      child: Container(
                                        width:
                                            MediaQuery.sizeOf(context).width *
                                                0.22,
                                        height: 8.0,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFB8956A),
                                          borderRadius:
                                              BorderRadius.circular(100.0),
                                        ),
                                      ),
                                    ),
                                  ].divide(SizedBox(height: 8.0)),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'PENDING SELECTIONS',
                                          style: FlutterFlowTheme.of(context)
                                              .labelSmall
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelSmall
                                                          .fontStyle,
                                                ),
                                                color: Color(0xFF8B8680),
                                                fontSize: 10.0,
                                                letterSpacing: 0.8,
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .fontStyle,
                                              ),
                                        ),
                                        Text(
                                          '11 items awaiting',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                color: Color(0xFF2C2C2C),
                                                fontSize: 14.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                        ),
                                      ].divide(SizedBox(height: 2.0)),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'NEXT MILESTONE',
                                          style: FlutterFlowTheme.of(context)
                                              .labelSmall
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelSmall
                                                          .fontStyle,
                                                ),
                                                color: Color(0xFF8B8680),
                                                fontSize: 10.0,
                                                letterSpacing: 0.8,
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .fontStyle,
                                              ),
                                        ),
                                        Text(
                                          'Design Review — Apr 2',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                color: Color(0xFF2C2C2C),
                                                fontSize: 14.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                        ),
                                      ].divide(SizedBox(height: 2.0)),
                                    ),
                                  ],
                                ),
                                Container(
                                  width: double.infinity,
                                  height: 44.0,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFB8956A),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'View Project Details',
                                          style: FlutterFlowTheme.of(context)
                                              .titleSmall
                                              .override(
                                                font: GoogleFonts.interTight(
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .titleSmall
                                                          .fontStyle,
                                                ),
                                                color: Colors.white,
                                                fontSize: 14.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .fontStyle,
                                              ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Colors.white,
                                          size: 16.0,
                                        ),
                                      ].divide(SizedBox(width: 8.0)),
                                    ),
                                  ),
                                ),
                              ].divide(SizedBox(height: 16.0)),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 12.0,
                                color: Color(0x1A000000),
                                offset: Offset(
                                  0.0,
                                  4.0,
                                ),
                              )
                            ],
                            borderRadius: BorderRadius.circular(16.0),
                            border: Border.all(
                              color: Color(0xFFD4C4B0),
                              width: 1.5,
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Lakeside Deck & Patio',
                                            style: FlutterFlowTheme.of(context)
                                                .titleLarge
                                                .override(
                                                  font: GoogleFonts.interTight(
                                                    fontWeight: FontWeight.bold,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .titleLarge
                                                            .fontStyle,
                                                  ),
                                                  color: Color(0xFF2C2C2C),
                                                  fontSize: 18.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .titleLarge
                                                          .fontStyle,
                                                ),
                                          ),
                                          Text(
                                            'Builder: Pinnacle Outdoor Builds',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  color: Color(0xFF8B8680),
                                                  fontSize: 13.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.normal,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                          ),
                                        ].divide(SizedBox(height: 4.0)),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          10.0, 6.0, 10.0, 6.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFECE8F5),
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            'Completed',
                                            style: FlutterFlowTheme.of(context)
                                                .labelSmall
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight: FontWeight.bold,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelSmall
                                                            .fontStyle,
                                                  ),
                                                  color: Color(0xFF6750A4),
                                                  fontSize: 11.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelSmall
                                                          .fontStyle,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(
                                  height: 1.0,
                                  thickness: 1.0,
                                  color: Color(0xFFD4C4B0),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Selection Completion',
                                          style: FlutterFlowTheme.of(context)
                                              .bodySmall
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodySmall
                                                          .fontStyle,
                                                ),
                                                color: Color(0xFF8B8680),
                                                fontSize: 13.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w500,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodySmall
                                                        .fontStyle,
                                              ),
                                        ),
                                        Text(
                                          '100%',
                                          style: FlutterFlowTheme.of(context)
                                              .bodySmall
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodySmall
                                                          .fontStyle,
                                                ),
                                                color: Color(0xFFB8956A),
                                                fontSize: 13.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.bold,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodySmall
                                                        .fontStyle,
                                              ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      width: double.infinity,
                                      height: 8.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xFFD4C4B0),
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                      ),
                                      child: Container(
                                        width:
                                            MediaQuery.sizeOf(context).width *
                                                1.0,
                                        height: 8.0,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFB8956A),
                                          borderRadius:
                                              BorderRadius.circular(100.0),
                                        ),
                                      ),
                                    ),
                                  ].divide(SizedBox(height: 8.0)),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'PENDING SELECTIONS',
                                          style: FlutterFlowTheme.of(context)
                                              .labelSmall
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelSmall
                                                          .fontStyle,
                                                ),
                                                color: Color(0xFF8B8680),
                                                fontSize: 10.0,
                                                letterSpacing: 0.8,
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .fontStyle,
                                              ),
                                        ),
                                        Text(
                                          'All selections done',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                color: Color(0xFF2C2C2C),
                                                fontSize: 14.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                        ),
                                      ].divide(SizedBox(height: 2.0)),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'COMPLETED ON',
                                          style: FlutterFlowTheme.of(context)
                                              .labelSmall
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelSmall
                                                          .fontStyle,
                                                ),
                                                color: Color(0xFF8B8680),
                                                fontSize: 10.0,
                                                letterSpacing: 0.8,
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .fontStyle,
                                              ),
                                        ),
                                        Text(
                                          'Feb 28, 2025',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                color: Color(0xFF2C2C2C),
                                                fontSize: 14.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                        ),
                                      ].divide(SizedBox(height: 2.0)),
                                    ),
                                  ],
                                ),
                                Container(
                                  width: double.infinity,
                                  height: 44.0,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFB8956A),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'View Project Details',
                                          style: FlutterFlowTheme.of(context)
                                              .titleSmall
                                              .override(
                                                font: GoogleFonts.interTight(
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .titleSmall
                                                          .fontStyle,
                                                ),
                                                color: Colors.white,
                                                fontSize: 14.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .fontStyle,
                                              ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Colors.white,
                                          size: 16.0,
                                        ),
                                      ].divide(SizedBox(width: 8.0)),
                                    ),
                                  ),
                                ),
                              ].divide(SizedBox(height: 16.0)),
                            ),
                          ),
                        ),
                      ),
                    ]
                        .divide(SizedBox(height: 0.0))
                        .addToStart(SizedBox(height: 20.0))
                        .addToEnd(SizedBox(height: 32.0)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
