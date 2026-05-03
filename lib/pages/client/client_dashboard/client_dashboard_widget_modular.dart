import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/user_network_avatar.dart';
import '/auth/firebase_auth/auth_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'client_dashboard_model.dart';
export 'client_dashboard_model.dart';

// Import modular widgets
import 'widgets/project_overview_card.dart';
import 'widgets/pending_decisions_list.dart';
import 'widgets/recent_messages_widget.dart';

/// # Client Dashboard (Modular Version)
///
/// Refactored dashboard with modular widgets for better maintainability.
/// Uses separate widgets for project overview, pending decisions, and messages.
class ClientDashboardWidgetModular extends StatefulWidget {
  const ClientDashboardWidgetModular({super.key});

  static String routeName = 'ClientDashboard';
  static String routePath = '/clientDashboard';

  @override
  State<ClientDashboardWidgetModular> createState() =>
      _ClientDashboardWidgetModularState();
}

class _ClientDashboardWidgetModularState
    extends State<ClientDashboardWidgetModular> {
  late ClientDashboardModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Dashboard data
  String _userName = '';
  String _userPhotoUrl = '';
  String _projectId = '';
  String _projectName = '';
  String _projectStatus = '';
  DateTime? _startDate;
  DateTime? _targetDate;
  String _phase = '';
  double _completionPercent = 0.0;
  int _pendingDecisions = 0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ClientDashboardModel());
    _loadDashboardData();
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Get current user's document
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUid)
          .get();

      if (!userDoc.exists) {
        setState(() {
          _errorMessage = 'User profile not found';
          _isLoading = false;
        });
        return;
      }

      final userData = userDoc.data() as Map<String, dynamic>?;
      _userName = userData?['displayName'] as String? ?? 'Client';
      _userPhotoUrl = userData?['photoUrl'] as String? ?? '';
      final projectIds =
          (userData?['projectIds'] as List?)?.cast<String>() ?? [];

      if (projectIds.isEmpty) {
        setState(() {
          _isLoading = false;
          // Don't set error message, just leave data empty
          // The UI will show a welcome message instead
        });
        return;
      }

      // Get first project (in real app, user would select)
      _projectId = projectIds.first;
      final projectDoc = await FirebaseFirestore.instance
          .collection('projects')
          .doc(_projectId)
          .get();

      if (!projectDoc.exists) {
        setState(() {
          _errorMessage = 'Project not found';
          _isLoading = false;
        });
        return;
      }

      final projectData = projectDoc.data() as Map<String, dynamic>?;
      _projectName = projectData?['name'] as String? ?? 'Untitled Project';
      _projectStatus = projectData?['status'] as String? ?? 'active';
      _startDate = (projectData?['startDate'] as Timestamp?)?.toDate();
      _targetDate =
          (projectData?['targetCompletionDate'] as Timestamp?)?.toDate();

      // Calculate phase based on progress
      final progress = projectData?['progress'] as Map<String, dynamic>?;
      final totalItems = progress?['totalItems'] as int? ?? 0;
      final completedItems = progress?['completedItems'] as int? ?? 0;

      if (totalItems > 0) {
        _completionPercent = completedItems / totalItems;
      }

      // Determine phase
      if (_completionPercent < 0.3) {
        _phase = 'Planning';
      } else if (_completionPercent < 0.7) {
        _phase = 'Selections';
      } else {
        _phase = 'Finishing';
      }

      // Query items for pending decisions count
      final itemsQuery = await FirebaseFirestore.instance
          .collection('projects')
          .doc(_projectId)
          .collection('items')
          .where('status',
              whereIn: ['awaitingClientApproval', 'needsClientInput']).get();

      setState(() {
        _pendingDecisions = itemsQuery.docs.length;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading dashboard data: $e');
      setState(() {
        _errorMessage = 'Failed to load dashboard data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Widget _buildQuickActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 80.0,
          decoration: BoxDecoration(
            color: isPrimary ? Color(0xFFB8956A) : Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: isPrimary ? Color(0xFFB8956A) : Color(0xFFD4C4B0),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isPrimary ? Colors.white : Color(0xFFB8956A),
                size: 28.0,
              ),
              SizedBox(height: 6.0),
              Text(
                label,
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      color: isPrimary ? Colors.white : Color(0xFF2C2C2C),
                      fontSize: 12.0,
                      letterSpacing: 0.0,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
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
                Text(
                  'Dashboard',
                  style: FlutterFlowTheme.of(context).headlineMedium.override(
                        font: GoogleFonts.interTight(
                          fontWeight: FontWeight.bold,
                        ),
                        color: Color(0xFF2C2C2C),
                        fontSize: 22.0,
                        letterSpacing: 0.0,
                      ),
                ),
                InkWell(
                  onTap: () {
                    context.pushNamed('ProfileSettings');
                  },
                  child: Icon(
                    Icons.settings_outlined,
                    color: Color(0xFF2C2C2C),
                    size: 24.0,
                  ),
                ),
              ],
            ),
          ),
          centerTitle: false,
          elevation: 0.0,
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64.0,
                  color: Color(0xFFE05C5C),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Error',
                  style: FlutterFlowTheme.of(context).headlineMedium.override(
                        font: GoogleFonts.interTight(
                          fontWeight: FontWeight.bold,
                        ),
                        color: Color(0xFF2C2C2C),
                        letterSpacing: 0.0,
                      ),
                ),
                SizedBox(height: 8.0),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(),
                        color: Color(0xFF8B8680),
                        letterSpacing: 0.0,
                      ),
                ),
                SizedBox(height: 24.0),
                FFButtonWidget(
                  onPressed: _loadDashboardData,
                  text: 'Retry',
                  options: FFButtonOptions(
                    height: 44.0,
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    color: Color(0xFFB8956A),
                    textStyle:
                        FlutterFlowTheme.of(context).titleSmall.override(
                              font: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                              ),
                              color: Colors.white,
                              letterSpacing: 0.0,
                            ),
                    elevation: 0.0,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Show empty state if no projects
    if (!_isLoading && _projectId.isEmpty) {
      return Scaffold(
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
                      'Welcome back,',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            font: GoogleFonts.inter(),
                            color: Color(0xFF8B8680),
                            fontSize: 13.0,
                            letterSpacing: 0.0,
                          ),
                    ),
                    Text(
                      _userName,
                      style:
                          FlutterFlowTheme.of(context).headlineMedium.override(
                                font: GoogleFonts.interTight(
                                  fontWeight: FontWeight.bold,
                                ),
                                color: Color(0xFF2C2C2C),
                                fontSize: 22.0,
                                letterSpacing: 0.0,
                              ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    context.pushNamed('ProfileSettings');
                  },
                  child: Container(
                    width: 44.0,
                    height: 44.0,
                    decoration: BoxDecoration(
                      color: Color(0xFFD4C4B0),
                      shape: BoxShape.circle,
                    ),
                            child: _userPhotoUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(50.0),
                            child: userNetworkAvatar(
                              imageUrl: _userPhotoUrl,
                              width: 44.0,
                              height: 44.0,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error) => Center(
                                child: Text(
                                  _userName.isNotEmpty
                                      ? _userName[0].toUpperCase()
                                      : 'C',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        color: Colors.white,
                                        fontSize: 18.0,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              _userName.isNotEmpty
                                  ? _userName[0].toUpperCase()
                                  : 'C',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    color: Colors.white,
                                    fontSize: 18.0,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          centerTitle: false,
          elevation: 0.0,
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120.0,
                  height: 120.0,
                  decoration: BoxDecoration(
                    color: Color(0xFFF5EFE8),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.home_work_outlined,
                    size: 60.0,
                    color: Color(0xFFB8956A),
                  ),
                ),
                SizedBox(height: 24.0),
                Text(
                  'No Projects Yet',
                  style: FlutterFlowTheme.of(context).headlineMedium.override(
                        font: GoogleFonts.interTight(
                          fontWeight: FontWeight.bold,
                        ),
                        color: Color(0xFF2C2C2C),
                        fontSize: 24.0,
                        letterSpacing: 0.0,
                      ),
                ),
                SizedBox(height: 12.0),
                Text(
                  'You don\'t have any projects assigned yet.\nYour builder will add you to a project soon.',
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(),
                        color: Color(0xFF8B8680),
                        fontSize: 15.0,
                        letterSpacing: 0.0,
                      ),
                ),
                SizedBox(height: 32.0),
                FFButtonWidget(
                  onPressed: _loadDashboardData,
                  text: 'Refresh',
                  icon: Icon(
                    Icons.refresh,
                    size: 20.0,
                  ),
                  options: FFButtonOptions(
                    height: 48.0,
                    padding: EdgeInsets.symmetric(horizontal: 32.0),
                    color: Color(0xFFB8956A),
                    textStyle:
                        FlutterFlowTheme.of(context).titleSmall.override(
                              font: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                              ),
                              color: Colors.white,
                              fontSize: 15.0,
                              letterSpacing: 0.0,
                            ),
                    elevation: 0.0,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
                      'Welcome back,',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            font: GoogleFonts.inter(),
                            color: Color(0xFF8B8680),
                            fontSize: 13.0,
                            letterSpacing: 0.0,
                          ),
                    ),
                    Text(
                      _isLoading ? 'Loading...' : _userName,
                      style:
                          FlutterFlowTheme.of(context).headlineMedium.override(
                                font: GoogleFonts.interTight(
                                  fontWeight: FontWeight.bold,
                                ),
                                color: Color(0xFF2C2C2C),
                                fontSize: 22.0,
                                letterSpacing: 0.0,
                              ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    context.pushNamed('ProfileSettings');
                  },
                  child: Container(
                    width: 44.0,
                    height: 44.0,
                    decoration: BoxDecoration(
                      color: Color(0xFFD4C4B0),
                      shape: BoxShape.circle,
                    ),
                    child: _userPhotoUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(50.0),
                            child: userNetworkAvatar(
                              imageUrl: _userPhotoUrl,
                              width: 44.0,
                              height: 44.0,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error) => Center(
                                child: Text(
                                  _userName.isNotEmpty
                                      ? _userName[0].toUpperCase()
                                      : 'C',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        color: Colors.white,
                                        fontSize: 18.0,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              _userName.isNotEmpty
                                  ? _userName[0].toUpperCase()
                                  : 'C',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    color: Colors.white,
                                    fontSize: 18.0,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                // Project Overview Card
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 16.0),
                  child: ProjectOverviewCard(
                    projectName: _projectName,
                    projectStatus: _projectStatus,
                    startDate: _startDate,
                    targetDate: _targetDate,
                    phase: _phase,
                    completionPercent: _completionPercent,
                    isLoading: _isLoading,
                  ),
                ),

                // Decisions Needed Section
                if (!_isLoading && _projectId.isNotEmpty)
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 16.0),
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
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Container(
                                      width: 8.0,
                                      height: 8.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xFFE05C5C),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: 8.0),
                                    Text(
                                      'Decisions Needed',
                                      style: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .override(
                                            font: GoogleFonts.interTight(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            color: Color(0xFF2C2C2C),
                                            fontSize: 16.0,
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                  ],
                                ),
                                Container(
                                  height: 30.0,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFE05C5C),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12.0, vertical: 6.0),
                                    child: Text(
                                      '$_pendingDecisions Due',
                                      style: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            color: Colors.white,
                                            fontSize: 11.0,
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PendingDecisionsList(projectId: _projectId),
                        ],
                      ),
                    ),
                  ),

                // Quick Actions
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      _buildQuickActionButton(
                        label: 'Selections',
                        icon: Icons.grid_view_rounded,
                        isPrimary: true,
                        onTap: () {
                          context.pushNamed(
                            'ClientSelectionsHome',
                            queryParameters: {
                              'projectId': _projectId,
                            }.withoutNulls,
                          );
                        },
                      ),
                      SizedBox(width: 12.0),
                      _buildQuickActionButton(
                        label: 'Photos',
                        icon: Icons.photo_library_outlined,
                        onTap: () {
                          context.pushNamed(
                            'Photos',
                            queryParameters: {
                              'projectId': _projectId,
                            }.withoutNulls,
                          );
                        },
                      ),
                      SizedBox(width: 12.0),
                      _buildQuickActionButton(
                        label: 'Messages',
                        icon: Icons.message_outlined,
                        onTap: () {
                          context.pushNamed(
                            'Messages',
                            queryParameters: {
                              'projectId': _projectId,
                            }.withoutNulls,
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Recent Messages Section
                if (!_isLoading && _projectId.isNotEmpty)
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 20.0),
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
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Recent Messages',
                                  style: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .override(
                                        font: GoogleFonts.interTight(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        color: Color(0xFF2C2C2C),
                                        fontSize: 16.0,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                                InkWell(
                                  onTap: () {
                                    context.pushNamed(
                                      'Messages',
                                      queryParameters: {
                                        'projectId': _projectId,
                                      }.withoutNulls,
                                    );
                                  },
                                  child: Text(
                                    'View All',
                                    style: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                          ),
                                          color: Color(0xFFB8956A),
                                          fontSize: 13.0,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          RecentMessagesWidget(projectId: _projectId),
                        ],
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
