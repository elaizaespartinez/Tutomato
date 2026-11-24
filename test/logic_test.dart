import 'package:flutter_test/flutter_test.dart';
import 'package:tutomato/core/day_keys.dart';
import 'package:tutomato/core/firestore_paths.dart';
import 'package:tutomato/core/format.dart';
import 'package:tutomato/core/validators.dart';
import 'package:tutomato/logic/records.dart';
import 'package:tutomato/logic/rewards.dart';
import 'package:tutomato/logic/streak.dart';
import 'package:tutomato/logic/task_groups.dart';
import 'package:tutomato/logic/timer_state.dart';
import 'package:tutomato/models/study_session.dart';
import 'package:tutomato/models/study_task.dart';

StudyTask task(String id, String due, {bool done = false, int minute = 0}) => StudyTask(
      id: id,
      title: id,
      subject: 'Biology',
      plannedSessions: 2,
      completedSessions: 0,
      dueDay: due,
      isDone: done,
      createdAt: DateTime(2026, 11, 1, 9, minute),
    );

StudySession session(DateTime at, {int minutes = 25, SessionStatus status = SessionStatus.completed}) =>
    StudySession(
      id: at.toIso8601String(),
      taskId: null,
      taskTitle: 'Test',
      subject: 'Biology',
      plannedMinutes: minutes,
      round: 1,
      totalRounds: 4,
      status: status,
      startedAt: at,
      pointsEarned: 0,
    );

void main() {
  group('day keys', () {
    test('format and parse', () {
      expect(dayKey(DateTime(2026, 11, 5)), '2026-11-05');
      expect(parseDayKey('2026-11-05'), DateTime(2026, 11, 5));
    });

    test('week starts on Monday', () {
      // Sunday 8 Nov 2026 belongs to the week of Monday 2 Nov.
      expect(startOfWeek(DateTime(2026, 11, 8)), DateTime(2026, 11, 2));
      expect(startOfWeek(DateTime(2026, 11, 2)), DateTime(2026, 11, 2));
    });

    test('daysBetween ignores the time of day', () {
      expect(daysBetween(DateTime(2026, 11, 2, 23, 59), DateTime(2026, 11, 3, 0, 1)), 1);
    });

    test('pairId is the same for both friends', () {
      expect(FirestorePaths.pairId('b', 'a'), FirestorePaths.pairId('a', 'b'));
    });
  });

  group('streak', () {
    const none = StreakState(current: 0, best: 0, lastDay: null);

    test('first session starts a streak of 1', () {
      final s = advanceStreak(none, '2026-11-08');
      expect(s.current, 1);
      expect(s.best, 1);
      expect(s.lastDay, '2026-11-08');
    });

    test('second session the same day changes nothing', () {
      final first = advanceStreak(none, '2026-11-08');
      final again = advanceStreak(first, '2026-11-08');
      expect(again.current, 1);
    });

    test('consecutive days extend the streak', () {
      const s = StreakState(current: 4, best: 8, lastDay: '2026-11-07');
      final next = advanceStreak(s, '2026-11-08');
      expect(next.current, 5);
      expect(next.best, 8);
    });

    test('works across month boundaries', () {
      const s = StreakState(current: 2, best: 2, lastDay: '2026-10-31');
      expect(advanceStreak(s, '2026-11-01').current, 3);
    });

    test('a missed day resets to 1 but keeps the best', () {
      const s = StreakState(current: 5, best: 8, lastDay: '2026-11-05');
      final next = advanceStreak(s, '2026-11-08');
      expect(next.current, 1);
      expect(next.best, 8);
    });

    test('best grows with the streak', () {
      const s = StreakState(current: 8, best: 8, lastDay: '2026-11-07');
      expect(advanceStreak(s, '2026-11-08').best, 9);
    });

    test('effectiveStreak shows 0 once a day was missed', () {
      expect(effectiveStreak(current: 5, lastDay: '2026-11-08', today: '2026-11-08'), 5);
      expect(effectiveStreak(current: 5, lastDay: '2026-11-07', today: '2026-11-08'), 5);
      expect(effectiveStreak(current: 5, lastDay: '2026-11-06', today: '2026-11-08'), 0);
      expect(effectiveStreak(current: 0, lastDay: null, today: '2026-11-08'), 0);
    });
  });

  group('rewards', () {
    test('points equal focus minutes (25 min -> +25)', () {
      expect(pointsForFocusMinutes(25), 25);
      expect(pointsForFocusMinutes(50), 50);
      expect(pointsForFocusMinutes(-5), 0);
    });

    test('ripeness matches the design: 38% + 8 = 46%', () {
      final r = applyRipeness(level: 3, ripeness: 38);
      expect(r.level, 3);
      expect(r.ripeness, 46);
      expect(r.leveledUp, false);
    });

    test('ripeness rolls over into the next level', () {
      final r = applyRipeness(level: 3, ripeness: 96);
      expect(r.level, 4);
      expect(r.ripeness, 4);
      expect(r.leveledUp, true);
    });
  });

  group('task groups (To Learn screen)', () {
    test('counts match the design: To do 3, Today 2, Done 2', () {
      final groups = TaskGroups.from([
        task('Cell division review', '2026-11-05'),
        task('Practice derivatives', '2026-11-05', minute: 1),
        task('Read Chapter 4', '2026-11-06'),
        task('Old A', '2026-11-01', done: true),
        task('Old B', '2026-11-02', done: true),
      ], '2026-11-05');

      expect(groups.todo.length, 3);
      expect(groups.today.length, 2);
      expect(groups.upcoming.length, 1);
      expect(groups.done.length, 2);
      expect(groups.upcoming.single.id, 'Read Chapter 4');
    });

    test('overdue tasks stay in Today', () {
      final groups = TaskGroups.from([task('Late', '2026-11-01')], '2026-11-05');
      expect(groups.today.length, 1);
    });
  });

  group('records (Records screen)', () {
    test('sums completed sessions per weekday and ignores broken ones', () {
      final monday = DateTime(2026, 11, 2);
      final stats = buildWeeklyStats(
        [
          session(DateTime(2026, 11, 2, 9)), // Mon 25
          session(DateTime(2026, 11, 2, 10)), // Mon 25
          session(DateTime(2026, 11, 4, 9), minutes: 50), // Wed 50
          session(DateTime(2026, 11, 4, 11), status: SessionStatus.broken),
          session(DateTime(2026, 11, 9, 9)), // next week, ignored
        ],
        weekStart: monday,
        today: DateTime(2026, 11, 4, 15),
      );
      expect(stats.minutesPerDay, [50, 0, 50, 0, 0, 0, 0]);
      expect(stats.totalMinutes, 100);
      expect(stats.sessionsCompleted, 3);
      expect(stats.todaySessions.length, 1);
      expect(stats.maxDayMinutes, 50);
    });
  });

  group('timer config', () {
    test('presets are valid, out-of-range values are rejected', () {
      expect(const TimerConfig(focusMinutes: 25, breakMinutes: 5, rounds: 4).validate(), isNull);
      expect(const TimerConfig(focusMinutes: 0, breakMinutes: 5, rounds: 4).validate(), isNotNull);
      expect(const TimerConfig(focusMinutes: 25, breakMinutes: 5, rounds: 99).validate(), isNotNull);
    });

    test('progress goes from 0 to 1', () {
      final s = TimerState.idle().copyWith(
        total: const Duration(minutes: 25),
        remaining: const Duration(minutes: 25),
      );
      expect(s.progress, 0);
      final half = s.copyWith(remaining: const Duration(minutes: 5));
      expect(half.progress, closeTo(0.8, 0.001));
    });
  });

  group('formatting', () {
    test('clock', () {
      expect(formatClock(const Duration(minutes: 18, seconds: 42)), '18:42');
      expect(formatClock(const Duration(minutes: 5)), '05:00');
      expect(formatClock(const Duration(milliseconds: 100)), '00:01');
      expect(formatClock(Duration.zero), '00:00');
    });

    test('minutes', () {
      expect(formatMinutes(50), '50 min');
      expect(formatMinutes(375), '6h 15m');
      expect(formatMinutes(120), '2h');
    });

    test('sessions label', () {
      expect(sessionsLabel(0, 2), '0 / 2 sessions');
      expect(sessionsLabel(0, 1), '0 / 1 session');
    });

    test('due label', () {
      expect(dueLabel('2026-11-05', '2026-11-05'), 'Today');
      expect(dueLabel('2026-11-06', '2026-11-05'), 'Tomorrow');
      expect(dueLabel('2026-11-01', '2026-11-05'), 'Overdue');
      expect(dueLabel('2026-11-12', '2026-11-05'), 'Thu, Nov 12');
    });

    test('week range', () {
      expect(weekRangeLabel(DateTime(2026, 11, 2)), 'Nov 2–8');
      expect(weekRangeLabel(DateTime(2026, 10, 26)), 'Oct 26 – Nov 1');
    });
  });

  group('validators', () {
    test('password rule from the sign-up screen', () {
      expect(Validators.newPassword('abc12345'), isNull);
      expect(Validators.newPassword('short1'), isNotNull); // < 8
      expect(Validators.newPassword('12345678'), isNotNull); // no letter
      expect(Validators.newPassword('abcdefgh'), isNotNull); // no number
    });

    test('confirm password', () {
      expect(Validators.confirmPassword('abc12345', 'abc12345'), isNull);
      expect(Validators.confirmPassword('abc12345', 'abc12346'), isNotNull);
    });

    test('email and name', () {
      expect(Validators.email('alex.rivera@university.edu'), isNull);
      expect(Validators.email('alex@'), isNotNull);
      expect(Validators.name('  '), isNotNull);
    });
  });
}
