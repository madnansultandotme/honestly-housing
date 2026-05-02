import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '/flutter_flow/flutter_flow_theme.dart';

/// Widget that displays the project overview card with progress
class ProjectOverviewCard extends StatelessWidget {
  final String projectName;
  final String projectStatus;
  final DateTime? startDate;
  final DateTime? targetDate;
  final String phase;
  final double completionPercent;
  final bool isLoading;

  const ProjectOverviewCard({
    super.key,
    required this.projectName,
    required this.projectStatus,
    this.startDate,
    this.targetDate,
    required this.phase,
    required this.completionPercent,
    this.isLoading = false,
  });

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not set';
    return '${date.month}/${date.day}/${date.year}';
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'active':
        return 'In Progress';
      case 'planning':
        return 'Planning';
      case 'completed':
        return 'Completed';
      case 'onHold':
        return 'On Hold';
      default:
        return 'In Progress';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Color(0xFFB8956A);
      case 'planning':
        return Color(0xFF8B8680);
      case 'completed':
        return Color(0xFF4CAF50);
      case 'onHold':
        return Color(0xFFE05C5C);
      default:
        return Color(0xFFB8956A);
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status) {
      case 'active':
        return Color(0xFFF5EDE3);
      case 'planning':
        return Color(0xFFF5F5F5);
      case 'completed':
        return Color(0xFFE8F5E9);
      case 'onHold':
        return Color(0xFFFFEBEE);
      default:
        return Color(0xFFF5EDE3);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
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
              // Project name and status
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isLoading ? 'Loading...' : projectName,
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
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 2.0, 0.0, 0.0),
                          child: Text(
                            'Interior Design Project',
                            style: FlutterFlowTheme.of(context)
                                .bodySmall
                                .override(
                                  font: GoogleFonts.inter(),
                                  color: Color(0xFF8B8680),
                                  fontSize: 12.0,
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 28.0,
                    decoration: BoxDecoration(
                      color: _getStatusBgColor(projectStatus),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 6.0),
                      child: Text(
                        _getStatusLabel(projectStatus),
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              font: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                              ),
                              color: _getStatusColor(projectStatus),
                              fontSize: 12.0,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.0),
              
              // Progress bar
              Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Overall Completion',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              font: GoogleFonts.inter(),
                              color: Color(0xFF8B8680),
                              fontSize: 13.0,
                              letterSpacing: 0.0,
                            ),
                      ),
                      Text(
                        isLoading
                            ? '--'
                            : '${(completionPercent * 100).toStringAsFixed(0)}%',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              font: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                              ),
                              color: Color(0xFFB8956A),
                              fontSize: 13.0,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.0),
                  LinearPercentIndicator(
                    percent: isLoading ? 0.0 : completionPercent.clamp(0.0, 1.0),
                    width: MediaQuery.sizeOf(context).width - 72.0,
                    lineHeight: 10.0,
                    animation: true,
                    animateFromLastPercent: true,
                    progressColor: Color(0xFFB8956A),
                    backgroundColor: Color(0xFFF5EFE8),
                    barRadius: Radius.circular(8.0),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              SizedBox(height: 14.0),
              
              // Project details
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start Date',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              font: GoogleFonts.inter(),
                              color: Color(0xFF8B8680),
                              fontSize: 11.0,
                              letterSpacing: 0.0,
                            ),
                      ),
                      Text(
                        isLoading ? '--' : _formatDate(startDate),
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              font: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                              ),
                              color: Color(0xFF2C2C2C),
                              fontSize: 13.0,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Phase',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              font: GoogleFonts.inter(),
                              color: Color(0xFF8B8680),
                              fontSize: 11.0,
                              letterSpacing: 0.0,
                            ),
                      ),
                      Text(
                        isLoading ? '--' : phase,
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              font: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                              ),
                              color: Color(0xFF2C2C2C),
                              fontSize: 13.0,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Est. Completion',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              font: GoogleFonts.inter(),
                              color: Color(0xFF8B8680),
                              fontSize: 11.0,
                              letterSpacing: 0.0,
                            ),
                      ),
                      Text(
                        isLoading ? '--' : _formatDate(targetDate),
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              font: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                              ),
                              color: Color(0xFF2C2C2C),
                              fontSize: 13.0,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
