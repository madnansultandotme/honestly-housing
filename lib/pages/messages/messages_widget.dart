import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'messages_model.dart';
export 'messages_model.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import 'package:intl/intl.dart';

/// # Messages
///
/// Build project-scoped messaging for threaded chat between Builders and
/// Clients.
///
/// Include message composer for new messages. Query messages by project,
/// write to messages collection. Design on white (#FFFFFF) with chat bubbles:
/// soft taupe (#D4C4B0) for received, brass accent (#B8956A) for sent. Use
/// warm neutral gray (#8B8680) for timestamps. Add text input with brass
/// accent (#B8956A) send button. Apply rounded corners on bubbles and premium
/// spacing.
class MessagesWidget extends StatefulWidget {
  const MessagesWidget({super.key});

  static String routeName = 'Messages';
  static String routePath = '/messages';

  @override
  State<MessagesWidget> createState() => _MessagesWidgetState();
}

class _MessagesWidgetState extends State<MessagesWidget> {
  late MessagesModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  String? _projectId;
  String? _projectName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MessagesModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    _loadProjectData();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  Future<void> _loadProjectData() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUid)
          .get();
      
      if (userDoc.exists) {
        final projectIds = (userDoc.data()?['projectIds'] as List?)?.cast<String>() ?? [];
        if (projectIds.isNotEmpty) {
          final projectDoc = await FirebaseFirestore.instance
              .collection('projects')
              .doc(projectIds.first)
              .get();
          
          setState(() {
            _projectId = projectIds.first;
            _projectName = projectDoc.data()?['name'] ?? 'Project';
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading project: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    if (_model.textController == null || _model.textController!.text.trim().isEmpty || _projectId == null) {
      return;
    }

    try {
      // Get user data
      final userDocSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUid)
          .get();
      final userData = userDocSnap.data() ?? {};
      final userName = userData['display_name'] as String? ?? 'Unknown User';
      final userRole = userData['role'] as String? ?? 'client';

      // Send message
      await FirebaseFirestore.instance
          .collection('projects')
          .doc(_projectId)
          .collection('messages')
          .add({
        'senderId': currentUserUid,
        'senderName': userName,
        'senderRole': userRole,
        'text': _model.textController!.text.trim(),
        'readBy': [currentUserUid],
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Clear input
      _model.textController?.clear();

      // Scroll to bottom
      Future.delayed(Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending message: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return DateFormat('h:mm a').format(date);
    } else if (difference.inDays == 1) {
      return 'Yesterday ${DateFormat('h:mm a').format(date)}';
    } else if (difference.inDays < 7) {
      return DateFormat('EEE h:mm a').format(date);
    } else {
      return DateFormat('MMM d, h:mm a').format(date);
    }
  }

  Widget _buildMessageBubble(Map<String, dynamic> messageData, bool isSentByMe) {
    final text = messageData['text'] ?? '';
    final senderName = messageData['senderName'] ?? 'Unknown';
    final timestamp = messageData['createdAt'] as Timestamp?;

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        isSentByMe ? 60.0 : 16.0,
        8.0,
        isSentByMe ? 16.0 : 60.0,
        8.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isSentByMe)
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 0.0, 4.0),
              child: Text(
                senderName,
                style: FlutterFlowTheme.of(context).labelSmall.override(
                      font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      color: Color(0xFF8B8680),
                      fontSize: 11.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              color: isSentByMe ? Color(0xFFB8956A) : Color(0xFFD4C4B0),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isSentByMe ? 18.0 : 4.0),
                topRight: Radius.circular(isSentByMe ? 4.0 : 18.0),
                bottomLeft: Radius.circular(18.0),
                bottomRight: Radius.circular(18.0),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                text,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(),
                      color: isSentByMe ? Colors.white : Color(0xFF2C2C2C),
                      fontSize: 14.0,
                      letterSpacing: 0.0,
                    ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(12.0, 4.0, 12.0, 0.0),
            child: Text(
              _formatTimestamp(timestamp),
              style: FlutterFlowTheme.of(context).labelSmall.override(
                    font: GoogleFonts.inter(),
                    color: Color(0xFF8B8680),
                    fontSize: 10.0,
                    letterSpacing: 0.0,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _model.dispose();
    _scrollController.dispose();

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

    if (_projectId == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text('Messages'),
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
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FlutterFlowIconButton(
                borderColor: Colors.transparent,
                borderRadius: 20.0,
                borderWidth: 1.0,
                buttonSize: 40.0,
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: Color(0xFF2C2C2C),
                  size: 24.0,
                ),
                onPressed: () {
                  context.pop();
                },
              ),
              Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Project Messages',
                    style: FlutterFlowTheme.of(context).titleMedium.override(
                          font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                          color: Color(0xFF2C2C2C),
                          fontSize: 17.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    _projectName ?? 'Project',
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          font: GoogleFonts.inter(),
                          color: Color(0xFF8B8680),
                          fontSize: 12.0,
                          letterSpacing: 0.0,
                        ),
                  ),
                ],
              ),
            ].divide(SizedBox(width: 12.0)),
          ),
          actions: [],
          centerTitle: false,
          elevation: 0.0,
        ),
        body: Column(
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
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('projects')
                    .doc(_projectId)
                    .collection('messages')
                    .orderBy('createdAt', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB8956A)),
                      ),
                    );
                  }

                  final messages = snapshot.data!.docs;

                  if (messages.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 64.0,
                              color: Color(0xFFD4C4B0),
                            ),
                            SizedBox(height: 16.0),
                            Text(
                              'No messages yet',
                              style: FlutterFlowTheme.of(context).titleMedium.override(
                                    font: GoogleFonts.interTight(),
                                    color: Color(0xFF8B8680),
                                    letterSpacing: 0.0,
                                  ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'Start a conversation with your builder',
                              style: FlutterFlowTheme.of(context).bodySmall.override(
                                    font: GoogleFonts.inter(),
                                    color: Color(0xFF8B8680),
                                    letterSpacing: 0.0,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Auto-scroll to bottom when new messages arrive
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  });

                  // Mark unread messages as read
                  for (final doc in messages) {
                    final data = doc.data() as Map<String, dynamic>;
                    final readBy = List<String>.from(data['readBy'] ?? []);
                    if (!readBy.contains(currentUserUid)) {
                      doc.reference.update({
                        'readBy': FieldValue.arrayUnion([currentUserUid]),
                      });
                    }
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.fromLTRB(0, 16.0, 0, 16.0),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final messageDoc = messages[index];
                      final messageData = messageDoc.data() as Map<String, dynamic>;
                      final senderId = messageData['senderId'] ?? '';
                      final isSentByMe = senderId == currentUserUid;
                      final timestamp = messageData['createdAt'] as Timestamp?;

                      // Date separator logic
                      Widget? dateSeparator;
                      if (timestamp != null) {
                        final messageDate = timestamp.toDate();
                        bool showSeparator = false;

                        if (index == 0) {
                          showSeparator = true;
                        } else {
                          final prevData = messages[index - 1].data() as Map<String, dynamic>;
                          final prevTimestamp = prevData['createdAt'] as Timestamp?;
                          if (prevTimestamp != null) {
                            final prevDate = prevTimestamp.toDate();
                            if (messageDate.day != prevDate.day ||
                                messageDate.month != prevDate.month ||
                                messageDate.year != prevDate.year) {
                              showSeparator = true;
                            }
                          }
                        }

                        if (showSeparator) {
                          final now = DateTime.now();
                          final today = DateTime(now.year, now.month, now.day);
                          final msgDay = DateTime(messageDate.year, messageDate.month, messageDate.day);
                          String label;
                          if (msgDay == today) {
                            label = 'Today';
                          } else if (msgDay == today.subtract(Duration(days: 1))) {
                            label = 'Yesterday';
                          } else {
                            label = DateFormat('EEEE, MMM d').format(messageDate);
                          }

                          dateSeparator = Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Row(
                              children: [
                                Expanded(child: Divider(color: Color(0xFFEDE8E2), thickness: 1.0)),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                                  child: Text(
                                    label,
                                    style: FlutterFlowTheme.of(context).labelSmall.override(
                                          font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                          color: Color(0xFF8B8680),
                                          fontSize: 10.0,
                                          letterSpacing: 0.5,
                                        ),
                                  ),
                                ),
                                Expanded(child: Divider(color: Color(0xFFEDE8E2), thickness: 1.0)),
                              ],
                            ),
                          );
                        }
                      }

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (dateSeparator != null) dateSeparator,
                          _buildMessageBubble(messageData, isSentByMe),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8.0,
                    color: Color(0x0D000000),
                    offset: Offset(0.0, -2.0),
                  )
                ],
              ),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFF5F0EA),
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 8.0),
                          child: TextFormField(
                            controller: _model.textController,
                            focusNode: _model.textFieldFocusNode,
                            autofocus: false,
                            obscureText: false,
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.inter(),
                                    color: Color(0xFF8B8680),
                                    fontSize: 14.0,
                                    letterSpacing: 0.0,
                                  ),
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.inter(),
                                  color: Color(0xFF2C2C2C),
                                  fontSize: 14.0,
                                  letterSpacing: 0.0,
                                ),
                            maxLines: 5,
                            minLines: 1,
                            keyboardType: TextInputType.multiline,
                            validator: _model.textControllerValidator.asValidator(context),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.0),
                    Container(
                      width: 48.0,
                      height: 48.0,
                      decoration: BoxDecoration(
                        color: Color(0xFFB8956A),
                        shape: BoxShape.circle,
                      ),
                      child: FlutterFlowIconButton(
                        borderRadius: 24.0,
                        buttonSize: 48.0,
                        icon: Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 22.0,
                        ),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
