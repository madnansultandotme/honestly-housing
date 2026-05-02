import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Widget that displays recent messages for the client
class RecentMessagesWidget extends StatelessWidget {
  final String projectId;

  const RecentMessagesWidget({
    super.key,
    required this.projectId,
  });

  String _formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      final hour = timestamp.hour;
      final minute = timestamp.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('projects')
          .doc(projectId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(3)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Error loading messages',
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    font: GoogleFonts.inter(),
                    color: Color(0xFFE05C5C),
                    letterSpacing: 0.0,
                  ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: EdgeInsets.all(20.0),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB8956A)),
              ),
            ),
          );
        }

        final messages = snapshot.data?.docs ?? [];

        if (messages.isEmpty) {
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.message_outlined,
                    size: 48.0,
                    color: Color(0xFFD4C4B0),
                  ),
                  SizedBox(height: 12.0),
                  Text(
                    'No messages yet',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.inter(fontWeight: FontWeight.w600),
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
          children: messages.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final senderName = data['senderName'] as String? ?? 'Unknown';
            final messageText = data['text'] as String? ?? '';
            final timestamp = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
            final senderId = data['senderId'] as String? ?? '';
            final senderPhotoUrl = data['senderPhotoUrl'] as String?;

            return InkWell(
              onTap: () {
                // Navigate to messages page
                context.pushNamed(
                  'Messages',
                  queryParameters: {
                    'projectId': projectId,
                  }.withoutNulls,
                );
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFFF5EFE8),
                      width: 1.0,
                    ),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          color: Color(0xFFD4C4B0),
                          shape: BoxShape.circle,
                        ),
                        child: senderPhotoUrl != null && senderPhotoUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(50.0),
                                child: Image.network(
                                  senderPhotoUrl,
                                  width: 40.0,
                                  height: 40.0,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Text(
                                        senderName.isNotEmpty
                                            ? senderName[0].toUpperCase()
                                            : '?',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight: FontWeight.bold,
                                              ),
                                              color: Colors.white,
                                              fontSize: 16.0,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Center(
                                child: Text(
                                  senderName.isNotEmpty
                                      ? senderName[0].toUpperCase()
                                      : '?',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        color: Colors.white,
                                        fontSize: 16.0,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ),
                      ),
                      SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  senderName,
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
                                Text(
                                  _formatMessageTime(timestamp),
                                  style: FlutterFlowTheme.of(context)
                                      .bodySmall
                                      .override(
                                        font: GoogleFonts.inter(),
                                        color: Color(0xFF8B8680),
                                        fontSize: 11.0,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4.0),
                            Text(
                              messageText,
                              style: FlutterFlowTheme.of(context)
                                  .bodySmall
                                  .override(
                                    font: GoogleFonts.inter(),
                                    color: Color(0xFF5C5450),
                                    fontSize: 13.0,
                                    letterSpacing: 0.0,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
