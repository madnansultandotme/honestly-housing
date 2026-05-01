import 'dart:async';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class BrandingStruct extends FFFirebaseStruct {
  BrandingStruct({
    String? logoUrl,
    String? primaryColor,
    String? accentColor,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _logoUrl = logoUrl,
        _primaryColor = primaryColor,
        _accentColor = accentColor,
        super(firestoreUtilData);

  // "logoUrl" field.
  String? _logoUrl;
  String get logoUrl => _logoUrl ?? '';
  set logoUrl(String? val) => _logoUrl = val;
  bool hasLogoUrl() => _logoUrl != null;

  // "primaryColor" field.
  String? _primaryColor;
  String get primaryColor => _primaryColor ?? '';
  set primaryColor(String? val) => _primaryColor = val;
  bool hasPrimaryColor() => _primaryColor != null;

  // "accentColor" field.
  String? _accentColor;
  String get accentColor => _accentColor ?? '';
  set accentColor(String? val) => _accentColor = val;
  bool hasAccentColor() => _accentColor != null;

  static BrandingStruct fromMap(Map<String, dynamic> data) => BrandingStruct(
        logoUrl: data['logoUrl'] as String?,
        primaryColor: data['primaryColor'] as String?,
        accentColor: data['accentColor'] as String?,
      );

  static BrandingStruct? maybeFromMap(dynamic data) =>
      data is Map ? BrandingStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'logoUrl': _logoUrl,
        'primaryColor': _primaryColor,
        'accentColor': _accentColor,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => toMap();

  @override
  String serialize() => json.encode(toSerializableMap());

  @override
  bool operator ==(Object other) {
    return other is BrandingStruct &&
        logoUrl == other.logoUrl &&
        primaryColor == other.primaryColor &&
        accentColor == other.accentColor;
  }

  @override
  int get hashCode =>
      const ListEquality().hash([logoUrl, primaryColor, accentColor]);
}

BrandingStruct createBrandingStruct({
  String? logoUrl,
  String? primaryColor,
  String? accentColor,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    BrandingStruct(
      logoUrl: logoUrl,
      primaryColor: primaryColor,
      accentColor: accentColor,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

BrandingStruct? updateBrandingStruct(
  BrandingStruct? branding, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    branding
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addBrandingStructData(
  Map<String, dynamic> firestoreData,
  BrandingStruct? branding,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (branding == null) {
    return;
  }
  if (branding.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && branding.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final brandingData = getBrandingFirestoreData(branding, forFieldValue);
  final nestedData = brandingData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = branding.firestoreUtilData.create || clearFields;
  firestoreData.addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getBrandingFirestoreData(
  BrandingStruct? branding, [
  bool forFieldValue = false,
]) {
  if (branding == null) {
    return {};
  }
  final firestoreData = mapToFirestore(branding.toMap());

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getBrandingListFirestoreData(
  List<BrandingStruct>? brandings,
) =>
    brandings?.map((e) => getBrandingFirestoreData(e, true)).toList() ?? [];
