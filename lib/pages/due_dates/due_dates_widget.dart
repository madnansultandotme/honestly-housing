import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'due_dates_model.dart';
export 'due_dates_model.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import 'package:intl/intl.dart';

/// # Due Dates
///
/// Build due dates page showing upcoming selection deadlines chronologically
/// by project.
///
/// Use **due_this_week_list** for most urgent items and **status_badge** for
/// each item state. Highlight overdue items. Query items with dueDate. Design
/// on white (#FFFFFF) as date-grouped list with brass accent (#B8956A) for
/// overdue highlights, soft taupe (#D4C4B0) for date headers/dividers, warm
/// neutral gray (#8B8680) for regular dates. Apply rounded corners and
/// premium spacing.
class DueDatesWidget extends StatefulWidget {
  const DueDatesWidget({super.key});

  static String routeName = 'DueDates';
  static String routePath = '/dueDates';

  @override
  State<DueDatesWidget> createState() => _DueDatesWidgetState();
}

class _DueDatesWidgetState extends State<DueDatesWidget> {
  late DueDatesModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DueDatesModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  // Get status badge color
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'awaitingclientapproval':
      case 'needsbuilderinput':
        return Color(0xFFB8956A);
      case 'ordered':
        return Colors.blue;
      case 'installed':
        return Colors.purple;
      default:
        return Color(0xFF8B8680);
    }
  }

  // Get status display text
  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'notstarted':
        return 'Not Started';
      case 'needsbuilderinput':
        return 'Needs Builder Input';
      case 'awaitingclientapproval':
        return 'Pending Review';
      case 'approved':
        return 'Approved';
      case 'ordered':
        return 'Ordered';
      case 'installed':
        return 'Installed';
      default:
        return status;
    }
  }

  // Check if date is overdue
  bool _isOverdue(Timestamp? dueDate) {
    if (dueDate == null) return false;
    return dueDate.toDate().isBefore(DateTime.now());
  }

  // Get relative time string
  String _getRelativeTime(Timestamp? dueDate) {
    if (dueDate == null) return '';
    final date = dueDate.toDate();
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.isNegative) {
      final days = difference.inDays.abs();
      if (days == 0) return 'Today';
      if (days == 1) return '1 day ago';
      return '$days days ago';
    } else {
      final days = difference.inDays;
      if (days == 0) return 'Today';
      if (days == 1) return 'Tomorrow';
      if (days <= 7) return 'In $days days';
      return DateFormat('MMM d').format(date);
    }
  }

  Widget _buildItemCard(
    Map<String, dynamic> itemData,
    String projectId,
    String itemId,
    bool isOverdue,
    bool isBuilder,
  ) {
    final name = itemData['name'] ?? 'Unknown Item';
    final categoryName = itemData['categoryName'] ?? '';
    final status = itemData['status'] ?? 'notStarted';
    final dueDate = itemData['dueDate'] as Timestamp?;

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 12.0),
      child: InkWell(
        onTap: () {
          if (isBuilder) {
            context.pushNamed(
              'BuilderSelectionItemDetail',
              queryParameters: {
                'itemId': itemId,
                'projectId': projectId,
              },
            );
          } else {
            context.pushNamed(
              'ClientSelectionItemDetail',
              queryParameters: {
                'itemId': itemId,
                'projectId': projectId,
              },
            );
          }
        },
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: isOverdue ? 12.0 : 8.0,
                color: isOverdue ? Color(0x1AB8956A) : Color(0x0D000000),
                offset: Offset(0.0, 2.0),
              )
            ],
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: isOverdue ? Color(0xFFF0D5B8) : Color(0xFFEDE8E0),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                // Top indicator bar
                Container(
                  width: double.infinity,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: isOverdue ? Color(0xFFB8956A) : Color(0xFF7B9EC4),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
                SizedBox(height: 14.0),
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
                          if (isOverdue)
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 6.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFFFDEEE0),
                                  borderRadius: BorderRadius.circular(6.0),
                                ),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 4.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.warning_amber_rounded,
                                        color: Color(0xFFB8956A),
                                        size: 12.0,
                                      ),
                                      SizedBox(width: 4.0),
                                      Text(
                                        'OVERDUE',
                                        style: FlutterFlowTheme.of(context).labelSmall.override(
                                              font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                              color: Color(0xFFB8956A),
                                              fontSize: 10.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          if (categoryName.isNotEmpty)
                            Text(
                              categoryName.toUpperCase(),
                              style: FlutterFlowTheme.of(context).bodySmall.override(
                                    font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                    color: Color(0xFFB8956A),
                                    fontSize: 10.0,
                                    letterSpacing: 1.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          SizedBox(height: 3.0),
                          Text(
                            name,
                            style: FlutterFlowTheme.of(context).titleMedium.override(
                                  font: GoogleFonts.interTight(fontWeight: FontWeight.w600),
                                  color: Color(0xFF1A1A1A),
                                  fontSize: 15.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: isOverdue ? Color(0xFFFDEEE0) : Color(0xFFEEF3F9),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          _getRelativeTime(dueDate),
                          style: FlutterFlowTheme.of(context).labelSmall.override(
                                font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                color: isOverdue ? Color(0xFFB8956A) : Color(0xFF7B9EC4),
                                fontSize: 11.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.0),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(10.0, 5.0, 10.0, 5.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6.0,
                              height: 6.0,
                              decoration: BoxDecoration(
                                color: _getStatusColor(status),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 5.0),
                            Text(
                              _getStatusText(status),
                              style: FlutterFlowTheme.of(context).labelSmall.override(
                                    font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                    color: _getStatusColor(status),
                                    fontSize: 11.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: AppBar(
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            title: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Due Dates',
                        style: FlutterFlowTheme.of(context).headlineMedium.override(
                              font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                              color: Color(0xFF1A1A1A),
                              fontSize: 26.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'Upcoming selection deadlines',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              font: GoogleFonts.inter(fontWeight: FontWeight.normal),
                              color: Color(0xFF8B8680),
                              fontSize: 13.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.normal,
                            ),
                      ),
                    ],
                  ),
                  Container(
                    width: 44.0,
                    height: 44.0,
                    decoration: BoxDecoration(
                      color: Color(0xFFF5F0EA),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Align(
                      alignment: AlignmentDirectional(0.0, 0.0),
                      child: Icon(
                        Icons.filter_list_rounded,
                        color: Color(0xFFB8956A),
                        size: 22.0,
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
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(currentUserUid)
              .snapshots(),
          builder: (context, userSnapshot) {
            if (!userSnapshot.hasData) {
              return Center(
                child: SizedBox(
                  width: 50.0,
                  height: 50.0,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB8956A)),
                  ),
                ),
              );
            }

            final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
            final userProjectIds = List<String>.from(userData?['projectIds'] ?? []);
            final isBuilder = (userData?['role'] ?? '') == 'builder' ||
                (userData?['role'] ?? '') == 'designer';
            if (userData == null || userProjectIds.isEmpty) {
              return Center(
                child: Text(
                  'No project assigned',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(),
                        color: Color(0xFF8B8680),
                        letterSpacing: 0.0,
                      ),
                ),
              );
            }

            // Query items with due dates from all user's projects
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collectionGroup('items')
                  .where('dueDate', isNull: false)
                  .orderBy('dueDate', descending: false)
                  .snapshots(),
              builder: (context, itemsSnapshot) {
                if (!itemsSnapshot.hasData) {
                  return Center(
                    child: SizedBox(
                      width: 50.0,
                      height: 50.0,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB8956A)),
                      ),
                    ),
                  );
                }

                // Filter items for user's projects only and extract projectId
                final allItemsWithProjects = itemsSnapshot.data!.docs.map((doc) {
                  final path = doc.reference.path;
                  final projectId = path.split('/')[1]; // Extract projectId from path
                  return {'doc': doc, 'projectId': projectId};
                }).where((item) {
                  return userProjectIds.contains(item['projectId']);
                }).toList();

                if (allItemsWithProjects.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        'No items with due dates',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.inter(),
                              color: Color(0xFF8B8680),
                              letterSpacing: 0.0,
                            ),
                      ),
                    ),
                  );
                }

                // Separate overdue and upcoming items
                final now = DateTime.now();
                final overdueItems = allItemsWithProjects.where((item) {
                  final doc = item['doc'] as DocumentSnapshot;
                  final data = doc.data() as Map<String, dynamic>;
                  final dueDate = data['dueDate'] as Timestamp?;
                  return dueDate != null && dueDate.toDate().isBefore(now);
                }).toList();

                final upcomingItems = allItemsWithProjects.where((item) {
                  final doc = item['doc'] as DocumentSnapshot;
                  final data = doc.data() as Map<String, dynamic>;
                  final dueDate = data['dueDate'] as Timestamp?;
                  return dueDate != null && !dueDate.toDate().isBefore(now);
                }).toList();

                return Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 1.0,
                      decoration: BoxDecoration(
                        color: Color(0xFFF0EBE3),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.fromLTRB(0, 8.0, 0, 40.0),
                        children: [
                          // Overdue Section
                          if (overdueItems.isNotEmpty) ...[
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(20.0, 16.0, 20.0, 8.0),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Color(0xFFFFF8F0),
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(
                                    color: Color(0xFFB8956A),
                                    width: 1.0,
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(12.0),
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
                                              color: Color(0xFFB8956A),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          SizedBox(width: 8.0),
                                          Text(
                                            'OVERDUE',
                                            style: FlutterFlowTheme.of(context).labelMedium.override(
                                                  font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                                  color: Color(0xFFB8956A),
                                                  fontSize: 11.0,
                                                  letterSpacing: 1.5,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFB8956A),
                                          borderRadius: BorderRadius.circular(20.0),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsetsDirectional.fromSTEB(10.0, 4.0, 10.0, 4.0),
                                          child: Text(
                                            '${overdueItems.length} items',
                                            style: FlutterFlowTheme.of(context).labelSmall.override(
                                                  font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                                  color: Colors.white,
                                                  fontSize: 11.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
                              child: Container(
                                width: double.infinity,
                                height: 1.0,
                                decoration: BoxDecoration(
                                  color: Color(0xFFE8D5BC),
                                ),
                              ),
                            ),
                            ...overdueItems.map((item) {
                              final doc = item['doc'] as DocumentSnapshot;
                              final projectId = item['projectId'] as String;
                              final data = doc.data() as Map<String, dynamic>;
                              return _buildItemCard(
                                data,
                                projectId,
                                doc.id,
                                true,
                                isBuilder,
                              );
                            }).toList(),
                          ],

                          // Upcoming Section
                          if (upcomingItems.isNotEmpty) ...[
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(20.0, 24.0, 20.0, 8.0),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Color(0xFFF5F9FC),
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(
                                    color: Color(0xFF7B9EC4),
                                    width: 1.0,
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(12.0),
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
                                              color: Color(0xFF7B9EC4),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          SizedBox(width: 8.0),
                                          Text(
                                            'UPCOMING',
                                            style: FlutterFlowTheme.of(context).labelMedium.override(
                                                  font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                                  color: Color(0xFF7B9EC4),
                                                  fontSize: 11.0,
                                                  letterSpacing: 1.5,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFF7B9EC4),
                                          borderRadius: BorderRadius.circular(20.0),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsetsDirectional.fromSTEB(10.0, 4.0, 10.0, 4.0),
                                          child: Text(
                                            '${upcomingItems.length} items',
                                            style: FlutterFlowTheme.of(context).labelSmall.override(
                                                  font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                                  color: Colors.white,
                                                  fontSize: 11.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
                              child: Container(
                                width: double.infinity,
                                height: 1.0,
                                decoration: BoxDecoration(
                                  color: Color(0xFFD5E4F0),
                                ),
                              ),
                            ),
                            ...upcomingItems.map((item) {
                              final doc = item['doc'] as DocumentSnapshot;
                              final projectId = item['projectId'] as String;
                              final data = doc.data() as Map<String, dynamic>;
                              return _buildItemCard(
                                data,
                                projectId,
                                doc.id,
                                false,
                                isBuilder,
                              );
                            }).toList(),
                          ],

                          // Empty state
                          if (overdueItems.isEmpty && upcomingItems.isEmpty)
                            Padding(
                              padding: EdgeInsets.all(40.0),
                              child: Center(
                                child: Text(
                                  'No items with due dates',
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        font: GoogleFonts.inter(),
                                        color: Color(0xFF8B8680),
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
