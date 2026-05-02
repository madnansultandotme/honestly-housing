import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/structs/index.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class UsersRecord extends FirestoreRecord {
  UsersRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "displayName" field.
  String? _displayName;
  String get displayName => _displayName ?? '';
  bool hasDisplayName() => _displayName != null;

  // "role" field.
  String? _role;
  String get role => _role ?? '';
  bool hasRole() => _role != null;

  // "builderOrgId" field.
  String? _builderOrgId;
  String get builderOrgId => _builderOrgId ?? '';
  bool hasBuilderOrgId() => _builderOrgId != null;

  // "projectIds" field.
  List<String>? _projectIds;
  List<String> get projectIds => _projectIds ?? const [];
  bool hasProjectIds() => _projectIds != null;

  // "phone" field.
  String? _phone;
  String get phone => _phone ?? '';
  bool hasPhone() => _phone != null;

  // "photoUrl" field.
  String? _photoUrl;
  String get photoUrl => _photoUrl ?? '';
  bool hasPhotoUrl() => _photoUrl != null;

  // "createdAt" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "updatedAt" field.
  DateTime? _updatedAt;
  DateTime? get updatedAt => _updatedAt;
  bool hasUpdatedAt() => _updatedAt != null;

  // "lastLoginAt" field.
  DateTime? _lastLoginAt;
  DateTime? get lastLoginAt => _lastLoginAt;
  bool hasLastLoginAt() => _lastLoginAt != null;

  // "notificationPreferences" field.
  NotificationPreferencesStruct? _notificationPreferences;
  NotificationPreferencesStruct get notificationPreferences =>
      _notificationPreferences ?? NotificationPreferencesStruct();
  bool hasNotificationPreferences() => _notificationPreferences != null;

  void _initializeFields() {
    _uid = snapshotData['uid'] as String?;
    _email = snapshotData['email'] as String?;
    _displayName = snapshotData['displayName'] as String?;
    _role = snapshotData['role'] as String?;
    _builderOrgId = snapshotData['builderOrgId'] as String?;
    _projectIds = getDataList(snapshotData['projectIds']);
    _phone = snapshotData['phone'] as String?;
    _photoUrl = snapshotData['photoUrl'] as String?;
    _createdAt = snapshotData['createdAt'] as DateTime?;
    _updatedAt = snapshotData['updatedAt'] as DateTime?;
    _lastLoginAt = snapshotData['lastLoginAt'] as DateTime?;
    _notificationPreferences = NotificationPreferencesStruct.maybeFromMap(
        snapshotData['notificationPreferences']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('users');

  static Stream<UsersRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => UsersRecord.fromSnapshot(s));

  static Future<UsersRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => UsersRecord.fromSnapshot(s));

  static UsersRecord fromSnapshot(DocumentSnapshot snapshot) => UsersRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static UsersRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      UsersRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'UsersRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is UsersRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createUsersRecordData({
  String? uid,
  String? email,
  String? displayName,
  String? role,
  String? builderOrgId,
  String? phone,
  String? photoUrl,
  DateTime? createdAt,
  DateTime? updatedAt,
  DateTime? lastLoginAt,
  NotificationPreferencesStruct? notificationPreferences,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role,
      'builderOrgId': builderOrgId,
      'phone': phone,
      'photoUrl': photoUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'lastLoginAt': lastLoginAt,
      'notificationPreferences': NotificationPreferencesStruct().toMap(),
    }.withoutNulls,
  );

  // Handle nested data for "notificationPreferences" field.
  addNotificationPreferencesStructData(
      firestoreData, notificationPreferences, 'notificationPreferences');

  return firestoreData;
}

class UsersRecordDocumentEquality implements Equality<UsersRecord> {
  const UsersRecordDocumentEquality();

  @override
  bool equals(UsersRecord? e1, UsersRecord? e2) {
    const listEquality = ListEquality();
    return e1?.uid == e2?.uid &&
        e1?.email == e2?.email &&
        e1?.displayName == e2?.displayName &&
        e1?.role == e2?.role &&
        e1?.builderOrgId == e2?.builderOrgId &&
        listEquality.equals(e1?.projectIds, e2?.projectIds) &&
        e1?.phone == e2?.phone &&
        e1?.photoUrl == e2?.photoUrl &&
        e1?.createdAt == e2?.createdAt &&
        e1?.updatedAt == e2?.updatedAt &&
        e1?.lastLoginAt == e2?.lastLoginAt &&
        e1?.notificationPreferences == e2?.notificationPreferences;
  }

  @override
  int hash(UsersRecord? e) => const ListEquality().hash([
        e?.uid,
        e?.email,
        e?.displayName,
        e?.role,
        e?.builderOrgId,
        e?.projectIds,
        e?.phone,
        e?.photoUrl,
        e?.createdAt,
        e?.updatedAt,
        e?.lastLoginAt,
        e?.notificationPreferences
      ]);

  @override
  bool isValidKey(Object? o) => o is UsersRecord;
}
