import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutomato/models/converters.dart';

/// A "To Learn" item: users/{uid}/tasks/{id}.
class StudyTask {
  const StudyTask({
    required this.id,
    required this.title,
    required this.subject,
    required this.plannedSessions,
    required this.completedSessions,
    required this.dueDay,
    required this.isDone,
    required this.createdAt,
    this.doneAt,
  });

  final String id;
  final String title;
  final String subject;

  /// "How many focus sessions?" (one session = 25 minutes of focus).
  final int plannedSessions;

  /// Completed focus sessions linked to this task ("1 / 3 sessions").
  final int completedSessions;

  /// Due date as "yyyy-MM-dd".
  final String dueDay;

  final bool isDone;
  final DateTime createdAt;
  final DateTime? doneAt;

  factory StudyTask.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const <String, dynamic>{};
    return StudyTask(
      id: doc.id,
      title: readString(d['title']),
      subject: readString(d['subject'], 'Other'),
      plannedSessions: readInt(d['plannedSessions'], 1),
      completedSessions: readInt(d['completedSessions']),
      dueDay: readString(d['dueDay']),
      isDone: readBool(d['isDone']),
      createdAt: readDate(d['createdAt']) ?? DateTime.now(),
      doneAt: readDate(d['doneAt']),
    );
  }
}
