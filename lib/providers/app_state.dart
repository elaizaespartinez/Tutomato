import 'package:flutter/foundation.dart';

import '../core/constants.dart';
import '../core/utils/date_helpers.dart';
import '../models/models.dart';

/// All of the app's data in one place. Everything here is sample data for now;
/// later it can be saved on the phone or in an online database.
class AppState extends ChangeNotifier {
  AppState._() {
    _seed();
  }
  static final AppState instance = AppState._();

  // ---- Profile ------------------------------------------------------------
  String userName = 'Alex';
  String fullName = 'Alex Rivera';
  String email = 'alex.rivera@university.edu';
  String petName = 'Pip';

  // ---- Progress -----------------------------------------------------------
  int points = 240;
  int level = 3;
  double ripeness = 0.38;
  int streak = 5;
  int bestStreak = 8;
  DateTime? lastStudyDay;

  // ---- Settings -----------------------------------------------------------
  int dailyGoal = 4;
  bool soundOn = true;
  int defaultFocus = 25;
  int defaultBreak = 5;

  // ---- Tasks and records --------------------------------------------------
  final List<Task> tasks = [];
  final List<SessionLog> todaySessions = [];
  final List<int> weekMinutes = List.filled(7, 0); // Monday first
  final List<int> weekSessions = List.filled(7, 0);

  // ---- Pomodori wardrobe --------------------------------------------------
  static const List<WardrobeItem> wardrobe = [
    WardrobeItem('outfit_classic', WardrobeCategory.outfit, 'Classic', 0),
    WardrobeItem('outfit_scholar', WardrobeCategory.outfit, 'Scholar', 80),
    WardrobeItem('outfit_cozy', WardrobeCategory.outfit, 'Cozy', 120),
    WardrobeItem('color_classic', WardrobeCategory.color, 'Classic', 0),
    WardrobeItem('color_golden', WardrobeCategory.color, 'Golden', 80),
    WardrobeItem('color_rosy', WardrobeCategory.color, 'Rosy', 120),
    WardrobeItem('extra_none', WardrobeCategory.extra, 'None', 0),
    WardrobeItem('extra_glasses', WardrobeCategory.extra, 'Glasses', 60),
    WardrobeItem('extra_book', WardrobeCategory.extra, 'Study book', 100),
  ];

  final Set<String> owned = {'outfit_classic', 'color_classic', 'extra_none'};
  final Map<WardrobeCategory, String> equipped = {
    WardrobeCategory.outfit: 'outfit_classic',
    WardrobeCategory.color: 'color_classic',
    WardrobeCategory.extra: 'extra_none',
  };

  // ---- Friends (sample data) ---------------------------------------------
  final List<Friend> friends = const [
    Friend(
      name: 'Maya Chen',
      sharedStreak: 5,
      status: 'Focusing now',
      focusing: true,
    ),
    Friend(
      name: 'Jules Santos',
      sharedStreak: 3,
      status: '75 min today',
      focusing: false,
    ),
  ];

  void _seed() {
    final today = dayOnly(DateTime.now());

    Task task(
        String id,
        String name,
        String subject,
        int dayOffset,
        int sessions,
        int sessionsDone, {
          bool done = false,
        }) {
      return Task(
        id: id,
        name: name,
        subject: subject,
        due: today.add(Duration(days: dayOffset)),
        sessions: sessions,
        sessionsDone: sessionsDone,
        done: done,
      );
    }

    tasks.addAll([
      task('t1', 'Cell division review', 'Biology', 0, 2, 0),
      task('t2', 'Practice derivatives', 'Mathematics', 0, 3, 1),
      task('t3', 'Read Chapter 4', 'Literature', 1, 1, 0),
      task('t4', 'Essay outline', 'Literature', -1, 2, 2, done: true),
      task('t5', 'Lab report', 'Chemistry', -2, 2, 2, done: true),
    ]);

    todaySessions.addAll([
      SessionLog(
        subject: 'Biology',
        minutes: 25,
        at: DateTime(today.year, today.month, today.day, 9, 0),
      ),
      SessionLog(
        subject: 'Mathematics',
        minutes: 25,
        at: DateTime(today.year, today.month, today.day, 10, 15),
      ),
    ]);

    // Sample numbers for earlier days this week; today matches the list above.
    const earlier = [75, 100, 150, 60, 40, 90, 30];
    final todayIndex = DateTime.now().weekday - 1;
    for (var i = 0; i < todayIndex; i++) {
      weekMinutes[i] = earlier[i];
      weekSessions[i] = earlier[i] ~/ 25;
    }
    weekMinutes[todayIndex] = 50;
    weekSessions[todayIndex] = 2;
    lastStudyDay = today;
  }

  // ---- Task helpers -------------------------------------------------------
  /// Not finished yet, earliest due date first.
  List<Task> get todo =>
      tasks.where((t) => !t.done).toList()
        ..sort((a, b) => a.due.compareTo(b.due));
  List<Task> get dueToday =>
      todo.where((t) => daysFromToday(t.due) <= 0).toList();
  List<Task> get comingUp =>
      todo.where((t) => daysFromToday(t.due) > 0).toList();
  List<Task> get completed => tasks.where((t) => t.done).toList();
  int get todayMinutes =>
      todaySessions.fold<int>(0, (sum, s) => sum + s.minutes);

  Task? taskById(String id) {
    for (final t in tasks) {
      if (t.id == id) return t;
    }
    return null;
  }

  void addTask({
    required String name,
    required String subject,
    required DateTime due,
    required int sessions,
  }) {
    tasks.add(
      Task(
        id: 't${DateTime.now().microsecondsSinceEpoch}',
        name: name,
        subject: subject,
        due: dayOnly(due),
        sessions: sessions,
      ),
    );
    notifyListeners();
  }

  void setTaskDone(String id, bool value) {
    final t = taskById(id);
    if (t == null) return;
    t.done = value;
    notifyListeners();
  }

  void toggleTask(String id) {
    final t = taskById(id);
    if (t != null) setTaskDone(id, !t.done);
  }

  void removeTask(String id) {
    tasks.removeWhere((t) => t.id == id);
    // call whatever toggleTask() calls to save, if you persist tasks
    notifyListeners();
  }

  /// Change any plain field, then tell the screens:
  /// `app.update(() => app.dailyGoal = 5);`
  void update(VoidCallback change) {
    change();
    notifyListeners();
  }

  // ---- Finished session ---------------------------------------------------
  void recordSession({Task? task, required int minutes}) {
    final now = DateTime.now();
    todaySessions.add(
      SessionLog(
        subject: task?.subject ?? 'Free focus',
        minutes: minutes,
        at: now,
      ),
    );
    final day = now.weekday - 1;
    weekMinutes[day] += minutes;
    weekSessions[day] += 1;
    if (task != null) task.sessionsDone += 1;

    // Streak: first session of a new day.
    final today = dayOnly(now);
    final last = lastStudyDay;
    if (last == null || !sameDay(last, today)) {
      streak = (last != null && daysFromToday(last) == -1) ? streak + 1 : 1;
      if (streak > bestStreak) bestStreak = streak;
      lastStudyDay = today;
    }

    // Rewards.
    points += kPointsPerSession;
    ripeness += kRipenessPerSession;
    while (ripeness >= 1) {
      ripeness -= 1;
      level += 1;
    }
    notifyListeners();
  }

  // ---- Wardrobe helpers ---------------------------------------------------
  List<WardrobeItem> itemsOf(WardrobeCategory c) =>
      wardrobe.where((i) => i.category == c).toList();

  bool isOwned(WardrobeItem i) => owned.contains(i.id);
  bool isEquipped(WardrobeItem i) => equipped[i.category] == i.id;

  /// "scholar", "golden", "glasses"...
  String equippedKey(WardrobeCategory c) {
    final id = equipped[c]!;
    return id.substring(id.indexOf('_') + 1);
  }

  /// Buys (if needed) and equips. Returns a message to show, or null.
  String? choose(WardrobeItem item) {
    if (isEquipped(item)) return null;
    if (!isOwned(item)) {
      if (points < item.cost) {
        return 'Not enough Study Points yet. Finish a session to earn $kPointsPerSession.';
      }
      points -= item.cost;
      owned.add(item.id);
      equipped[item.category] = item.id;
      notifyListeners();
      return 'Bought ${item.name}!';
    }
    equipped[item.category] = item.id;
    notifyListeners();
    return '${item.name} equipped.';
  }
}
