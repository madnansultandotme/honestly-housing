import 'dart:async';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class NotificationPreferencesStruct extends FFFirebaseStruct {
  NotificationPreferencesStruct({
    bool? email,
    bool? push,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _email = email,
        _push = push,
        super(firestoreUtilData);

  // "email" field.
  bool? _email;
  bool get email => _email ?? true;
  set email(bool? val) => _email = val;
  bool hasEmail() => _email != null;

  // "push" field.
  bool? _push;
  bool get push => _push ?? true;
  set push(bool? val) => _push = val;
  bool hasPush() => _push != null;

  static NotificationPreferencesStruct fromMap(Map<String, dynamic> data) =>
      NotificationPreferencesStruct(
        email: data['email'] as bool?,
        push: data['push'] as bool?,
      );

  static NotificationPreferencesStruct? maybeFromMap(dynamic data) =>
      data is Map ? NotificationPreferencesStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'email': _email,
        'push': _push,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => toMap();

  @override
  String serialize() => json.encode(toSerializableMap());

  @override
  bool operator ==(Object other) {
    return other is NotificationPreferencesStruct &&
        email == other.email &&
        push == other.push;
  }

  @override
  int get hashCode => const ListEquality().hash([email, push]);
}

NotificationPreferencesStruct createNotificationPreferencesStruct({
  bool? email,
  bool? push,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    NotificationPreferencesStruct(
      email: email,
      push: push,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

NotificationPreferencesStruct? updateNotificationPreferencesStruct(
  NotificationPreferencesStruct? notificationPreferences, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    notificationPreferences
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addNotificationPreferencesStructData(
  Map<String, dynamic> firestoreData,
  NotificationPreferencesStruct? notificationPreferences,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (notificationPreferences == null) {
    return;
  }
  if (notificationPreferences.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && notificationPreferences.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final notificationPreferencesData =
      getNotificationPreferencesFirestoreData(notificationPreferences, forFieldValue);
  final nestedData =
      notificationPreferencesData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = notificationPreferences.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getNotificationPreferencesFirestoreData(
  NotificationPreferencesStruct? notificationPreferences, [
  bool forFieldValue = false,
]) {
  if (notificationPreferences == null) {
    return {};
  }
  final firestoreData = mapToFirestore(notificationPreferences.toMap());

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getNotificationPreferencesListFirestoreData(
  List<NotificationPreferencesStruct>? notificationPreferencess,
) =>
    notificationPreferencess
        ?.map((e) => getNotificationPreferencesFirestoreData(e, true))
        .toList() ??
    [];
