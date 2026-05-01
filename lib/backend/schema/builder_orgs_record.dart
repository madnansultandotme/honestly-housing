import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class BuilderOrgsRecord extends FirestoreRecord {
  BuilderOrgsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  void _initializeFields() {}

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('builderOrgs');

  static Stream<BuilderOrgsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => BuilderOrgsRecord.fromSnapshot(s));

  static Future<BuilderOrgsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => BuilderOrgsRecord.fromSnapshot(s));

  static BuilderOrgsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      BuilderOrgsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static BuilderOrgsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      BuilderOrgsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'BuilderOrgsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is BuilderOrgsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createBuilderOrgsRecordData() {
  final firestoreData = mapToFirestore(
    <String, dynamic>{}.withoutNulls,
  );

  return firestoreData;
}

class BuilderOrgsRecordDocumentEquality implements Equality<BuilderOrgsRecord> {
  const BuilderOrgsRecordDocumentEquality();

  @override
  bool equals(BuilderOrgsRecord? e1, BuilderOrgsRecord? e2) {
    return e1?.reference == e2?.reference;
  }

  @override
  int hash(BuilderOrgsRecord? e) => const ListEquality().hash([]);

  @override
  bool isValidKey(Object? o) => o is BuilderOrgsRecord;
}
