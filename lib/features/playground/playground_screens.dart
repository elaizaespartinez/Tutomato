// PLACEHOLDER UI. Ugly on purpose: it exists only so the backend can be tried
// on the emulator before the real Figma screens are built. When the UI team
// builds the real screens, they call the same providers used here (see
// docs/BACKEND.md) and this file can be deleted.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutomato/core/async_utils.dart';
import 'package:tutomato/core/constants.dart';
import 'package:tutomato/core/day_keys.dart';
import 'package:tutomato/core/format.dart';
import 'package:tutomato/logic/timer_state.dart';
import 'package:tutomato/models/session_result.dart';
import 'package:tutomato/models/shop_item.dart';
import 'package:tutomato/models/user_profile.dart';
import 'package:tutomato/providers/actions.dart';
import 'package:tutomato/providers/auth_controller.dart';
import 'package:tutomato/providers/core_providers.dart';
import 'package:tutomato/providers/data_providers.dart';
import 'package:tutomato/providers/startup_providers.dart';
import 'package:tutomato/providers/timer_controller.dart';

/// Runs [action] and shows any error message in a SnackBar.
Future<void> guarded(BuildContext context, Future<void> Function() action) async {
  try {
    await action();
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title, this.children);

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Log in / Sign up
// =============================================================================

class AuthPlaceholderScreen extends ConsumerStatefulWidget {
  const AuthPlaceholderScreen({super.key});

  @override
  ConsumerState<AuthPlaceholderScreen> createState() => _AuthPlaceholderScreenState();
}

class _AuthPlaceholderScreenState extends ConsumerState<AuthPlaceholderScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _signUp = false;
  bool _remember = true;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(prefsServiceProvider);
    _email.text = prefs.rememberedEmail ?? '';
    _remember = prefs.rememberMe;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = ref.read(authControllerProvider.notifier);
    if (_signUp) {
      await auth.signUp(
        name: _name.text,
        email: _email.text,
        password: _password.text,
        confirmPassword: _confirm.text,
      );
    } else {
      await auth.signIn(
        email: _email.text,
        password: _password.text,
        rememberMe: _remember,
      );
    }
  }

  Future<void> _forgotPassword() async {
    final ok = await ref.read(authControllerProvider.notifier).sendPasswordReset(_email.text);
    if (ok && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Password reset link sent. Check your email.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(_signUp ? 'Let\'s grow together.' : 'Welcome back!',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            if (_signUp) TextField(controller: _name, decoration: const InputDecoration(labelText: 'Your name')),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email address'),
            ),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                helperText: _signUp ? 'Use at least 8 characters, a letter, and a number.' : null,
              ),
            ),
            if (_signUp)
              TextField(
                controller: _confirm,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirm password'),
              ),
            if (!_signUp)
              Row(
                children: [
                  Checkbox(value: _remember, onChanged: (v) => setState(() => _remember = v ?? true)),
                  const Text('Remember me'),
                  const Spacer(),
                  TextButton(onPressed: _forgotPassword, child: const Text('Forgot password?')),
                ],
              ),
            if (auth.hasError)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(auth.error.toString(),
                    style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: auth.isLoading ? null : _submit,
              child: auth.isLoading
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(_signUp ? 'Create account' : 'Log in'),
            ),
            TextButton(
              onPressed: () => setState(() => _signUp = !_signUp),
              child: Text(_signUp ? 'Already have an account? Log in' : 'New here? Sign up'),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Logged-in playground
// =============================================================================

class HomePlaceholderScreen extends ConsumerWidget {
  const HomePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(staleSessionCleanupProvider); // run the one-time cleanup
    final profile = ref.watch(userProfileProvider).dataOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutomato · backend playground'),
        actions: [
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: profile == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                _ProfileCard(profile: profile),
                const _TimerCard(),
                const _TasksCard(),
                const _RecordsCard(),
                _ShopCard(profile: profile),
                _FriendsCard(profile: profile),
              ],
            ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final today = dayKey(DateTime.now());
    return _Section('Hi, ${profile.displayName}!', [
      Text(profile.email),
      Text(growingSinceLabel(profile.createdAt)),
      Text('Study Points: ${profile.points}'),
      Text('Level ${profile.level} · Ripeness ${profile.ripeness}%'),
      Text('${formatMinutes(profile.minutesOn(today))} today · '
          '${profile.sessionsOn(today)} / ${profile.settings.dailyGoalSessions} sessions · '
          '${profile.streakOn(today)}-day streak (best ${profile.bestStreak})'),
      Text('Timer preference: ${profile.settings.summary}'),
    ]);
  }
}

// ---- Timer ------------------------------------------------------------------

class _TimerCard extends ConsumerStatefulWidget {
  const _TimerCard();

  @override
  ConsumerState<_TimerCard> createState() => _TimerCardState();
}

class _TimerCardState extends ConsumerState<_TimerCard> {
  // Defaults are tiny so a whole flow can be tested in about 2 minutes.
  final _focus = TextEditingController(text: '1');
  final _break = TextEditingController(text: '1');
  final _rounds = TextEditingController(text: '2');

  @override
  void dispose() {
    _focus.dispose();
    _break.dispose();
    _rounds.dispose();
    super.dispose();
  }

  Widget _numberField(String label, TextEditingController c) => Expanded(
        child: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: TextField(
            controller: c,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: label),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(timerControllerProvider);
    final timer = ref.read(timerControllerProvider.notifier);
    final task = ref.watch(taskGroupsProvider).todo.firstOrNull;

    final List<Widget> body = switch (t.phase) {
      TimerPhase.idle => [
          Row(children: [
            _numberField('Focus min', _focus),
            _numberField('Break min', _break),
            _numberField('Rounds', _rounds),
          ]),
          Text('Studying: ${task?.title ?? 'Free study (add a task to pick one)'}'),
          Text('Presets: ${AppConstants.presets.map((p) => p.label).join('  ·  ')}'),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () => guarded(
              context,
              () => timer.startFocus(
                config: TimerConfig(
                  focusMinutes: int.tryParse(_focus.text) ?? AppConstants.defaultFocusMinutes,
                  breakMinutes: int.tryParse(_break.text) ?? AppConstants.defaultBreakMinutes,
                  rounds: int.tryParse(_rounds.text) ?? AppConstants.defaultRounds,
                ),
                task: task,
              ),
            ),
            child: const Text('Start focus (lock-in ON)'),
          ),
        ],
      TimerPhase.focus => [
          Text(formatClock(t.remaining), style: Theme.of(context).textTheme.displayMedium),
          Text('${t.taskTitle} · Round ${t.round} of ${t.config.rounds}'),
          Text('+${t.pointsOnFinish} Study Points when you finish'),
          const Text('Lock-in is on. Press the phone\'s Home button to see it break.'),
          OutlinedButton(onPressed: timer.endSession, child: const Text('End session')),
        ],
      TimerPhase.focusComplete => _completeWidgets(context, t, timer),
      TimerPhase.breakTime => [
          Text('A little breather · round ${t.round} of ${t.config.rounds} done'),
          Text(formatClock(t.remaining), style: Theme.of(context).textTheme.displayMedium),
          Row(children: [
            OutlinedButton(
              onPressed: t.breakFinished ? null : (t.paused ? timer.resumeBreak : timer.pauseBreak),
              child: Text(t.paused ? 'Resume break' : 'Pause break'),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () => guarded(context, timer.startNextFocus),
              child: const Text('Start next focus'),
            ),
          ]),
        ],
      TimerPhase.broken => [
          Text('Lock-in broken', style: Theme.of(context).textTheme.titleLarge),
          if (t.broken != null) ...[
            Text(t.broken!.reason == BreakReason.leftApp
                ? 'You left with ${formatClock(t.broken!.remaining)} still on the timer, so this session didn\'t count.'
                : 'You ended early, so this session didn\'t count.'),
            Text('Study Points +0 · balance ${t.broken!.pointsBalance} unchanged'),
            if (t.broken!.streakIsSafe)
              Text('Your ${t.broken!.currentStreak}-day streak is safe. '
                  'You already completed ${t.broken!.todaySessions} sessions today.'),
          ],
          Row(children: [
            FilledButton(onPressed: () => guarded(context, timer.retry), child: const Text('Try again')),
            TextButton(onPressed: timer.reset, child: const Text('Back to Home')),
          ]),
        ],
    };

    return _Section('Pomodoro timer · phase: ${t.phase.name}', body);
  }

  List<Widget> _completeWidgets(BuildContext context, TimerState t, TimerController timer) {
    final r = t.reward;
    return [
      Text('Session complete!', style: Theme.of(context).textTheme.titleLarge),
      if (r == null && t.errorMessage == null) const LinearProgressIndicator(),
      if (t.errorMessage != null) Text(t.errorMessage!),
      if (r != null) ...[
        Text('${r.minutes} min on ${t.taskTitle}'),
        Text('Study Points +${r.pointsEarned} (total ${r.totalPoints})'),
        Text('Pomodori ripeness +${r.ripenessGain}% -> ${r.ripeness}% ripe'
            '${r.leveledUp ? ' · LEVEL UP to ${r.level}!' : ''}'),
        Text('Daily streak: ${r.currentStreak} days'),
      ],
      if (t.taskId != null)
        OutlinedButton(
          onPressed: () => guarded(context, () => timer.setTaskDone(true)),
          child: Text('Mark "${t.taskTitle}" as done'),
        ),
      if (!t.isFinalRound) ...[
        FilledButton(onPressed: timer.startBreak, child: Text('Start ${t.breakMinutes}-minute break')),
        TextButton(
          onPressed: () => guarded(context, timer.startNextFocus),
          child: const Text('Skip break · next focus'),
        ),
      ],
      TextButton(onPressed: timer.reset, child: const Text('Back to Home')),
    ];
  }
}

// ---- To Learn ---------------------------------------------------------------

class _TasksCard extends ConsumerStatefulWidget {
  const _TasksCard();

  @override
  ConsumerState<_TasksCard> createState() => _TasksCardState();
}

class _TasksCardState extends ConsumerState<_TasksCard> {
  final _title = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groups = ref.watch(taskGroupsProvider);
    final actions = ref.read(actionsProvider);
    final today = dayKey(DateTime.now());

    return _Section(
      'To Learn · To do ${groups.todo.length} · Today ${groups.today.length} · Done ${groups.done.length}',
      [
        Row(children: [
          Expanded(
            child: TextField(
              controller: _title,
              decoration: const InputDecoration(hintText: 'New task (Biology, 2 sessions, due today)'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => guarded(context, () async {
              await actions.addTask(
                title: _title.text,
                subject: AppConstants.subjects.first,
                plannedSessions: 2,
                dueDate: DateTime.now(),
              );
              if (mounted) _title.clear();
            }),
          ),
        ]),
        for (final t in [...groups.today, ...groups.upcoming])
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Checkbox(
              value: false,
              onChanged: (_) => guarded(context, () => actions.setTaskDone(t.id, true)),
            ),
            title: Text(t.title),
            subtitle: Text('${t.subject} · ${dueLabel(t.dueDay, today)} · '
                '${sessionsLabel(t.completedSessions, t.plannedSessions)}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => guarded(context, () => actions.deleteTask(t.id)),
            ),
          ),
        if (groups.done.isNotEmpty)
          Text('${groups.done.length} completed: ${groups.done.map((t) => t.title).join(', ')}'),
      ],
    );
  }
}

// ---- Records ----------------------------------------------------------------

class _RecordsCard extends ConsumerWidget {
  const _RecordsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final week = ref.watch(selectedWeekProvider);
    final stats = ref.watch(weeklyStatsProvider(week));
    final profile = ref.watch(userProfileProvider).dataOrNull;
    final today = dayKey(DateTime.now());

    return _Section('Your records · This week · ${weekRangeLabel(week)}', [
      if (stats == null)
        const LinearProgressIndicator()
      else ...[
        Text('Focus time ${formatMinutes(stats.totalMinutes)} · ${stats.sessionsCompleted} sessions completed'),
        Text('Minutes M T W T F S S: ${stats.minutesPerDay.join('  ')}'),
        Text('Current streak ${profile?.streakOn(today) ?? 0} days · best ${profile?.bestStreak ?? 0} days'),
        const Text('Today\'s sessions:'),
        for (final s in stats.todaySessions)
          Text('  ${s.subject ?? 'Free study'} · ${s.plannedMinutes} min · ${formatTimeOfDay(s.startedAt)}'),
      ],
    ]);
  }
}

// ---- Pomodori shop ----------------------------------------------------------

class _ShopCard extends ConsumerWidget {
  const _ShopCard({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = ref.read(actionsProvider);
    return _Section('Your Pomodori · ${profile.points} points', [
      for (final category in ShopCategory.values) ...[
        Text(category.name.toUpperCase(), style: Theme.of(context).textTheme.labelLarge),
        for (final entry in ref.watch(shopEntriesProvider(category)))
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(entry.item.name),
            subtitle: Text(entry.equipped
                ? 'Equipped ✓'
                : entry.owned
                    ? 'Owned'
                    : 'Buy · ${entry.item.cost} pts'),
            trailing: entry.equipped
                ? null
                : FilledButton.tonal(
                    onPressed: () => guarded(
                      context,
                      () => entry.owned
                          ? actions.equipItem(entry.item.id)
                          : actions.buyAndEquipItem(entry.item.id),
                    ),
                    child: Text(entry.owned ? 'Equip' : 'Buy'),
                  ),
          ),
      ],
    ]);
  }
}

// ---- Friends ----------------------------------------------------------------

class _FriendsCard extends ConsumerStatefulWidget {
  const _FriendsCard({required this.profile});

  final UserProfile profile;

  @override
  ConsumerState<_FriendsCard> createState() => _FriendsCardState();
}

class _FriendsCardState extends ConsumerState<_FriendsCard> {
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actions = ref.read(actionsProvider);
    final hero = ref.watch(friendsHeroProvider);
    final cards = ref.watch(friendCardsProvider);
    final cheers = ref.watch(cheersProvider).dataOrNull ?? const [];

    return _Section('Better together · ${cards.length} friends', [
      SelectableText('Your invite code: ${widget.profile.inviteCode}'),
      Row(children: [
        Expanded(
          child: TextField(
            controller: _code,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(hintText: 'Friend\'s invite code'),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.person_add),
          onPressed: () => guarded(context, () async {
            await actions.addFriendByCode(_code.text);
            if (mounted) _code.clear();
          }),
        ),
      ]),
      if (hero != null)
        Text('YOU + ${hero.friend.name.toUpperCase()}: ${hero.friend.sharedStreak} days of showing up · '
            '${hero.progressText}'),
      for (final f in cards)
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(f.name),
          subtitle: Text('${f.sharedStreak}-day shared streak · ${f.statusText}'),
          trailing: TextButton(
            onPressed: () => guarded(context, () => actions.cheer(f.uid)),
            child: const Text('Cheer'),
          ),
        ),
      Text('Cheers received: ${cheers.length}'
          '${cheers.isEmpty ? '' : ' (latest from ${cheers.first.fromName})'}'),
    ]);
  }
}
