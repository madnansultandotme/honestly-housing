import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ChangeRequestsRecord extends FirestoreRecord {
  ChangeRequestsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {}

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('changeRequests')
          : FirebaseFirestore.instance.collectionGroup('changeRequests');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('changeRequests').doc(id);

  static Stream<ChangeRequestsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ChangeRequestsRecord.fromSnapshot(s));

  static Future<ChangeRequestsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ChangeRequestsRecord.fromSnapshot(s));

  static ChangeRequestsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ChangeRequestsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ChangeRequestsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ChangeRequestsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ChangeRequestsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ChangeRequestsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createChangeRequestsRecordData() {
  final firestoreData = mapToFirestore(
    <String, dynamic>{}.withoutNulls,
  );

  return firestoreData;
}

class ChangeRequestsRecordDocumentEquality
    implements Equality<ChangeRequestsRecord> {
  const ChangeRequestsRecordDocumentEquality();

  @override
  bool equals(ChangeRequestsRecord? e1, ChangeRequestsRecord? e2) {
    return e1?.reference == e2?.reference;
  }

  @override
  int hash(ChangeRequestsRecord? e) => const ListEquality().hash([]);

  @override
  bool isValidKey(Object? o) => o is ChangeRequestsRecord;
}
