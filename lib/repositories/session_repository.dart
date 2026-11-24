import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutomato/core/app_exception.dart';
import 'package:tutomato/core/constants.dart';
import 'package:tutomato/core/day_keys.dart';
import 'package:tutomato/core/firestore_helpers.dart';
import 'package:tutomato/core/firestore_paths.dart';
import 'package:tutomato/logic/rewards.dart';
import 'package:tutomato/logic/streak.dart';
import 'package:tutomato/models/converters.dart';
import 'package:tutomato/models/session_result.dart';
import 'package:tutomato/models/study_session.dart';
import 'package:tutomato/models/user_profile.dart';

/// Focus sessions: users/{uid}/sessions/{id}. This is where points, ripeness,
/// streaks and the "today" counters are awarded, in one batched write, so they
/// can never get out of step with each other.
class SessionRepository {
  SessionRepository(this._db);

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _user(String uid) =>
      _db.collection(FirestorePaths.users).doc(uid);

  DocumentReference<Map<String, dynamic>> _public(String uid) =>
      _db.collection(FirestorePaths.publicProfiles).doc(uid);

  CollectionReference<Map<String, dynamic>> _sessions(String uid) =>
      _user(uid).collection(FirestorePaths.sessions);

  /// Called when a focus round starts. Records it as `inProgress` and marks the
  /// user as "focusing now" for friends. Returns the id immediately; the write
  /// happens in the background so the timer starts instantly, even offline.
  String startFocus({
    required String uid,
    required String? taskId,
    required String taskTitle,
    required String? subject,
    required int plannedMinutes,
    required int round,
    required int totalRounds,
    required DateTime startedAt,
  }) {
    final ref = _sessions(uid).doc();
    final batch = _db.batch();
    batch.set(ref, {
      'taskId': taskId,
      'taskTitle': taskTitle,
      'subject': subject,
      'plannedMinutes': plannedMinutes,
      'round': round,
      'totalRounds': totalRounds,
      'status': SessionStatus.inProgress.name,
      'startedAt': ts(startedAt),
      'endedAt': null,
      'pointsEarned': 0,
    });
    batch.set(
      _public(uid),
      {'focusingUntil': ts(startedAt.add(Duration(minutes: plannedMinutes, seconds: 30)))},
      SetOptions(merge: true),
    );
    runInBackground(batch.commit(), 'start session');
    return ref.id;
  }

  /// The timer reached 00:00 without the user leaving: award everything.
  ///
  /// Awards, in one batch: Study Points, ripeness (+level), daily streak, the
  /// "today" counters, +1 completed session on the linked task, and the
  /// friend-visible stats.
  Future<SessionReward> completeFocus({
    required String uid,
    required String sessionId,
    required int minutes,
    required String? taskId,
    required DateTime now,
  }) async {
    final userSnap = await _user(uid).get();
    if (!userSnap.exists) {
      throw const AppException('Your profile could not be found. Please log in again.');
    }
    final p = UserProfile.fromDoc(userSnap);

    final today = dayKey(now);
    final points = pointsForFocusMinutes(minutes);
    final ripeness = applyRipeness(level: p.level, ripeness: p.ripeness);
    final streak = advanceStreak(
      StreakState(
        current: p.currentStreak,
        best: p.bestStreak,
        lastDay: p.lastActiveDay,
      ),
      today,
    );
    final todayMinutes = p.minutesOn(today) + minutes;
    final todaySessions = p.sessionsOn(today) + 1;

    final batch = _db.batch();

    // merge:true so this still works if the "start" write never reached the
    // server (e.g. the phone was offline when the session began).
    batch.set(
      _sessions(uid).doc(sessionId),
      {
        'status': SessionStatus.completed.name,
        'endedAt': ts(now),
        'pointsEarned': points,
      },
      SetOptions(merge: true),
    );

    batch.update(_user(uid), {
      'points': FieldValue.increment(points),
      'totalSessions': FieldValue.increment(1),
      'totalFocusMinutes': FieldValue.increment(minutes),
      'level': ripeness.level,
      'ripeness': ripeness.ripeness,
      'currentStreak': streak.current,
      'bestStreak': streak.best,
      'lastActiveDay': today,
      'todayDay': today,
      'todayMinutes': todayMinutes,
      'todaySessions': todaySessions,
    });

    batch.set(
      _public(uid),
      {
        'level': ripeness.level,
        'lastActiveDay': today,
        'todayDay': today,
        'todayMinutes': todayMinutes,
        'focusingUntil': null,
      },
      SetOptions(merge: true),
    );

    if (taskId != null) {
      final taskRef = _user(uid).collection(FirestorePaths.tasks).doc(taskId);
      final taskSnap = await taskRef.get();
      // The task may have been deleted while the timer ran.
      if (taskSnap.exists) {
        batch.update(taskRef, {'completedSessions': FieldValue.increment(1)});
      }
    }

    await batch.commit().offlineSafe();

    return SessionReward(
      sessionId: sessionId,
      minutes: minutes,
      pointsEarned: points,
      totalPoints: p.points + points,
      ripenessGain: AppConstants.ripenessPerSession,
      level: ripeness.level,
      ripeness: ripeness.ripeness,
      leveledUp: ripeness.leveledUp,
      currentStreak: streak.current,
      bestStreak: streak.best,
      todaySessions: todaySessions,
      todayMinutes: todayMinutes,
      taskId: taskId,
    );
  }

  /// The lock-in broke (user left the app) or the user pressed "End session".
  /// No points, no streak change, and nothing already earned is removed.
  void markBroken({
    required String uid,
    required String sessionId,
    required Duration remaining,
    required BreakReason reason,
    required DateTime now,
  }) {
    final batch = _db.batch();
    batch.set(
      _sessions(uid).doc(sessionId),
      {
        'status': reason == BreakReason.endedEarly
            ? SessionStatus.cancelled.name
            : SessionStatus.broken.name,
        'endedAt': ts(now),
        'pointsEarned': 0,
        'remainingSeconds': remaining.inSeconds,
        'breakReason': reason.name,
      },
      SetOptions(merge: true),
    );
    batch.set(_public(uid), {'focusingUntil': null}, SetOptions(merge: true));
    runInBackground(batch.commit(), 'break session');
  }

  /// If the app was killed mid-session (swipe away, crash, phone died), the
  /// session is left `inProgress`. Run once at app start to mark those broken,
  /// because the user did leave the app. [startedBefore] protects a session
  /// that has just been started.
  Future<void> failStaleSessions(
    String uid, {
    required DateTime startedBefore,
  }) async {
    final snap =
        await _sessions(uid).where('status', isEqualTo: SessionStatus.inProgress.name).get();
    final stale = snap.docs.where((d) {
      final started = readDate(d.data()['startedAt']);
      return started == null || !started.isAfter(startedBefore);
    }).toList();
    if (stale.isEmpty) return;

    final batch = _db.batch();
    for (final d in stale) {
      batch.set(
        d.reference,
        {
          'status': SessionStatus.broken.name,
          'breakReason': 'appClosed',
          'pointsEarned': 0,
          'endedAt': ts(startedBefore),
        },
        SetOptions(merge: true),
      );
    }
    batch.set(_public(uid), {'focusingUntil': null}, SetOptions(merge: true));
    await batch.commit().offlineSafe();
  }

  /// All sessions that started in [start, end). Only a range on `startedAt`
  /// is used, so no composite index is needed; filter `isCompleted` in code
  /// (buildWeeklyStats does).
  Stream<List<StudySession>> watchSessionsBetween(
    String uid,
    DateTime start,
    DateTime end,
  ) =>
      _sessions(uid)
          .where('startedAt', isGreaterThanOrEqualTo: ts(start))
          .where('startedAt', isLessThan: ts(end))
          .orderBy('startedAt')
          .snapshots()
          .map((snap) => snap.docs.map(StudySession.fromDoc).toList());
}
