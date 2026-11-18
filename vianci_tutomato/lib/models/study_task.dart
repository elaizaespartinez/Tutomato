class StudyTask {
  static int _nextId = 0;

  StudyTask({
    required this.title,
    required this.subject,
    required this.dueLabel,
    required this.sessionsGoal,
    this.completedSessions = 0,
    this.isDone = false,
    String? id,
  }) : id = id ?? '${DateTime.now().microsecondsSinceEpoch}-${_nextId++}';

  final String id;
  final String title;
  final String subject;
  final String dueLabel;
  final int sessionsGoal;
  final int completedSessions;
  final bool isDone;

  StudyTask copyWith({int? completedSessions, bool? isDone}) {
    return StudyTask(
      id: id,
      title: title,
      subject: subject,
      dueLabel: dueLabel,
      sessionsGoal: sessionsGoal,
      completedSessions: completedSessions ?? this.completedSessions,
      isDone: isDone ?? this.isDone,
    );
  }
}
