import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'client_selection_catagories_model.dart';
export 'client_selection_catagories_model.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';

/// # Client Selection Categories
///
/// Build category navigation for Client role listing all categories.
///
/// Use **category_checklist** for categories with completion status and
/// **progress_bar** for visual completion indicators. Show category name,
/// total items, completed count ("X of Y completed"). Tap opens filtered item
/// list. Query categories and aggregate item counts. Design on white
/// (#FFFFFF) with rounded cards, soft taupe (#D4C4B0) borders, brass accent
/// (#B8956A) for completion/progress, warm neutral gray (#8B8680) for counts.
/// Apply premium spacing.
class ClientSelectionCatagoriesWidget extends StatefulWidget {
  const ClientSelectionCatagoriesWidget({super.key});

  static String routeName = 'ClientSelectionCatagories';
  static String routePath = '/clientSelectionCatagories';

  @override
  State<ClientSelectionCatagoriesWidget> createState() =>
      _ClientSelectionCatagoriesWidgetState();
}

class _ClientSelectionCatagoriesWidgetState
    extends State<ClientSelectionCatagoriesWidget> {
  late ClientSelectionCatagoriesModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ClientSelectionCatagoriesModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  // Get icon for category
  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('kitchen') || name.contains('dining')) {
      return Icons.checklist_rounded;
    } else if (name.contains('living')) {
      return Icons.weekend_rounded;
    } else if (name.contains('bedroom')) {
      return Icons.bed_rounded;
    } else if (name.contains('bathroom') || name.contains('bath')) {
      return Icons.bathtub_rounded;
    } else if (name.contains('outdoor') || name.contains('garden')) {
      return Icons.outdoor_grill_rounded;
    } else if (name.contains('office')) {
      return Icons.computer_rounded;
    } else if (name.contains('flooring') || name.contains('floor')) {
      return Icons.layers_rounded;
    } else if (name.contains('lighting') || name.contains('light')) {
      return Icons.lightbulb_rounded;
    } else if (name.contains('paint')) {
      return Icons.palette_rounded;
    } else if (name.contains('tile')) {
      return Icons.grid_on_rounded;
    } else if (name.contains('countertop')) {
      return Icons.countertops_rounded;
    } else if (name.contains('hardware')) {
      return Icons.handyman_rounded;
    }
    return Icons.category_rounded;
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
            'Categories',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(
                    fontWeight: FontWeight.bold,
                    fontStyle:
                        FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                  ),
                  color: Color(0xFF2C2825),
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
              child: FlutterFlowIconButton(
                borderRadius: 22.0,
                buttonSize: 44.0,
                icon: Icon(
                  Icons.search_rounded,
                  color: Color(0xFF8B8680),
                  size: 22.0,
                ),
                onPressed: () {
                  print('IconButton pressed ...');
                },
              ),
            ),
          ],
          centerTitle: false,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: StreamBuilder<UsersRecord?>(
            stream: UsersRecord.getDocument(currentUserReference!),
            builder: (context, userSnapshot) {
              if (!userSnapshot.hasData) {
                return Center(
                  child: SizedBox(
                    width: 50.0,
                    height: 50.0,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFFB8956A),
                      ),
                    ),
                  ),
                );
              }

              final user = userSnapshot.data;
              if (user == null || user.projectIds.isEmpty) {
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

              final projectId = user.projectIds.first;

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('projects')
                    .doc(projectId)
                    .collection('categories')
                    .orderBy('displayOrder')
                    .snapshots(),
                builder: (context, categoriesSnapshot) {
                  if (!categoriesSnapshot.hasData) {
                    return Center(
                      child: SizedBox(
                        width: 50.0,
                        height: 50.0,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFB8956A),
                          ),
                        ),
                      ),
                    );
                  }

                  final categories = categoriesSnapshot.data!.docs;

                  if (categories.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          'No categories available yet',
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.inter(),
                                color: Color(0xFF8B8680),
                                letterSpacing: 0.0,
                              ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(20.0, 4.0, 20.0, 8.0),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Track your progress across all categories',
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.normal,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    color: Color(0xFF8B8680),
                                    fontSize: 14.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.normal,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.fromLTRB(0, 12.0, 0, 32.0),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final categoryDoc = categories[index];
                            final categoryData = categoryDoc.data() as Map<String, dynamic>;
                            final categoryId = categoryDoc.id;
                            final categoryName = categoryData['name'] ?? 'Unknown';
                            
                            // Get progress data
                            final progress = categoryData['progress'] as Map<String, dynamic>?;
                            final totalItems = progress?['totalItems'] ?? 0;
                            final completedItems = progress?['completedItems'] ?? 0;
                            
                            // Calculate percentage
                            final percentage = totalItems > 0 
                                ? (completedItems / totalItems * 100).round() 
                                : 0;
                            final progressWidth = totalItems > 0 
                                ? (completedItems / totalItems) 
                                : 0.0;

                            return Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 12.0),
                              child: InkWell(
                                onTap: () {
                                  // Navigate to item detail page - in a real app, this would show a filtered list
                                  // For now, navigate to selections home
                                  context.pushNamed(
                                    'ClientSelectionsHome',
                                    queryParameters: {
                                      'projectId': projectId,
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
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Container(
                                                  width: 44.0,
                                                  height: 44.0,
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFFFBF7F2),
                                                    borderRadius: BorderRadius.circular(12.0),
                                                  ),
                                                  child: Align(
                                                    alignment: AlignmentDirectional(0.0, 0.0),
                                                    child: Icon(
                                                      _getCategoryIcon(categoryName),
                                                      color: Color(0xFFB8956A),
                                                      size: 22.0,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 12.0),
                                                Column(
                                                  mainAxisSize: MainAxisSize.max,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      categoryName,
                                                      style: FlutterFlowTheme.of(context)
                                                          .titleMedium
                                                          .override(
                                                            font: GoogleFonts.interTight(
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                            color: Color(0xFF2C2825),
                                                            fontSize: 16.0,
                                                            letterSpacing: 0.0,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                    ),
                                                    Text(
                                                      '$totalItems items total',
                                                      style: FlutterFlowTheme.of(context)
                                                          .bodySmall
                                                          .override(
                                                            font: GoogleFonts.inter(
                                                              fontWeight: FontWeight.normal,
                                                            ),
                                                            color: Color(0xFF8B8680),
                                                            fontSize: 12.0,
                                                            letterSpacing: 0.0,
                                                            fontWeight: FontWeight.normal,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Container(
                                              width: 48.0,
                                              height: 48.0,
                                              decoration: BoxDecoration(
                                                color: Color(0xFFFBF7F2),
                                                borderRadius: BorderRadius.circular(24.0),
                                              ),
                                              child: Align(
                                                alignment: AlignmentDirectional(0.0, 0.0),
                                                child: Icon(
                                                  Icons.chevron_right_rounded,
                                                  color: Color(0xFFB8956A),
                                                  size: 20.0,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 14.0),
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              '$completedItems of $totalItems completed',
                                              style: FlutterFlowTheme.of(context)
                                                  .bodySmall
                                                  .override(
                                                    font: GoogleFonts.inter(
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                    color: Color(0xFFB8956A),
                                                    fontSize: 13.0,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                            Text(
                                              '$percentage%',
                                              style: FlutterFlowTheme.of(context)
                                                  .bodySmall
                                                  .override(
                                                    font: GoogleFonts.inter(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    color: Color(0xFFB8956A),
                                                    fontSize: 13.0,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 14.0),
                                        Container(
                                          width: double.infinity,
                                          height: 6.0,
                                          decoration: BoxDecoration(
                                            color: Color(0xFFEDE5DA),
                                            borderRadius: BorderRadius.circular(100.0),
                                          ),
                                          child: FractionallySizedBox(
                                            alignment: Alignment.centerLeft,
                                            widthFactor: progressWidth,
                                            child: Container(
                                              height: 6.0,
                                              decoration: BoxDecoration(
                                                color: Color(0xFFB8956A),
                                                borderRadius: BorderRadius.circular(100.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
