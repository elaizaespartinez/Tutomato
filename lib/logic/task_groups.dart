import 'package:tutomato/models/study_task.dart';

/// Splits the task list the way the To Learn screen does:
///   chips:    "To do · 3"   "Today · 2"   "Done · 2"
///   sections: "Today" and "Coming up"
class TaskGroups {
  const TaskGroups({
    required this.todo,
    required this.today,
    required this.upcoming,
    required this.done,
  });

  /// Every task that isn't done (the "To do" chip).
  final List<StudyTask> todo;

  /// Not done and due today or earlier (overdue tasks stay visible here).
  final List<StudyTask> today;

  /// Not done and due after today ("Coming up").
  final List<StudyTask> upcoming;

  /// Completed tasks ("2 completed tasks").
  final List<StudyTask> done;

  factory TaskGroups.from(List<StudyTask> tasks, String today) {
    int byDue(StudyTask a, StudyTask b) {
      final c = a.dueDay.compareTo(b.dueDay);
      return c != 0 ? c : a.createdAt.compareTo(b.createdAt);
    }

    final todo = tasks.where((t) => !t.isDone).toList()..sort(byDue);
    final done = tasks.where((t) => t.isDone).toList()
      ..sort((a, b) => (b.doneAt ?? b.createdAt).compareTo(a.doneAt ?? a.createdAt));
    return TaskGroups(
      todo: todo,
      today: todo.where((t) => t.dueDay.compareTo(today) <= 0).toList(),
      upcoming: todo.where((t) => t.dueDay.compareTo(today) > 0).toList(),
      done: done,
    );
  }

  static const empty = TaskGroups(todo: [], today: [], upcoming: [], done: []);
}
