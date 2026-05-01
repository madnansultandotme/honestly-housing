import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'photos_model.dart';
export 'photos_model.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

/// # Photos
///
/// Build project photo gallery for upload and viewing.
///
/// Allow captions and auto-capture timestamps. Query photos collection, write
/// to photos and Firebase Storage on upload. Design on white (#FFFFFF) as
/// grid gallery with upload button in brass accent (#B8956A), soft taupe
/// (#D4C4B0) photo card borders, warm neutral gray (#8B8680) for
/// captions/timestamps. Apply rounded corners and premium spacing.
class PhotosWidget extends StatefulWidget {
  const PhotosWidget({super.key});

  static String routeName = 'Photos';
  static String routePath = '/photos';

  @override
  State<PhotosWidget> createState() => _PhotosWidgetState();
}

class _PhotosWidgetState extends State<PhotosWidget> {
  late PhotosModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  String? _projectId;
  bool _isLoading = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PhotosModel());

    _loadProjectId();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Future<void> _loadProjectId() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUid)
          .get();
      final projectIds =
          (userDoc.data()?['projectIds'] as List?)?.cast<String>() ?? [];
      setState(() {
        _projectId = projectIds.isNotEmpty ? projectIds.first : null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    return DateFormat('MMM d, h:mm a').format(timestamp.toDate());
  }

  Future<String?> _promptForCaption() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add caption'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Optional caption',
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text('Save'),
          ),
        ],
      ),
    );

    return result;
  }

  Future<void> _uploadPhoto() async {
    if (_isUploading || _projectId == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    final caption = await _promptForCaption();

    setState(() {
      _isUploading = true;
    });

    try {
      final bytes = await pickedFile.readAsBytes();
      final fileName = pickedFile.name.isNotEmpty
          ? pickedFile.name
          : 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storagePath =
          'projects/${_projectId!}/photos/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      final storageRef = FirebaseStorage.instance.ref().child(storagePath);

      await storageRef.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final downloadUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('projects')
          .doc(_projectId)
          .collection('photos')
          .add({
        'imageUrl': downloadUrl,
        'caption': caption ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': currentUserUid,
        'storagePath': storagePath,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading photo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _showFullScreenPhoto(String imageUrl, String caption, String timestamp) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: Scaffold(
              backgroundColor: Colors.black.withOpacity(0.95),
              body: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Stack(
                  children: [
                    Center(
                      child: InteractiveViewer(
                        minScale: 0.5,
                        maxScale: 4.0,
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.broken_image_rounded,
                            color: Color(0xFFD4C4B0),
                            size: 64.0,
                          ),
                        ),
                      ),
                    ),
                    // Close button
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 12.0,
                      right: 16.0,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 40.0,
                          height: 40.0,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 22.0,
                          ),
                        ),
                      ),
                    ),
                    // Caption overlay
                    if (caption.isNotEmpty || timestamp.isNotEmpty)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.fromLTRB(
                            24.0,
                            16.0,
                            24.0,
                            MediaQuery.of(context).padding.bottom + 24.0,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (caption.isNotEmpty)
                                Text(
                                  caption,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              if (timestamp.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    timestamp,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
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
          title: Text('Project Photos'),
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
          title: Text(
            'Project Photos',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(
                    fontWeight: FontWeight.bold,
                    fontStyle:
                        FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                  ),
                  color: Color(0xFF2C2825),
                  fontSize: 22.0,
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
                  FlutterFlowIconButton(
                    borderRadius: 12.0,
                    buttonSize: 40.0,
                    icon: Icon(
                      Icons.search_rounded,
                      color: Color(0xFF8B8680),
                      size: 22.0,
                    ),
                    onPressed: () {
                      print('IconButton pressed ...');
                    },
                  ),
                  InkWell(
                    onTap: _isUploading ? null : _uploadPhoto,
                    child: Opacity(
                      opacity: _isUploading ? 0.7 : 1.0,
                      child: Container(
                        height: 40.0,
                        decoration: BoxDecoration(
                          color: Color(0xFFB8956A),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              14.0, 0.0, 14.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add_a_photo_rounded,
                                color: Colors.white,
                                size: 18.0,
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    6.0, 0.0, 6.0, 0.0),
                                child: Text(
                                  _isUploading ? 'Uploading...' : 'Upload',
                                  style: FlutterFlowTheme.of(context)
                                      .labelLarge
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                          fontStyle: FlutterFlowTheme.of(context)
                                              .labelLarge
                                              .fontStyle,
                                        ),
                                        color: Colors.white,
                                        fontSize: 13.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelLarge
                                            .fontStyle,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ].divide(SizedBox(width: 8.0)),
              ),
            ),
          ],
          centerTitle: false,
          elevation: 0.0,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('projects')
              .doc(_projectId)
              .collection('photos')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB8956A)),
                ),
              );
            }

            final photos = snapshot.data!.docs;

            return Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 0.0),
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
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${photos.length} photos',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FontWeight.normal,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      color: Color(0xFF8B8680),
                                      fontSize: 13.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.normal,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                height: 32.0,
                                decoration: BoxDecoration(
                                  color: Color(0xFFF5F0EB),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      10.0, 0.0, 10.0, 0.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.grid_view_rounded,
                                        color: Color(0xFFB8956A),
                                        size: 16.0,
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            4.0, 0.0, 4.0, 0.0),
                                        child: Text(
                                          'Grid',
                                          style: FlutterFlowTheme.of(context)
                                              .labelSmall
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(context)
                                                          .labelSmall
                                                          .fontStyle,
                                                ),
                                                color: Color(0xFFB8956A),
                                                fontSize: 12.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .fontStyle,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ].divide(SizedBox(width: 4.0)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 0.0),
                  child: Container(
                    width: double.infinity,
                    height: 1.0,
                    decoration: BoxDecoration(
                      color: Color(0xFFF0EBE5),
                    ),
                  ),
                ),
                Expanded(
                  child: photos.isEmpty
                      ? Center(
                          child: Text(
                            'No photos yet',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.inter(),
                                  color: Color(0xFF8B8680),
                                  letterSpacing: 0.0,
                                ),
                          ),
                        )
                      : Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 16.0, 16.0, 16.0),
                          child: GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 14.0,
                              mainAxisSpacing: 14.0,
                              childAspectRatio: 0.7,
                            ),
                            itemCount: photos.length,
                            itemBuilder: (context, index) {
                              final doc = photos[index];
                              final data = doc.data() as Map<String, dynamic>;
                              final imageUrl = data['imageUrl'] as String?;
                              final caption = data['caption'] as String? ?? '';
                              final createdAt = data['createdAt'] as Timestamp?;

                              return GestureDetector(
                                onTap: () {
                                  if (imageUrl != null && imageUrl.isNotEmpty) {
                                    _showFullScreenPhoto(
                                      imageUrl,
                                      caption,
                                      _formatTimestamp(createdAt),
                                    );
                                  }
                                },
                                child: ClipRRect(
                                borderRadius: BorderRadius.circular(16.0),
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 8.0,
                                        color: Color(0x1A000000),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          height: 160.0,
                                          child: Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                                child: imageUrl == null ||
                                                        imageUrl.isEmpty
                                                    ? Container(
                                                        color:
                                                            Color(0xFFF5EFE8),
                                                        child: Icon(
                                                          Icons.photo_rounded,
                                                          color:
                                                              Color(0xFFD4C4B0),
                                                          size: 48.0,
                                                        ),
                                                      )
                                                    : Image.network(
                                                        imageUrl,
                                                        width: double.infinity,
                                                        height: 160.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                              ),
                                              Container(
                                                width: double.infinity,
                                                height: 160.0,
                                                decoration: BoxDecoration(
                                                  color: Colors.transparent,
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Align(
                                                    alignment:
                                                        AlignmentDirectional(1.0, -1.0),
                                                    child: Container(
                                                      height: 24.0,
                                                      decoration: BoxDecoration(
                                                        color: Color(0xCC000000),
                                                        borderRadius:
                                                            BorderRadius.circular(6.0),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(6.0, 0.0, 6.0, 0.0),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Icon(
                                                              Icons.schedule_rounded,
                                                              color: Colors.white,
                                                              size: 12.0,
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(3.0, 0.0, 3.0, 0.0),
                                                              child: Text(
                                                                _formatTimestamp(createdAt),
                                                                style: FlutterFlowTheme
                                                                        .of(context)
                                                                    .labelSmall
                                                                    .override(
                                                                      font: GoogleFonts
                                                                          .inter(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        fontStyle:
                                                                            FlutterFlowTheme.of(
                                                                                    context)
                                                                                .labelSmall
                                                                                .fontStyle,
                                                                      ),
                                                                      color: Colors.white,
                                                                      fontSize: 10.0,
                                                                      letterSpacing: 0.0,
                                                                      fontWeight:
                                                                          FontWeight.w500,
                                                                      fontStyle:
                                                                          FlutterFlowTheme.of(
                                                                                  context)
                                                                              .labelSmall
                                                                              .fontStyle,
                                                                    ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsetsDirectional.fromSTEB(
                                              12.0, 10.0, 12.0, 12.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                caption.isNotEmpty
                                                    ? caption
                                                    : 'Project Update',
                                                maxLines: 2,
                                                style: FlutterFlowTheme.of(context)
                                                    .titleSmall
                                                    .override(
                                                      font: GoogleFonts.interTight(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(context)
                                                                .titleSmall
                                                                .fontStyle,
                                                      ),
                                                      color: Color(0xFF2C2825),
                                                      fontSize: 13.0,
                                                      letterSpacing: 0.0,
                                                      fontWeight: FontWeight.w600,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(context)
                                                              .titleSmall
                                                              .fontStyle,
                                                    ),
                                              ),
                                              if (createdAt != null)
                                                Padding(
                                                  padding: EdgeInsetsDirectional.fromSTEB(
                                                      0.0, 4.0, 0.0, 0.0),
                                                  child: Text(
                                                    _formatTimestamp(createdAt),
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
                                                          fontWeight: FlutterFlowTheme.of(context)
                                                              .bodySmall
                                                              .fontWeight,
                                                          fontStyle: FlutterFlowTheme.of(context)
                                                              .bodySmall
                                                              .fontStyle,
                                                        ),
                                                  ),
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
                            },
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

