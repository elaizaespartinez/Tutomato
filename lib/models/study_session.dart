import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutomato/models/converters.dart';

enum SessionStatus {
  /// Timer is running (or the app was closed mid-session, see failStaleSessions).
  inProgress,

  /// Finished without leaving the app: counts for points, streak, records.
  completed,

  /// Lock-in broken: the user left the app.
  broken,

  /// The user pressed "End session".
  cancelled;

  static SessionStatus fromName(String? name) => SessionStatus.values
      .firstWhere((s) => s.name == name, orElse: () => SessionStatus.broken);
}

/// One focus round: users/{uid}/sessions/{id}. Breaks are not stored.
class StudySession {
  const StudySession({
    required this.id,
    required this.taskId,
    required this.taskTitle,
    required this.subject,
    required this.plannedMinutes,
    required this.round,
    required this.totalRounds,
    required this.status,
    required this.startedAt,
    required this.pointsEarned,
    this.endedAt,
  });

  final String id;
  final String? taskId;
  final String taskTitle;
  final String? subject;
  final int plannedMinutes;
  final int round;
  final int totalRounds;
  final SessionStatus status;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int pointsEarned;

  bool get isCompleted => status == SessionStatus.completed;

  factory StudySession.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const <String, dynamic>{};
    return StudySession(
      id: doc.id,
      taskId: readStringOrNull(d['taskId']),
      taskTitle: readString(d['taskTitle'], 'Free study'),
      subject: readStringOrNull(d['subject']),
      plannedMinutes: readInt(d['plannedMinutes']),
      round: readInt(d['round'], 1),
      totalRounds: readInt(d['totalRounds'], 1),
      status: SessionStatus.fromName(readStringOrNull(d['status'])),
      startedAt: readDate(d['startedAt']) ?? DateTime.now(),
      endedAt: readDate(d['endedAt']),
      pointsEarned: readInt(d['pointsEarned']),
    );
  }
}
