import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Widget that displays a list of pending decisions for the client
class PendingDecisionsList extends StatelessWidget {
  final String projectId;

  const PendingDecisionsList({
    super.key,
    required this.projectId,
  });

  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final itemDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
    
    final difference = itemDate.difference(today).inDays;
    
    if (difference == 0) {
      return 'Due Today';
    } else if (difference == 1) {
      return 'Due Tomorrow';
    } else if (difference < 0) {
      return 'Overdue';
    } else {
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return 'Due ${weekdays[dueDate.weekday - 1]}, ${months[dueDate.month - 1]} ${dueDate.day}';
    }
  }

  Color _getDueDateColor(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final itemDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
    
    final difference = itemDate.difference(today).inDays;
    
    if (difference <= 0) {
      return Color(0xFFE05C5C); // Red for overdue/today
    } else if (difference <= 2) {
      return Color(0xFFB8956A); // Brass for soon
    } else {
      return Color(0xFF8B8680); // Gray for later
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('projects')
          .doc(projectId)
          .collection('items')
          .where('status', whereIn: ['awaitingClientApproval', 'needsClientInput'])
          .orderBy('dueDate', descending: false)
          .limit(3)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading decisions',
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    font: GoogleFonts.inter(),
                    color: Color(0xFFE05C5C),
                    letterSpacing: 0.0,
                  ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB8956A)),
              ),
            ),
          );
        }

        final items = snapshot.data?.docs ?? [];

        if (items.isEmpty) {
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 48.0,
                    color: Color(0xFFB8956A),
                  ),
                  SizedBox(height: 12.0),
                  Text(
                    'No pending decisions',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                          color: Color(0xFF2C2C2C),
                          letterSpacing: 0.0,
                        ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    'You\'re all caught up!',
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          font: GoogleFonts.inter(),
                          color: Color(0xFF8B8680),
                          letterSpacing: 0.0,
                        ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            SizedBox(height: 12.0),
            ...items.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final itemName = data['name'] as String? ?? 'Untitled Item';
              final description = data['description'] as String? ?? '';
              final dueDate = (data['dueDate'] as Timestamp?)?.toDate();
              final itemId = doc.id;
              
              final isUrgent = dueDate != null && 
                  DateTime.now().difference(dueDate).inDays >= 0;

              return Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 12.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xFFFFF8F3),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: isUrgent ? Color(0xFFB8956A) : Color(0xFFD4C4B0),
                      width: 1.0,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                itemName,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      color: Color(0xFF2C2C2C),
                                      fontSize: 14.0,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                              if (description.isNotEmpty)
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 2.0, 0.0, 0.0),
                                  child: Text(
                                    description,
                                    style: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .override(
                                          font: GoogleFonts.inter(),
                                          color: Color(0xFF8B8680),
                                          fontSize: 12.0,
                                          letterSpacing: 0.0,
                                        ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              if (dueDate != null)
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 6.0, 0.0, 0.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Icon(
                                        Icons.schedule,
                                        color: _getDueDateColor(dueDate),
                                        size: 14.0,
                                      ),
                                      SizedBox(width: 4.0),
                                      Text(
                                        _formatDueDate(dueDate),
                                        style: FlutterFlowTheme.of(context)
                                            .bodySmall
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight: FontWeight.w600,
                                              ),
                                              color: _getDueDateColor(dueDate),
                                              fontSize: 11.0,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              12.0, 0.0, 0.0, 0.0),
                          child: InkWell(
                            onTap: () {
                              // Navigate to item detail page
                              context.pushNamed(
                                'ClientSelectionItemDetail',
                                queryParameters: {
                                  'projectId': projectId,
                                  'itemId': itemId,
                                }.withoutNulls,
                              );
                            },
                            child: Container(
                              height: 32.0,
                              decoration: BoxDecoration(
                                color: Color(0xFFB8956A),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.0, vertical: 8.0),
                                child: Text(
                                  'Review',
                                  style: FlutterFlowTheme.of(context)
                                      .bodySmall
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        color: Colors.white,
                                        fontSize: 12.0,
                                        letterSpacing: 0.0,
                                      ),
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
            }).toList(),
          ],
        );
      },
    );
  }
}
