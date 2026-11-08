# Tutomato backend guide

For the UI team: every screen in the Figma maps to providers you `ref.watch` and
actions you `ref.read(actionsProvider)`. No Firestore code is needed in widgets.

```dart
final profile = ref.watch(userProfileProvider).dataOrNull;   // import core/async_utils.dart
await ref.read(actionsProvider).addTask(...);                // throws AppException with a friendly message
```

## Architecture

```
lib/
  core/          constants, validators, formatting, day helpers, errors
  models/        plain data classes (UserProfile, StudyTask, StudySession, Friendship, ...)
  logic/         pure rules, no Firebase: streak, points/ripeness, task grouping, weekly stats, timer state
  services/      AuthService (Firebase Auth), LockInService (app lifecycle), PrefsService (Remember me)
  repositories/  the only code that talks to Firestore
  providers/     Riverpod: live data, the timer controller, auth controller, actions
  features/playground/   throw-away test UI; delete when the real screens exist
```

## Screen map

| Figma screen | Watch | Call |
|---|---|---|
| 14 Welcome | none | navigate only |
| 15 Log in | `authControllerProvider` (loading/error) | `authControllerProvider.notifier`: `signIn`, `sendPasswordReset`; prefill with `prefsServiceProvider` (`rememberedEmail`, `rememberMe`) |
| 16 Sign up | `authControllerProvider` | `signUp(name, email, password, confirmPassword)`; use `Validators.*` for inline errors |
| Home | `userProfileProvider`, `taskGroupsProvider` | `profile.points`, `profile.minutesOn(today)`, `profile.sessionsOn(today)`, `profile.streakOn(today)`, `taskGroups.today` |
| Make room for growth (sheet) | none | navigate only |
| To Learn | `taskGroupsProvider` (`todo`, `today`, `upcoming`, `done`) | `actionsProvider`: `setTaskDone`, `deleteTask`; helpers `dueLabel`, `sessionsLabel` |
| Add a task | none | `actionsProvider.addTask(title, subject, plannedSessions, dueDate)`; `AppConstants.subjects` for the dropdown |
| Start a session | `tasksProvider` (dropdown), `userProfileProvider` (`settings`) | `AppConstants.presets`; `timerControllerProvider.notifier.startFocus(config: TimerConfig(...), task: task)` |
| Focus session | `timerControllerProvider` (`phase == focus`: `remaining`, `progress`, `round`, `config.rounds`, `pointsOnFinish`) | `endSession()`; format with `formatClock` |
| Your little win | `timerControllerProvider` (`phase == focusComplete`: `reward`, `isFinalRound`) | `startBreak()`, `setTaskDone(true)`, `reset()` (Back to Home). `reward == null` means still saving |
| A little breather | `timerControllerProvider` (`phase == breakTime`: `remaining`, `paused`, `breakFinished`) | `pauseBreak()`, `resumeBreak()`, `startNextFocus()` |
| A fresh start (lock-in broken) | `timerControllerProvider` (`phase == broken`: `broken`) | `retry()`, `reset()` |
| Your Pomodori (3 tabs) | `userProfileProvider` (`level`, `ripeness`, `points`), `shopEntriesProvider(ShopCategory.outfit/color/extra)` | `buyAndEquipItem(id)` on a "Buy" card, `equipItem(id)` on an owned card |
| Your records | `weeklyStatsProvider(selectedWeek)`, `userProfileProvider` (`bestStreak`) | set `selectedWeekProvider` to change week; `formatMinutes`, `weekRangeLabel`, `formatTimeOfDay` |
| Better together | `friendsHeroProvider`, `friendCardsProvider`, `cheersProvider` | `actionsProvider`: `cheer(uid)`, `addFriendByCode(code)`; your code to share: `profile.inviteCode` |
| Your profile | `userProfileProvider` | `updateName`, `updateSettings(profile.settings.copyWith(...))`, `authControllerProvider.notifier`: `changePassword`, `signOut`; `growingSinceLabel(profile.createdAt)` |

Navigation: watch `authStateProvider` (see `AuthGate` in `app.dart`). Don't navigate on login success; the gate does it.

## Firestore data model

```
users/{uid}                    private: displayName, email, createdAt, points, level, ripeness,
                               currentStreak, bestStreak, lastActiveDay, todayDay/todayMinutes/todaySessions,
                               totalSessions, totalFocusMinutes, equipped{outfit,color,extra},
                               ownedItemIds[], settings{focusMinutes,breakMinutes,rounds,dailyGoalSessions,
                               soundEnabled,remindersEnabled}, inviteCode
users/{uid}/tasks/{id}         title, subject, plannedSessions, completedSessions, dueDay, isDone, createdAt, doneAt
users/{uid}/sessions/{id}      taskId, taskTitle, subject, plannedMinutes, round, totalRounds,
                               status(inProgress|completed|broken|cancelled), startedAt, endedAt, pointsEarned
users/{uid}/cheers/{from_day}  fromUid, fromName, createdAt
publicProfiles/{uid}           what friends see: displayName, equipped, level, lastActiveDay,
                               todayDay/todayMinutes, focusingUntil, inviteCode
friendships/{uidA_uidB}        members[2], sharedStreak, bestSharedStreak, lastSharedDay, createdAt
```

The shop catalog (names, prices) lives in code: `models/shop_item.dart`. No Firestore indexes are needed.

## Game rules (all in one place each)

| Rule | Where |
|---|---|
| A session counts only if the timer reaches 00:00 without the app going to the background and without "End session" | `TimerController`, `LockInService` |
| Leaving the app or ending early: 0 points, no streak change, nothing already earned is removed | `SessionRepository.markBroken` |
| Points per completed session = focus minutes (25 min = +25) | `logic/rewards.dart` |
| Ripeness +8% per session; at 100% it rolls into the next level | `logic/rewards.dart` |
| Streak: +1 if you completed a session yesterday, otherwise restarts at 1; shows 0 once a day is missed | `logic/streak.dart` |
| Shared streak: +1 on a day when BOTH friends completed a session (the second to finish triggers it) | `FriendRepository.onSessionCompleted` |
| Task progress ("1 / 3 sessions") goes up by 1 for each completed session linked to the task | `SessionRepository.completeFocus` |
| App killed mid-session counts as leaving the app (marked broken on next launch) | `staleSessionCleanupProvider` |

## Decisions I made that you should confirm

1. **Points = focus minutes**, not a flat 25. Prevents farming with 1-minute sessions. One line to change (`logic/rewards.dart`).
2. **Custom duration limits**: focus 1-120, break 1-30, rounds 1-8 (`core/constants.dart`). The README still says "TODO: specify the allowed range". The minimum is 1 so you can test quickly; raise it to 5 before the demo if you like.
3. **No long break.** The design only has short breaks and "Round X of Y".
4. **Friends are added instantly** with an invite code (no request/accept step) to keep scope small.
5. **Subject list** for the dropdown is a guess (`AppConstants.subjects`).
6. **Task "done" is manual** (checkbox), as in the design; finishing all planned sessions doesn't auto-complete it.
7. **Screen lock counts as leaving the app.** Android reports it as backgrounded.

## Known limitations (put these in your report)

- Points are calculated on the phone, so a technically skilled user could edit their own points. Fine for a course project; a production app would move this to Cloud Functions.
- Lock-in detects leaving the app, not whether the student is studying, and it doesn't block other apps (already in your scope).
- Shared streaks need an internet connection to update; everything else works offline and syncs later.
- No notification when a timer ends while the app is in the background (a break timer keeps counting; the screen is correct when you return).
- Friends can see name, outfit, level, today's minutes and whether you're focusing. They cannot see email, points or tasks.
