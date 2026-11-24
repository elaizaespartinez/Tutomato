import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/async_utils.dart';
import '../../core/constants.dart';
import '../../core/format.dart';
import '../../core/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_page.dart';
import '../../core/widgets/pomodori_image.dart';
import '../../logic/timer_state.dart';
import '../../models/user_profile.dart';
import '../../providers/data_providers.dart';
import '../../providers/timer_controller.dart';

const double _kWideBreakpoint = 800;
const double _kWideMaxWidth = 980;

class SessionScreen extends ConsumerWidget {
  const SessionScreen({super.key});

  static final _fallbackProfile = UserProfile(
    uid: '',
    displayName: 'Student',
    email: '',
    createdAt: DateTime.now(),
    points: 0,
    level: 1,
    ripeness: 0,
    currentStreak: 0,
    bestStreak: 0,
    lastActiveDay: null,
    todayDay: null,
    todayMinutes: 0,
    todaySessions: 0,
    totalSessions: 0,
    totalFocusMinutes: 0,
    equipped: const EquippedItems(),
    ownedItemIds: const [],
    settings: const TimerSettings(),
    inviteCode: '',
  );

  bool _isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= _kWideBreakpoint;

  void _home(BuildContext context, WidgetRef ref) {
    ref.read(timerControllerProvider.notifier).reset();
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.shell, (r) => false);
  }

  Future<void> _confirmLeave(BuildContext context, WidgetRef ref, TimerPhase phase) async {
    final focusing = phase == TimerPhase.focus;
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cream,
        title: Text(focusing ? 'End this session?' : 'Stop here?'),
        content: Text(
          focusing
              ? 'Leaving now means this session won’t count.'
              : 'Your finished sessions are already saved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep going'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(focusing ? 'End session' : 'Stop'),
          ),
        ],
      ),
    );
    if (leave != true || !context.mounted) return;
    if (focusing) {
      ref.read(timerControllerProvider.notifier).endSession();
    } else {
      _home(context, ref);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerControllerProvider);
    final p = timerState.phase;
    final mustConfirm = p == TimerPhase.focus || p == TimerPhase.breakTime;

    return PopScope(
      canPop: !mustConfirm,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _confirmLeave(context, ref, p);
        } else if (p == TimerPhase.focusComplete || p == TimerPhase.broken) {
          ref.read(timerControllerProvider.notifier).reset();
        }
      },
      child: switch (p) {
        TimerPhase.idle => _idle(context),
        TimerPhase.focus => _focus(context, ref, timerState),
        TimerPhase.focusComplete => _complete(context, ref, timerState),
        TimerPhase.breakTime => _rest(context, ref, timerState),
        TimerPhase.broken => _lockBroken(context, ref, timerState),
      },
    );
  }

  Widget _twoColumns(List<Widget> left, List<Widget> right) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: left,
          ),
        ),
        const SizedBox(width: 32),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: right,
          ),
        ),
      ],
    );
  }

  // ==== 1. Focus view ======================================================

  Widget _ring(TimerState state) {
    return Center(
      child: LayoutBuilder(
        builder: (context, box) {
          final size = box.maxWidth < 320 ? box.maxWidth : 320.0;
          return SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: _RingPainter(state.progress)),
                ),
                Align(
                  alignment: const Alignment(0, -0.2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        formatClock(state.remaining),
                        style: AppText.h1.copyWith(fontSize: size * 0.21),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'of ${formatClock(Duration(minutes: state.config.focusMinutes))} · Round ${state.round} of ${state.config.rounds}',
                        style: AppText.small,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: size * 0.1,
                  child: PomodoriImage(size: size * 0.24),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _dots(TimerState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 1; i <= state.config.rounds; i++)
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i <= state.round ? AppColors.tomato : AppColors.peach,
            ),
          ),
      ],
    );
  }

  Widget _taskCard(TimerState state) => AppCard(
    color: AppColors.peach,
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(state.taskTitle, style: AppText.h2.copyWith(fontSize: 24)),
        const SizedBox(height: 4),
        Text(state.subject ?? 'No subject selected', style: AppText.small),
      ],
    ),
  );

  Widget _pointsLine(TimerState state) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Icon(Icons.star, size: 16, color: AppColors.leaf),
      const SizedBox(width: 8),
      Text(
        '+${state.pointsOnFinish} Study Points when you finish',
        style: const TextStyle(color: AppColors.leaf, fontSize: 16),
      ),
    ],
  );

  Widget _lockInCard() => AppCard(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Lock-in mode is on', style: AppText.h2.copyWith(fontSize: 18)),
        const SizedBox(height: 4),
        const Text(
          'Leaving the app or ending early won’t count.',
          style: AppText.small,
        ),
      ],
    ),
  );

  Widget _focus(BuildContext context, WidgetRef ref, TimerState state) {
    final endButton = AppButton(
      'End session',
      kind: AppButtonKind.outlined,
      onPressed: () => _confirmLeave(context, ref, state.phase),
    );
    const footer = FooterNote('Stay here until the timer ends.');

    if (_isWide(context)) {
      return AppPage(
        title: 'Focus session',
        maxWidth: _kWideMaxWidth,
        children: [
          _twoColumns(
            [const SizedBox(height: 8), _ring(state), const SizedBox(height: 16), _dots(state)],
            [
              const SizedBox(height: 8),
              _taskCard(state),
              const SizedBox(height: 16),
              _pointsLine(state),
              const SizedBox(height: 16),
              _lockInCard(),
              const SizedBox(height: 20),
              endButton,
            ],
          ),
          footer,
        ],
      );
    }

    return AppPage(
      title: 'Focus session',
      children: [
        const SizedBox(height: 8),
        _ring(state),
        const SizedBox(height: 16),
        _dots(state),
        const SizedBox(height: 24),
        _taskCard(state),
        const SizedBox(height: 16),
        _pointsLine(state),
        const SizedBox(height: 16),
        _lockInCard(),
        const SizedBox(height: 20),
        endButton,
        footer,
      ],
    );
  }

  // ==== 4. Break view ======================================================

  static const _tips = [
    'Drink some water',
    'Stretch your neck and back',
    'Rest your eyes',
  ];

  Widget _restPills(TimerState state) => Row(
    children: [
      Expanded(
        flex: 3,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: kMint,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Text(
              'Round ${state.round} of ${state.config.rounds} done',
              style: const TextStyle(
                color: AppColors.leaf,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
      const Expanded(
        flex: 2,
        child: Center(
          child: Text(
            'Short break',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),
      ),
    ],
  );

  List<Widget> _restHero(TimerState state) => [
    Text(
      'Pomodori is catching a nap',
      textAlign: TextAlign.center,
      style: AppText.h2.copyWith(fontSize: 26, color: Colors.white),
    ),
    const SizedBox(height: 12),
    const Center(
      child: PomodoriImage(
        size: 200,
        mood: PomodoriMood.sleepy,
      ),
    ),
    const SizedBox(height: 8),
    Text(
      formatClock(state.remaining),
      textAlign: TextAlign.center,
      style: AppText.h1.copyWith(fontSize: 72, color: Colors.white),
    ),
  ];

  List<Widget> _restTips() => [
    for (final tip in _tips)
      Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: kMint,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Text(
              '✓',
              style: TextStyle(
                color: AppColors.leaf,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                tip,
                style: const TextStyle(
                  color: AppColors.leaf,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
  ];

  Widget _restButtons(WidgetRef ref, TimerState state) => Row(
    children: [
      Expanded(
        child: _BreakButton(
          label: state.paused ? 'Resume break' : 'Pause break',
          onTap: () {
            final notifier = ref.read(timerControllerProvider.notifier);
            if (state.paused) {
              notifier.resumeBreak();
            } else {
              notifier.pauseBreak();
            }
          },
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: _BreakButton(
          label: 'Start next focus',
          filled: true,
          onTap: () => ref.read(timerControllerProvider.notifier).startNextFocus(),
        ),
      ),
    ],
  );

  Widget _rest(BuildContext context, WidgetRef ref, TimerState state) {
    final wide = _isWide(context);
    final Widget inner;

    if (wide) {
      inner = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _restPills(state),
          const SizedBox(height: 24),
          _twoColumns(
            _restHero(state),
            [
              const SizedBox(height: 16),
              ..._restTips(),
              const SizedBox(height: 16),
              _restButtons(ref, state),
            ],
          ),
        ],
      );
    } else {
      inner = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _restPills(state),
          const SizedBox(height: 20),
          ..._restHero(state),
          const SizedBox(height: 16),
          ..._restTips(),
          const SizedBox(height: 12),
          _restButtons(ref, state),
        ],
      );
    }

    return AppPage(
      title: 'A little breather',
      maxWidth: wide ? _kWideMaxWidth : 600,
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(
            wide ? 32 : 20,
            20,
            wide ? 32 : 20,
            wide ? 32 : 24,
          ),
          decoration: BoxDecoration(
            color: AppColors.leaf,
            borderRadius: BorderRadius.circular(32),
          ),
          child: inner,
        ),
        const FooterNote('Rest is part of the process.'),
      ],
    );
  }

  // ==== 3. Session complete ("Your little win") ============================

  Widget _statsCard(UserProfile profile, TimerState state) {
    final reward = state.reward;
    final pointsEarned = reward?.pointsEarned ?? state.pointsOnFinish;
    final ripenessGain = reward?.ripenessGain ?? AppConstants.ripenessPerSession;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Column(
        children: [
          _StatRow(
            label: 'Study Points',
            value: '+$pointsEarned',
            star: true,
          ),
          const Divider(height: 1, color: AppColors.border),
          _StatRow(label: 'Pomodori ripeness', value: '+$ripenessGain%'),
          const Divider(height: 1, color: AppColors.border),
          _StatRow(
            label: 'Daily streak',
            value: '${profile.currentStreak} ${profile.currentStreak == 1 ? 'day' : 'days'}',
          ),
        ],
      ),
    );
  }

  Widget _totalLine(UserProfile profile) => Text(
    '${profile.points} points total · Pomodori is ${profile.ripeness}% ripe',
    textAlign: TextAlign.center,
    style: const TextStyle(color: AppColors.leaf, fontSize: 15),
  );

  Widget _markDone(WidgetRef ref, TimerState state) {
    if (state.taskId == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.peach,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Checkbox(
            value: false,
            activeColor: AppColors.leaf,
            side: const BorderSide(color: AppColors.tomato, width: 1.5),
            onChanged: (v) {
              if (v == true) {
                ref.read(timerControllerProvider.notifier).setTaskDone(true);
              }
            },
          ),
          Expanded(
            child: Text(
              'Mark “${state.taskTitle}” as done',
              overflow: TextOverflow.ellipsis,
              style: AppText.body,
            ),
          ),
        ],
      ),
    );
  }

  Widget _complete(BuildContext context, WidgetRef ref, TimerState state) {
    final profile = ref.watch(userProfileProvider).dataOrNull ?? _fallbackProfile;
    final last = state.isFinalRound;

    final hero = <Widget>[
      const SizedBox(height: 8),
      const Center(child: PomodoriImage(size: 160)),
      const SizedBox(height: 12),
      Text(
        last ? 'All rounds done!' : 'Session complete!',
        textAlign: TextAlign.center,
        style: AppText.h1.copyWith(fontSize: 36),
      ),
      const SizedBox(height: 8),
      Text(
        '${state.config.focusMinutes} min on ${state.taskTitle}',
        textAlign: TextAlign.center,
        style: AppText.body,
      ),
    ];

    final actions = <Widget>[
      if (last)
        AppButton(
          'Finish',
          color: AppColors.leaf,
          onPressed: () => _home(context, ref),
        )
      else ...[
        AppButton(
          'Start ${state.config.breakMinutes}-minute break',
          color: AppColors.leaf,
          onPressed: () => ref.read(timerControllerProvider.notifier).startBreak(),
        ),
        const SizedBox(height: 8),
        AppButton(
          'Back to Home',
          kind: AppButtonKind.text,
          onPressed: () => _home(context, ref),
        ),
      ],
    ];

    final details = <Widget>[
      _statsCard(profile, state),
      const SizedBox(height: 12),
      _totalLine(profile),
      if (state.taskId != null) ...[
        const SizedBox(height: 16),
        _markDone(ref, state),
      ],
      const SizedBox(height: 24),
      ...actions,
    ];

    const footer = FooterNote('Lock in to ripen up.');

    if (_isWide(context)) {
      return AppPage(
        title: 'Your little win',
        maxWidth: _kWideMaxWidth,
        children: [
          _twoColumns(hero, [const SizedBox(height: 16), ...details]),
          footer,
        ],
      );
    }

    return AppPage(
      title: 'Your little win',
      children: [...hero, const SizedBox(height: 20), ...details, footer],
    );
  }

  // ==== 2. Lock-in broken ("A fresh start") ================================

  Widget _lockBroken(BuildContext context, WidgetRef ref, TimerState state) {
    final profile = ref.watch(userProfileProvider).dataOrNull ?? _fallbackProfile;
    final broken = state.broken;

    final hero = <Widget>[
      const SizedBox(height: 8),
      const Center(
        child: PomodoriImage(
          size: 150,
          mood: PomodoriMood.sad,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        'Lock-in broken',
        textAlign: TextAlign.center,
        style: AppText.h1.copyWith(fontSize: 34),
      ),
      const SizedBox(height: 8),
      Text(
        'You left with ${formatClock(state.remaining)} still on the timer,\nso this session didn’t count.',
        textAlign: TextAlign.center,
        style: AppText.body,
      ),
    ];

    final pointsCard = AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.star, size: 18, color: AppColors.brown),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Study Points',
                  style: AppText.h2.copyWith(fontSize: 18),
                ),
              ),
              Text(
                '+0',
                style: AppText.h2.copyWith(
                  fontSize: 22,
                  color: AppColors.tomato,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: Text('Your balance', style: AppText.small),
              ),
              Text(
                '${broken?.pointsBalance ?? profile.points} points · unchanged',
                style: AppText.small.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.brown,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    final done = broken?.todaySessions ?? 0;
    final streakCard = AppCard(
      color: AppColors.peach,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            done > 0
                ? 'Your streak is safe'
                : 'Finish one session to keep your streak',
            style: AppText.h2.copyWith(fontSize: 18, color: AppColors.leaf),
          ),
          const SizedBox(height: 4),
          Text(
            done > 0
                ? 'You already completed $done ${done == 1 ? 'session' : 'sessions'} today.'
                : 'One focused session today keeps it growing.',
            style: AppText.small,
          ),
        ],
      ),
    );

    const note = Text(
      'Tutomato detects leaving the app or ending early. No earned points were removed.',
      textAlign: TextAlign.center,
      style: AppText.small,
    );

    final actions = <Widget>[
      AppButton('Try again', color: AppColors.leaf, onPressed: () => ref.read(timerControllerProvider.notifier).retry()),
      const SizedBox(height: 8),
      AppButton(
        'Back to Home',
        kind: AppButtonKind.text,
        onPressed: () => _home(context, ref),
      ),
    ];

    const footer = FooterNote('Every restart is a fresh start.');

    if (_isWide(context)) {
      return AppPage(
        title: 'A fresh start',
        maxWidth: _kWideMaxWidth,
        children: [
          _twoColumns(hero, [
            const SizedBox(height: 16),
            pointsCard,
            const SizedBox(height: 12),
            streakCard,
            const SizedBox(height: 16),
            note,
            const SizedBox(height: 20),
            ...actions,
          ]),
          footer,
        ],
      );
    }

    return AppPage(
      title: 'A fresh start',
      children: [
        ...hero,
        const SizedBox(height: 20),
        pointsCard,
        const SizedBox(height: 12),
        streakCard,
        const SizedBox(height: 16),
        note,
        const SizedBox(height: 20),
        ...actions,
        footer,
      ],
    );
  }

  Widget _idle(BuildContext context) {
    return AppPage(
      title: 'Session',
      children: [
        const SizedBox(height: 24),
        const Center(child: PomodoriImage(size: 140)),
        const SizedBox(height: 16),
        Text(
          'No session running',
          textAlign: TextAlign.center,
          style: AppText.h2.copyWith(fontSize: 26),
        ),
        const SizedBox(height: 24),
        AppButton(
          'Set up a session',
          color: AppColors.leaf,
          onPressed: () =>
              Navigator.pushReplacementNamed(context, AppRoutes.sessionSetup),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final bool star;
  const _StatRow({required this.label, required this.value, this.star = false});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Row(
      children: [
        if (star) ...[
          const Icon(Icons.star, size: 16, color: AppColors.brown),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(label, style: AppText.h2.copyWith(fontSize: 17)),
        ),
        Text(
          value,
          style: AppText.h2.copyWith(fontSize: 20, color: AppColors.leaf),
        ),
      ],
    ),
  );
}

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 14.0;
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = AppColors.peach;
    canvas.drawCircle(center, radius, track);

    if (progress <= 0) return;
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = AppColors.tomato;
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false, arc);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

class _BreakButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool filled;
  const _BreakButton({
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? Colors.white : Colors.transparent,
      shape: StadiumBorder(
        side: filled
            ? BorderSide.none
            : const BorderSide(color: Colors.white, width: 1.5),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: filled ? AppColors.leaf : Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}