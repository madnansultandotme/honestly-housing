import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'client_selection_item_detail_model.dart';
export 'client_selection_item_detail_model.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';

/// # Client Selection Item Detail
///
/// Build selection review for Client role using **visual_approval_card** as
/// main element with **budget_impact_row** for allowance/cost/difference and
/// **status_badge** for current status.
///
/// Add "Approve" button (writes approvedAt, sets status "Approved", locks
/// item) and "Request Change" button (creates change request, notifies
/// builder). Query item, category, allowance. Write to item status,
/// approvedAt, change requests. Design on white (#FFFFFF) with brass accent
/// (#B8956A) for positive differences and Approve button, warm neutral gray
/// (#8B8680) for negative differences, soft taupe (#D4C4B0) for Request
/// Change. Apply rounded corners and premium spacing.
class ClientSelectionItemDetailWidget extends StatefulWidget {
  const ClientSelectionItemDetailWidget({
    super.key,
    required this.itemId,
    required this.projectId,
  });

  final String itemId;
  final String projectId;

  static String routeName = 'ClientSelectionItemDetail';
  static String routePath = '/clientSelectionItemDetail';

  @override
  State<ClientSelectionItemDetailWidget> createState() =>
      _ClientSelectionItemDetailWidgetState();
}

class _ClientSelectionItemDetailWidgetState
    extends State<ClientSelectionItemDetailWidget> {
  late ClientSelectionItemDetailModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isApproving = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ClientSelectionItemDetailModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  // Approve the selection
  Future<void> _approveSelection() async {
    setState(() {
      _isApproving = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('projects')
          .doc(widget.projectId)
          .collection('items')
          .doc(widget.itemId)
          .update({
        'status': 'approved',
        'locked': true,
        'approvedAt': FieldValue.serverTimestamp(),
        'approvedBy': currentUserUid,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selection approved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back
      context.pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error approving selection: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isApproving = false;
      });
    }
  }

  // Request a change
  Future<void> _requestChange() async {
    // Show dialog to get reason
    final reasonController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Request Change'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Please explain why you need to change this selection:'),
            SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter your reason here...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Submit Request'),
          ),
        ],
      ),
    );

    if (result == true && reasonController.text.isNotEmpty) {
      try {
        // Get item data first
        final itemDoc = await FirebaseFirestore.instance
            .collection('projects')
            .doc(widget.projectId)
            .collection('items')
            .doc(widget.itemId)
            .get();

        final itemData = itemDoc.data();
        final itemName = itemData?['name'] ?? 'Unknown Item';

        // Get user data
        final userDoc = await UsersRecord.getDocumentOnce(currentUserReference!);
        final userName = userDoc?.displayName ?? 'Unknown User';

        // Create change request
        await FirebaseFirestore.instance
            .collection('projects')
            .doc(widget.projectId)
            .collection('changeRequests')
            .add({
          'itemId': widget.itemId,
          'itemName': itemName,
          'requestedBy': currentUserUid,
          'requestedByName': userName,
          'reason': reasonController.text,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Change request submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back
        context.pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting change request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
          leading: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
            child: FlutterFlowIconButton(
              borderRadius: 22.0,
              buttonSize: 44.0,
              icon: Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFF2D2D2D),
                size: 22.0,
              ),
              onPressed: () {
                context.pop();
              },
            ),
          ),
          title: Text(
            'Selection Review',
            style: FlutterFlowTheme.of(context).titleLarge.override(
                  font: GoogleFonts.interTight(
                    fontWeight: FontWeight.bold,
                  ),
                  color: Color(0xFF2D2D2D),
                  fontSize: 20.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.bold,
                ),
          ),
          centerTitle: false,
          elevation: 0.0,
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('projects')
              .doc(widget.projectId)
              .collection('items')
              .doc(widget.itemId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
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

            final itemDoc = snapshot.data!;
            if (!itemDoc.exists) {
              return Center(
                child: Text('Item not found'),
              );
            }

            final itemData = itemDoc.data() as Map<String, dynamic>;
            final name = itemData['name'] ?? 'Unknown Item';
            final categoryName = itemData['categoryName'] ?? 'Unknown Category';
            final brand = itemData['brand'] ?? '';
            final description = itemData['description'] ?? '';
            final imageUrl = itemData['imageUrl'];
            final linkUrl = itemData['linkUrl'];
            final allowance = itemData['allowance'] ?? 0.0;
            final actualCost = itemData['actualCost'] ?? 0.0;
            final difference = actualCost - allowance;
            final status = itemData['status'] ?? 'notStarted';
            final locked = itemData['locked'] ?? false;
            final roomName = itemData['roomName'];

            // Check if item can be approved
            final canApprove = status.toLowerCase() == 'awaitingclientapproval' && !locked;

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  // Status Badge in AppBar area
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(20.0, 8.0, 20.0, 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: _getStatusColor(status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(12.0, 6.0, 12.0, 6.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8.0,
                                  height: 8.0,
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(status),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 6.0),
                                Text(
                                  _getStatusText(status),
                                  style: FlutterFlowTheme.of(context).labelSmall.override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                        ),
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
                  ),

                  // Item Card
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 20.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 24.0,
                            color: Color(0x1A000000),
                            offset: Offset(0.0, 4.0),
                          )
                        ],
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category Header
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
                                        'CATEGORY',
                                        style: FlutterFlowTheme.of(context).labelSmall.override(
                                              font: GoogleFonts.inter(
                                                fontWeight: FontWeight.w600,
                                              ),
                                              color: Color(0xFF8B8680),
                                              fontSize: 10.0,
                                              letterSpacing: 1.2,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      SizedBox(height: 4.0),
                                      Text(
                                        categoryName,
                                        style: FlutterFlowTheme.of(context).headlineSmall.override(
                                              font: GoogleFonts.interTight(
                                                fontWeight: FontWeight.bold,
                                              ),
                                              color: Color(0xFF2D2D2D),
                                              fontSize: 22.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      if (roomName != null)
                                        Text(
                                          roomName,
                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                font: GoogleFonts.inter(),
                                                color: Color(0xFF8B8680),
                                                fontSize: 13.0,
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Divider(
                              height: 32.0,
                              thickness: 1.0,
                              color: Color(0xFFF5F0EB),
                            ),

                            // Item Details
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Image
                                if (imageUrl != null)
                                  Container(
                                    width: 80.0,
                                    height: 80.0,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFF5F0EB),
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16.0),
                                      child: Image.network(
                                        imageUrl,
                                        width: 80.0,
                                        height: 80.0,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Icon(
                                            Icons.image_not_supported,
                                            color: Color(0xFF8B8680),
                                            size: 40.0,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                SizedBox(width: 16.0),

                                // Item Info
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: FlutterFlowTheme.of(context).titleMedium.override(
                                              font: GoogleFonts.interTight(
                                                fontWeight: FontWeight.w600,
                                              ),
                                              color: Color(0xFF2D2D2D),
                                              fontSize: 16.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w600,
                                              lineHeight: 1.3,
                                            ),
                                      ),
                                      if (brand.isNotEmpty || description.isNotEmpty)
                                        Padding(
                                          padding: EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                                          child: Text(
                                            brand.isNotEmpty ? brand : description,
                                            style: FlutterFlowTheme.of(context).bodySmall.override(
                                                  font: GoogleFonts.inter(),
                                                  color: Color(0xFF8B8680),
                                                  fontSize: 12.0,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ),
                                      if (linkUrl != null)
                                        Padding(
                                          padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                                          child: InkWell(
                                            onTap: () async {
                                              await launchURL(linkUrl);
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Color(0xFFF5EDE3),
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 4.0),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.link_rounded,
                                                      color: Color(0xFFB8956A),
                                                      size: 12.0,
                                                    ),
                                                    SizedBox(width: 4.0),
                                                    Text(
                                                      'View Product',
                                                      style: FlutterFlowTheme.of(context).labelSmall.override(
                                                            font: GoogleFonts.inter(
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                            color: Color(0xFFB8956A),
                                                            fontSize: 11.0,
                                                            letterSpacing: 0.0,
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
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Budget Impact Card
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 20.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 24.0,
                            color: Color(0x1A000000),
                            offset: Offset(0.0, 4.0),
                          )
                        ],
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BUDGET IMPACT',
                              style: FlutterFlowTheme.of(context).labelSmall.override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    color: Color(0xFF8B8680),
                                    fontSize: 10.0,
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            SizedBox(height: 16.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Allowance',
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        font: GoogleFonts.inter(),
                                        color: Color(0xFF8B8680),
                                        letterSpacing: 0.0,
                                      ),
                                ),
                                Text(
                                  '\$${allowance.toStringAsFixed(2)}',
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        color: Color(0xFF2D2D2D),
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Actual Cost',
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        font: GoogleFonts.inter(),
                                        color: Color(0xFF8B8680),
                                        letterSpacing: 0.0,
                                      ),
                                ),
                                Text(
                                  '\$${actualCost.toStringAsFixed(2)}',
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        color: Color(0xFF2D2D2D),
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                            Divider(
                              height: 24.0,
                              thickness: 1.0,
                              color: Color(0xFFF5F0EB),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Difference',
                                  style: FlutterFlowTheme.of(context).titleMedium.override(
                                        font: GoogleFonts.interTight(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        color: Color(0xFF2D2D2D),
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                Text(
                                  '${difference >= 0 ? '+' : ''}\$${difference.toStringAsFixed(2)}',
                                  style: FlutterFlowTheme.of(context).titleMedium.override(
                                        font: GoogleFonts.interTight(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        color: difference >= 0 ? Color(0xFFB8956A) : Colors.red,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Action Buttons
                  if (canApprove)
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 40.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          FFButtonWidget(
                            onPressed: _isApproving ? null : _approveSelection,
                            text: _isApproving ? 'Approving...' : 'Approve Selection',
                            options: FFButtonOptions(
                              width: double.infinity,
                              height: 56.0,
                              padding: EdgeInsets.all(8.0),
                              iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                              color: Color(0xFFB8956A),
                              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                    font: GoogleFonts.interTight(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    color: Colors.white,
                                    fontSize: 15.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                              elevation: 0.0,
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                          ),
                          SizedBox(height: 12.0),
                          FFButtonWidget(
                            onPressed: _requestChange,
                            text: 'Request Change',
                            options: FFButtonOptions(
                              width: double.infinity,
                              height: 56.0,
                              padding: EdgeInsets.all(8.0),
                              iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                              color: Colors.white,
                              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                    font: GoogleFonts.interTight(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    color: Color(0xFF8B8680),
                                    fontSize: 15.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                              elevation: 0.0,
                              borderSide: BorderSide(
                                color: Color(0xFFD4C4B0),
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Locked message
                  if (locked)
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 40.0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Color(0xFFF0F7F0),
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 24.0,
                              ),
                              SizedBox(width: 12.0),
                              Expanded(
                                child: Text(
                                  'This selection has been approved and locked.',
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        color: Colors.green,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
