import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/auth/firebase_auth/auth_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';
import 'client_selections_home_model.dart';
export 'client_selections_home_model.dart';

/// # Client Selections Home
///
/// Build selections overview for Client role organized by status.
///
/// Use **progress_bar** at top for completed/total. Create sections: "Due
/// This Week" using **due_this_week_list**, "Awaiting Approval", "Approved",
/// "Installed" - each using **status_badge**. Query items by status, sorted
/// by due date. Tap navigates to Client Selection Item Detail. Design on
/// white (#FFFFFF) with stacked lists, soft taupe (#D4C4B0) dividers/cards,
/// brass accent (#B8956A) progress fill, warm neutral gray (#8B8680)
/// secondary text. Apply rounded corners and premium spacing.
class ClientSelectionsHomeWidget extends StatefulWidget {
  const ClientSelectionsHomeWidget({
    super.key,
    this.projectId,
  });

  static String routeName = 'ClientSelectionsHome';
  static String routePath = '/clientSelectionsHome';

  final String? projectId;

  @override
  State<ClientSelectionsHomeWidget> createState() =>
      _ClientSelectionsHomeWidgetState();
}

class _ClientSelectionsHomeWidgetState
    extends State<ClientSelectionsHomeWidget> {
  late ClientSelectionsHomeModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  
  String? _projectId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ClientSelectionsHomeModel());
    _loadProjectId();
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  Future<void> _loadProjectId() async {
    try {
      if (widget.projectId != null && widget.projectId!.isNotEmpty) {
        setState(() {
          _projectId = widget.projectId;
          _isLoading = false;
        });
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUid)
          .get();
      
      if (userDoc.exists) {
        final projectIds = (userDoc.data()?['projectIds'] as List?)?.cast<String>() ?? [];
        setState(() {
          _projectId = projectIds.isNotEmpty ? projectIds.first : null;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading project: $e');
      setState(() => _isLoading = false);
    }
  }

  String _normalizeStatus(String? status) {
    return (status ?? 'notStarted').toLowerCase().replaceAll(' ', '');
  }

  bool _isAwaitingApproval(String? status) {
    final normalized = _normalizeStatus(status);
    return normalized == 'awaitingclientapproval' ||
        normalized == 'needsclientinput' ||
        normalized == 'pendingreview';
  }

  bool _isApproved(String? status) => _normalizeStatus(status) == 'approved';

  bool _isInstalled(String? status) => _normalizeStatus(status) == 'installed';

  bool _isDueThisWeek(Timestamp? dueDate) {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final end = now.add(const Duration(days: 7));
    final date = dueDate.toDate();
    return date.isAfter(now.subtract(const Duration(days: 1))) &&
        date.isBefore(end);
  }

  String _formatDueDate(Timestamp? dueDate) {
    if (dueDate == null) return 'No due date';
    final date = dueDate.toDate();
    return DateFormat('MMM d, yyyy').format(date);
  }

  Widget _buildSectionHeader(String title, int count, Color accentColor) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(20.0, 24.0, 20.0, 8.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    width: 4.0,
                    height: 20.0,
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                  Text(
                    title,
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
                ].divide(SizedBox(width: 8.0)),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 4.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      '$count items',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            font: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodySmall
                                  .fontStyle,
                            ),
                            color: accentColor,
                            fontSize: 11.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w600,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodySmall
                                .fontStyle,
                          ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemCard(
    Map<String, dynamic> itemData,
    String itemId,
    Color accentColor,
  ) {
    final category = itemData['categoryName'] ?? 'Category';
    final name = itemData['name'] ?? 'Selection Item';
    final brand = itemData['brand'] ?? '';
    final dueDate = itemData['dueDate'] as Timestamp?;

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 12.0),
      child: InkWell(
        onTap: () {
          context.pushNamed(
            'ClientSelectionItemDetail',
            queryParameters: {
              'itemId': itemId,
              'projectId': _projectId,
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
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
                  child: Text(
                    category.toString().toUpperCase(),
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          font: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontStyle:
                                FlutterFlowTheme.of(context).bodySmall.fontStyle,
                          ),
                          color: Color(0xFFB8956A),
                          fontSize: 10.0,
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.bold,
                          fontStyle: FlutterFlowTheme.of(context)
                              .bodySmall
                              .fontStyle,
                        ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                  child: Text(
                    name,
                    style: FlutterFlowTheme.of(context).titleMedium.override(
                          font: GoogleFonts.interTight(
                            fontWeight: FontWeight.w600,
                            fontStyle: FlutterFlowTheme.of(context)
                                .titleMedium
                                .fontStyle,
                          ),
                          color: Color(0xFF2C2C2C),
                          fontSize: 15.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                          fontStyle:
                              FlutterFlowTheme.of(context).titleMedium.fontStyle,
                        ),
                  ),
                ),
                if (brand.toString().isNotEmpty)
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 2.0, 0.0, 0.0),
                    child: Text(
                      brand,
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            font: GoogleFonts.inter(
                              fontWeight: FlutterFlowTheme.of(context)
                                  .bodySmall
                                  .fontWeight,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodySmall
                                  .fontStyle,
                            ),
                            color: Color(0xFF8B8680),
                            fontSize: 12.0,
                            letterSpacing: 0.0,
                            fontWeight:
                                FlutterFlowTheme.of(context).bodySmall.fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodySmall
                                .fontStyle,
                          ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            color: Color(0xFF8B8680),
                            size: 14.0,
                          ),
                          Text(
                            _formatDueDate(dueDate),
                            style: FlutterFlowTheme.of(context)
                                .bodySmall
                                .override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .fontStyle,
                                  ),
                                  color: Color(0xFF8B8680),
                                  fontSize: 12.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodySmall
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodySmall
                                      .fontStyle,
                                ),
                          ),
                        ].divide(SizedBox(width: 6.0)),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Color(0xFFB8956A),
                            size: 14.0,
                          ),
                          Text(
                            'View Details',
                            style: FlutterFlowTheme.of(context)
                                .bodySmall
                                .override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .fontStyle,
                                  ),
                                  color: Color(0xFFB8956A),
                                  fontSize: 12.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodySmall
                                      .fontStyle,
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
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB8956A)),
          ),
        ),
      );
    }

    if (_projectId == null || _projectId!.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text('My Selections'),
        ),
        body: Center(
          child: Text(
            'No project assigned',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(),
                  color: Color(0xFF8B8680),
                  letterSpacing: 0.0,
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
          leading: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
            child: FlutterFlowIconButton(
              borderRadius: 22.0,
              buttonSize: 44.0,
              icon: Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFF2C2C2C),
                size: 22.0,
              ),
              body: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('projects')
                    .doc(_projectId)
                    .collection('items')
                    .orderBy('dueDate', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB8956A)),
                      ),
                    );
                  }

                  final items = snapshot.data!.docs;
                  final totalCount = items.length;
                  final approvedCount = items
                      .where((doc) => _isApproved((doc.data() as Map<String, dynamic>)['status']))
                      .length;
                  final installedCount = items
                      .where((doc) => _isInstalled((doc.data() as Map<String, dynamic>)['status']))
                      .length;
                  final completedCount = approvedCount + installedCount;
                  final progress = totalCount == 0
                      ? 0.0
                      : (completedCount / totalCount).clamp(0.0, 1.0);

                  final dueThisWeekItems = items.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return _isDueThisWeek(data['dueDate'] as Timestamp?) &&
                        !_isInstalled(data['status']);
                  }).toList();

                  final awaitingItems = items.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return _isAwaitingApproval(data['status']);
                  }).toList();

                  final approvedItems = items.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return _isApproved(data['status']);
                  }).toList();

                  final installedItems = items.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return _isInstalled(data['status']);
                  }).toList();

                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding:
                              EdgeInsetsDirectional.fromSTEB(20.0, 16.0, 20.0, 24.0),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(0.0),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Overall Progress',
                                            style: FlutterFlowTheme.of(context)
                                                .bodySmall
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight: FontWeight.w500,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(context)
                                                            .bodySmall
                                                            .fontStyle,
                                                  ),
                                                  color: Color(0xFF8B8680),
                                                  fontSize: 12.0,
                                                  letterSpacing: 0.5,
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(context)
                                                          .bodySmall
                                                          .fontStyle,
                                                ),
                                          ),
                                          Padding(
                                            padding: EdgeInsetsDirectional.fromSTEB(
                                                0.0, 4.0, 0.0, 0.0),
                                            child: Text(
                                              '$completedCount of $totalCount Complete',
                                              style: FlutterFlowTheme.of(context)
                                                  .headlineSmall
                                                  .override(
                                                    font: GoogleFonts.interTight(
                                                      fontWeight: FontWeight.bold,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(context)
                                                              .headlineSmall
                                                              .fontStyle,
                                                    ),
                                                    color: Color(0xFF2C2C2C),
                                                    fontSize: 18.0,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.bold,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(context)
                                                            .headlineSmall
                                                            .fontStyle,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        width: 56.0,
                                        height: 56.0,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFF5EFE8),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Align(
                                          alignment: AlignmentDirectional(0.0, 0.0),
                                          child: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              '${(progress * 100).round()}%',
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
                                                    fontSize: 14.0,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.bold,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(context)
                                                            .titleMedium
                                                            .fontStyle,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    width: double.infinity,
                                    height: 8.0,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFE8DDD3),
                                      borderRadius: BorderRadius.circular(100.0),
                                    ),
                                    child: Align(
                                      alignment: AlignmentDirectional(-1.0, 0.0),
                                      child: Container(
                                        width: MediaQuery.sizeOf(context).width *
                                            (progress == 0.0 ? 0.02 : progress),
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
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Container(
                                                width: 8.0,
                                                height: 8.0,
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFB8956A),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              Text(
                                                'Approved',
                                                style: FlutterFlowTheme.of(context)
                                                    .bodySmall
                                                    .override(
                                                      font: GoogleFonts.inter(
                                                        fontWeight:
                                                            FlutterFlowTheme.of(context)
                                                                .bodySmall
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(context)
                                                                .bodySmall
                                                                .fontStyle,
                                                      ),
                                                      color: Color(0xFF8B8680),
                                                      fontSize: 11.0,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FlutterFlowTheme.of(context)
                                                              .bodySmall
                                                              .fontWeight,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(context)
                                                              .bodySmall
                                                              .fontStyle,
                                                    ),
                                              ),
                                            ].divide(SizedBox(width: 6.0)),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Container(
                                                width: 8.0,
                                                height: 8.0,
                                                decoration: BoxDecoration(
                                                  color: Colors.green,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              Text(
                                                'Installed',
                                                style: FlutterFlowTheme.of(context)
                                                    .bodySmall
                                                    .override(
                                                      font: GoogleFonts.inter(
                                                        fontWeight:
                                                            FlutterFlowTheme.of(context)
                                                                .bodySmall
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(context)
                                                                .bodySmall
                                                                .fontStyle,
                                                      ),
                                                      color: Color(0xFF8B8680),
                                                      fontSize: 11.0,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FlutterFlowTheme.of(context)
                                                              .bodySmall
                                                              .fontWeight,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(context)
                                                              .bodySmall
                                                              .fontStyle,
                                                    ),
                                              ),
                                            ].divide(SizedBox(width: 6.0)),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Container(
                                                width: 8.0,
                                                height: 8.0,
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFE8DDD3),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              Text(
                                                'Pending',
                                                style: FlutterFlowTheme.of(context)
                                                    .bodySmall
                                                    .override(
                                                      font: GoogleFonts.inter(
                                                        fontWeight:
                                                            FlutterFlowTheme.of(context)
                                                                .bodySmall
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(context)
                                                                .bodySmall
                                                                .fontStyle,
                                                      ),
                                                      color: Color(0xFF8B8680),
                                                      fontSize: 11.0,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FlutterFlowTheme.of(context)
                                                              .bodySmall
                                                              .fontWeight,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(context)
                                                              .bodySmall
                                                              .fontStyle,
                                                    ),
                                              ),
                                            ].divide(SizedBox(width: 6.0)),
                                          ),
                                        ].divide(SizedBox(width: 16.0)),
                                      ),
                                    ],
                                  ),
                                ].divide(SizedBox(height: 12.0)),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          height: 1.0,
                          decoration: BoxDecoration(
                            color: Color(0xFFD4C4B0),
                          ),
                        ),
                        _buildSectionHeader(
                          'Due This Week',
                          dueThisWeekItems.length,
                          Color(0xFFCF6679),
                        ),
                        if (dueThisWeekItems.isEmpty)
                          Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(20.0, 8.0, 20.0, 16.0),
                            child: Text(
                              'No items due this week',
                              style: FlutterFlowTheme.of(context).bodySmall.override(
                                    font: GoogleFonts.inter(),
                                    color: Color(0xFF8B8680),
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          )
                        else
                          ListView.builder(
                            padding: EdgeInsets.zero,
                            primary: false,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: dueThisWeekItems.length,
                            itemBuilder: (context, index) {
                              final doc = dueThisWeekItems[index];
                              return _buildItemCard(
                                doc.data() as Map<String, dynamic>,
                                doc.id,
                                Color(0xFFCF6679),
                              );
                            },
                          ),
                        Container(
                          width: double.infinity,
                          height: 1.0,
                          decoration: BoxDecoration(
                            color: Color(0xFFD4C4B0),
                          ),
                        ),
                        _buildSectionHeader(
                          'Awaiting Approval',
                          awaitingItems.length,
                          Color(0xFFFFA726),
                        ),
                        if (awaitingItems.isEmpty)
                          Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(20.0, 8.0, 20.0, 16.0),
                            child: Text(
                              'No approvals needed right now',
                              style: FlutterFlowTheme.of(context).bodySmall.override(
                                    font: GoogleFonts.inter(),
                                    color: Color(0xFF8B8680),
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          )
                        else
                          ListView.builder(
                            padding: EdgeInsets.zero,
                            primary: false,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: awaitingItems.length,
                            itemBuilder: (context, index) {
                              final doc = awaitingItems[index];
                              return _buildItemCard(
                                doc.data() as Map<String, dynamic>,
                                doc.id,
                                Color(0xFFFFA726),
                              );
                            },
                          ),
                        Container(
                          width: double.infinity,
                          height: 1.0,
                          decoration: BoxDecoration(
                            color: Color(0xFFD4C4B0),
                          ),
                        ),
                        _buildSectionHeader(
                          'Approved',
                          approvedItems.length,
                          Color(0xFF4CAF50),
                        ),
                        if (approvedItems.isEmpty)
                          Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(20.0, 8.0, 20.0, 16.0),
                            child: Text(
                              'No approved selections yet',
                              style: FlutterFlowTheme.of(context).bodySmall.override(
                                    font: GoogleFonts.inter(),
                                    color: Color(0xFF8B8680),
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          )
                        else
                          ListView.builder(
                            padding: EdgeInsets.zero,
                            primary: false,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: approvedItems.length,
                            itemBuilder: (context, index) {
                              final doc = approvedItems[index];
                              return _buildItemCard(
                                doc.data() as Map<String, dynamic>,
                                doc.id,
                                Color(0xFF4CAF50),
                              );
                            },
                          ),
                        Container(
                          width: double.infinity,
                          height: 1.0,
                          decoration: BoxDecoration(
                            color: Color(0xFFD4C4B0),
                          ),
                        ),
                        _buildSectionHeader(
                          'Installed',
                          installedItems.length,
                          Color(0xFF7CB342),
                        ),
                        if (installedItems.isEmpty)
                          Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(20.0, 8.0, 20.0, 32.0),
                            child: Text(
                              'No installed selections yet',
                              style: FlutterFlowTheme.of(context).bodySmall.override(
                                    font: GoogleFonts.inter(),
                                    color: Color(0xFF8B8680),
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          )
                        else
                          ListView.builder(
                            padding: EdgeInsets.zero,
                            primary: false,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: installedItems.length,
                            itemBuilder: (context, index) {
                              final doc = installedItems[index];
                              return _buildItemCard(
                                doc.data() as Map<String, dynamic>,
                                doc.id,
                                Color(0xFF7CB342),
                              );
                            },
                          ),
                      ],
                    ),
                  );
                },
              ),
                                        Icons.chair_rounded,
