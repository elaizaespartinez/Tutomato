import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutomato/core/app_exception.dart';
import 'package:tutomato/core/constants.dart';
import 'package:tutomato/core/day_keys.dart';
import 'package:tutomato/core/firestore_helpers.dart';
import 'package:tutomato/core/firestore_paths.dart';
import 'package:tutomato/core/validators.dart';
import 'package:tutomato/models/study_task.dart';

/// The "To Learn" list: users/{uid}/tasks/{taskId}.
class TaskRepository {
  TaskRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _tasks(String uid) => _db
      .collection(FirestorePaths.users)
      .doc(uid)
      .collection(FirestorePaths.tasks);

  /// All tasks (done and not done), soonest due first. Group them for the
  /// screen with `TaskGroups.from(...)`.
  Stream<List<StudyTask>> watchTasks(String uid) =>
      _tasks(uid).orderBy('dueDay').snapshots().map(
            (snap) => snap.docs.map(StudyTask.fromDoc).toList(),
          );

  Future<String> addTask(
    String uid, {
    required String title,
    required String subject,
    required int plannedSessions,
    required DateTime dueDate,
  }) async {
    _validate(title, plannedSessions);
    final ref = _tasks(uid).doc();
    await ref.set({
      'title': title.trim(),
      'subject': subject,
      'plannedSessions': plannedSessions,
      'completedSessions': 0,
      'dueDay': dayKey(dueDate),
      'isDone': false,
      'createdAt': Timestamp.now(),
      'doneAt': null,
    }).offlineSafe();
    return ref.id;
  }

  Future<void> updateTask(
    String uid,
    String taskId, {
    required String title,
    required String subject,
    required int plannedSessions,
    required DateTime dueDate,
  }) async {
    _validate(title, plannedSessions);
    await _tasks(uid).doc(taskId).update({
      'title': title.trim(),
      'subject': subject,
      'plannedSessions': plannedSessions,
      'dueDay': dayKey(dueDate),
    }).offlineSafe();
  }

  /// The checkbox on the To Learn list and on "Session complete".
  Future<void> setDone(String uid, String taskId, bool done) =>
      _tasks(uid).doc(taskId).update({
        'isDone': done,
        'doneAt': done ? Timestamp.now() : null,
      }).offlineSafe();

  Future<void> deleteTask(String uid, String taskId) =>
      _tasks(uid).doc(taskId).delete().offlineSafe();

  void _validate(String title, int sessions) {
    final error = Validators.taskTitle(title);
    if (error != null) throw AppException(error);
    if (sessions < AppConstants.minTaskSessions ||
        sessions > AppConstants.maxTaskSessions) {
      throw AppException(
        'Plan between ${AppConstants.minTaskSessions} and '
        '${AppConstants.maxTaskSessions} sessions.',
      );
    }
  }
}
