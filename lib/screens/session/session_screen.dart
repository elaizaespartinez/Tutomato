import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/date_helpers.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_page.dart';
import '../../core/widgets/pomodori_image.dart';
import '../../models/models.dart';
import '../../providers/app_state.dart';
import '../../providers/session_controller.dart';

/// One screen that shows the right view for the current phase:
/// focus -> complete -> break -> (next focus) or lock-in broken.
class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen>
    with WidgetsBindingObserver {
  final SessionController s = SessionController.instance;
  final AppState app = AppState.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Leaving the app during a focus session breaks the lock-in.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) s.breakLock();
  }

  Future<void> _confirmEnd() async {
    final end = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cream,
        title: const Text('End this session?'),
        content: const Text('Leaving now means the session won’t count.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep going'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'End session',
              style: TextStyle(color: AppColors.tomato),
            ),
          ),
        ],
      ),
    );
    if (end == true) s.breakLock();
  }

  void _goHome() {
    s.reset();
    Navigator.popUntil(context, ModalRoute.withName(AppRoutes.shell));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: s,
      builder: (context, _) {
        return PopScope(
          // During focus the back button asks first.
          canPop: s.phase != SessionPhase.focus,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              s.reset();
            } else {
              _confirmEnd();
            }
          },
          child: switch (s.phase) {
            SessionPhase.focus => _focusView(),
            SessionPhase.complete => _completeView(),
            SessionPhase.rest => _breakView(),
            SessionPhase.broken => _brokenView(),
            SessionPhase.idle => _idleView(),
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------- idle
  Widget _idleView() {
    return AppPage(
      title: 'Focus session',
      children: [
        const Text('No session is running.', style: AppText.body),
        const SizedBox(height: 16),
        AppButton(
          'Start a session',
          color: AppColors.leaf,
          onPressed: () =>
              Navigator.pushReplacementNamed(context, AppRoutes.sessionSetup),
        ),
      ],
    );
  }

  // --------------------------------------------------------------- focus
  Widget _focusView() {
    final ring = math.min(300.0, MediaQuery.sizeOf(context).width - 80);
    final t = s.task;
    return AppPage(
      title: 'Focus session',
      onBack: _confirmEnd,
      children: [
        Center(
          child: SizedBox(
            width: ring,
            height: ring,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size.square(ring),
                  painter: _RingPainter(s.progress),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      mmss(s.remaining),
                      style: AppText.h1.copyWith(fontSize: ring * 0.26),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'of ${mmss(s.total)} · Round ${s.round} of ${s.rounds}',
                      style: AppText.body,
                    ),
                    SizedBox(height: ring * 0.22),
                  ],
                ),
                Positioned(
                  bottom: ring * 0.02,
                  child: PomodoriImage(size: ring * 0.34),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 1; i <= s.rounds; i++)
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i <= s.round ? AppColors.tomato : AppColors.peach,
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        AppCard(
          color: AppColors.peach,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t?.name ?? 'Free focus session',
                style: AppText.h2.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 4),
              Text(
                t == null
                    ? 'No task selected'
                    : '${t.subject} · ${dueMeta(t.due)}',
                style: AppText.body,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star, color: AppColors.leaf, size: 20),
              SizedBox(width: 8),
              Text(
                '+$kPointsPerSession Study Points when you finish',
                style: TextStyle(color: AppColors.leaf, fontSize: 17),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const AppCard(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Lock-in mode is on', style: AppText.title),
              SizedBox(height: 4),
              Text(
                'Leaving the app or ending early won’t count.',
                style: AppText.body,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        AppButton(
          'End session',
          kind: AppButtonKind.outlined,
          onPressed: _confirmEnd,
        ),
        const FooterNote('Stay here until the timer ends.'),
      ],
    );
  }

  // ------------------------------------------------------------ complete
  Widget _completeView() {
    final t = s.task;
    final streak = app.streak;
    return AppPage(
      title: 'Your little win',
      onBack: _goHome,
      children: [
        const Center(child: PomodoriImage(size: 200)),
        const SizedBox(height: 16),
        Text(
          'Session complete!',
          textAlign: TextAlign.center,
          style: AppText.h1.copyWith(fontSize: 38),
        ),
        const SizedBox(height: 8),
        Text(
          '${s.focusMinutes} min on ${t?.name ?? 'a free focus session'}',
          textAlign: TextAlign.center,
          style: AppText.body.copyWith(fontSize: 17),
        ),
        const SizedBox(height: 20),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Column(
            children: [
              _ResultRow(
                icon: Icons.star,
                label: 'Study Points',
                value: '+${s.earnedPoints}',
                valueColor: AppColors.leaf,
              ),
              const Divider(height: 1, color: AppColors.border),
              _ResultRow(
                label: 'Pomodori ripeness',
                value: '+${(s.earnedRipeness * 100).round()}%',
                valueColor: AppColors.leaf,
              ),
              const Divider(height: 1, color: AppColors.border),
              _ResultRow(
                label: 'Daily streak',
                value: '$streak ${streak == 1 ? 'day' : 'days'}',
                valueColor: AppColors.leaf,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            '${app.points} points total · ${app.petName} is ${(app.ripeness * 100).round()}% ripe',
            style: const TextStyle(color: AppColors.leaf, fontSize: 15),
          ),
        ),
        if (t != null) ...[
          const SizedBox(height: 16),
          ListenableBuilder(
            listenable: app,
            builder: (context, _) => _markDoneRow(t),
          ),
        ],
        const SizedBox(height: 20),
        if (s.isLastRound) ...[
          Center(
            child: Text(
              'All ${s.rounds} rounds complete. Great work!',
              style: AppText.title,
            ),
          ),
          const SizedBox(height: 16),
          AppButton('Back to Home', color: AppColors.leaf, onPressed: _goHome),
        ] else ...[
          AppButton(
            'Start ${s.breakMinutes}-minute break',
            color: AppColors.leaf,
            onPressed: s.startBreak,
          ),
          const SizedBox(height: 8),
          Center(
            child: AppButton(
              'Back to Home',
              kind: AppButtonKind.text,
              onPressed: _goHome,
            ),
          ),
        ],
        const FooterNote('Lock in to ripen up.'),
      ],
    );
  }

  Widget _markDoneRow(Task t) {
    return Material(
      color: AppColors.peach,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => app.setTaskDone(t.id, !t.done),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: t.done ? AppColors.leaf : AppColors.card,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: t.done ? AppColors.leaf : AppColors.border,
                    width: 2,
                  ),
                ),
                child: t.done
                    ? const Icon(Icons.check, size: 18, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Mark “${t.name}” as done',
                  style: const TextStyle(fontSize: 16, color: AppColors.brown),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------- break
  Widget _breakView() {
    final over = s.restOver;
    return AppPage(
      title: 'A little breather',
      onBack: _goHome,
      children: [
        Material(
          color: AppColors.leaf,
          borderRadius: BorderRadius.circular(32),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: kMint,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          'Round ${s.round} of ${s.rounds} done',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.leaf,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Short break',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  over ? 'Break’s over. Ready?' : 'Pomodori is catching a nap',
                  textAlign: TextAlign.center,
                  style: AppText.h2.copyWith(fontSize: 26, color: Colors.white),
                ),
                const SizedBox(height: 8),
                const PomodoriImage(
                  asset: 'pomodori_nap',
                  mood: PomodoriMood.sleepy,
                  size: 200,
                ),
                Text(
                  mmss(s.remaining),
                  style: AppText.h1.copyWith(fontSize: 72, color: Colors.white),
                ),
                const SizedBox(height: 16),
                for (final tip in const [
                  'Drink some water',
                  'Stretch your neck and back',
                  'Rest your eyes',
                ])
                  _TipRow(tip),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: over ? null : s.togglePause,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.white54,
                          side: const BorderSide(
                            color: Colors.white,
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: const StadiumBorder(),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        child: Text(s.paused ? 'Resume break' : 'Pause break'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: s.startNextFocus,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.card,
                          foregroundColor: AppColors.leaf,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        child: const Text('Start next focus'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const FooterNote('Rest is part of the process.'),
      ],
    );
  }

  // -------------------------------------------------------------- broken
  Widget _brokenView() {
    final n = app.todaySessions.length;
    return AppPage(
      title: 'A fresh start',
      onBack: _goHome,
      children: [
        const Center(
          child: PomodoriImage(
            asset: 'pomodori_sad',
            mood: PomodoriMood.sad,
            size: 200,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Lock-in broken',
          textAlign: TextAlign.center,
          style: AppText.h1.copyWith(fontSize: 38),
        ),
        const SizedBox(height: 8),
        Text(
          'You left with ${mmss(s.leftWith)} still on the timer,\nso this session didn’t count.',
          textAlign: TextAlign.center,
          style: AppText.body.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 20),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Column(
            children: [
              const _ResultRow(
                icon: Icons.star,
                label: 'Study Points',
                value: '+0',
                valueColor: AppColors.tomato,
              ),
              const Divider(height: 1, color: AppColors.border),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    const Text('Your balance', style: AppText.body),
                    const Spacer(),
                    Text(
                      '${app.points} points · unchanged',
                      style: AppText.title.copyWith(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          color: kMint,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your ${app.streak}-day streak is safe',
                style: AppText.h2.copyWith(fontSize: 22, color: AppColors.leaf),
              ),
              const SizedBox(height: 4),
              Text(
                n > 0
                    ? 'You already completed $n ${n == 1 ? 'session' : 'sessions'} today.'
                    : 'Finish one session today to keep it growing.',
                style: const TextStyle(color: AppColors.leaf, fontSize: 15),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Tutomato can detect leaving the app, not whether\nyou’re studying. No earned points were removed.',
          textAlign: TextAlign.center,
          style: AppText.small,
        ),
        const SizedBox(height: 20),
        AppButton(
          'Try again',
          color: AppColors.leaf,
          onPressed: () => Navigator.pushReplacementNamed(
            context,
            AppRoutes.sessionSetup,
            arguments: s.taskId,
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: AppButton(
            'Back to Home',
            kind: AppButtonKind.text,
            onPressed: _goHome,
          ),
        ),
        const FooterNote('Every restart is a fresh start.'),
      ],
    );
  }
}

class _ResultRow extends StatelessWidget {
  final IconData? icon;
  final String label;
  final String value;
  final Color valueColor;

  const _ResultRow({
    this.icon,
    required this.label,
    required this.value,
    this.valueColor = AppColors.brown,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppColors.brown, size: 22),
            const SizedBox(width: 10),
          ],
          Text(label, style: AppText.title),
          const Spacer(),
          Text(
            value,
            style: AppText.h2.copyWith(fontSize: 22, color: valueColor),
          ),
        ],
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final String text;
  const _TipRow(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: kMint,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.check, color: AppColors.leaf),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.leaf,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.045;
    final arcRect = (Offset.zero & size).deflate(stroke / 2);
    canvas.drawArc(
      arcRect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..color = AppColors.peach
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
    canvas.drawArc(
      arcRect,
      -math.pi / 2,
      math.pi * 2 * progress.clamp(0.0, 1.0),
      false,
      Paint()
        ..color = AppColors.tomato
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
