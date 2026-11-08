import 'package:cloud_firestore/cloud_firestore.dart';

// Tolerant readers for Firestore data: a missing or wrong-typed field falls
// back to a default instead of crashing the UI.

int readInt(Object? v, [int fallback = 0]) => v is num ? v.toInt() : fallback;

bool readBool(Object? v, [bool fallback = false]) => v is bool ? v : fallback;

String readString(Object? v, [String fallback = '']) =>
    v is String ? v : fallback;

String? readStringOrNull(Object? v) => v is String ? v : null;

DateTime? readDate(Object? v) => v is Timestamp ? v.toDate() : null;

Timestamp ts(DateTime d) => Timestamp.fromDate(d);
