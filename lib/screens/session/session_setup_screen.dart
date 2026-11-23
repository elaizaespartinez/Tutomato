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
import '../../core/widgets/app_fields.dart';
import '../../core/widgets/app_page.dart';
import '../../core/widgets/steppers.dart';
import '../../logic/timer_state.dart';
import '../../models/study_task.dart';
import '../../models/user_profile.dart';
import '../../providers/data_providers.dart';
import '../../providers/timer_controller.dart';
import '../../services/dnd_service.dart';

const double _kWideBreakpoint = 800;

class SessionSetupScreen extends ConsumerStatefulWidget {
  const SessionSetupScreen({super.key});

  @override
  ConsumerState<SessionSetupScreen> createState() => _SessionSetupScreenState();
}

class _SessionSetupScreenState extends ConsumerState<SessionSetupScreen> {
  int _focus = 25;
  int _rest = 5;
  int _rounds = 4;
  String _taskId = '';
  bool _initializedDefaults = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initializedDefaults) return;
    _initializedDefaults = true;

    final profile = ref.read(userProfileProvider).dataOrNull ?? UserProfile.fallback();
    _focus = profile.settings.focusMinutes;
    _rest = profile.settings.breakMinutes;
    _rounds = profile.settings.rounds;

    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is String) {
      _taskId = arg;
    }
  }

  void _start(List<StudyTask> todoTasks) {
    StudyTask? selectedTask;
    if (_taskId.isNotEmpty) {
      selectedTask = todoTasks.where((t) => t.id == _taskId).firstOrNull;
    }

    ref.read(timerControllerProvider.notifier).startFocus(
          config: TimerConfig(
            focusMinutes: _focus,
            breakMinutes: _rest,
            rounds: _rounds,
          ),
          task: selectedTask,
        );

    Navigator.pushReplacementNamed(context, AppRoutes.focus);
  }

  Widget _presetCard(RhythmPreset p) {
    final selected = _focus == p.focus && _rest == p.rest;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(
        color: selected ? AppColors.tomato : AppColors.border,
        width: selected ? 2 : 1,
      ),
    );
    return Expanded(
      child: Material(
        color: selected ? AppColors.peach : AppColors.card,
        shape: shape,
        child: InkWell(
          customBorder: shape,
          onTap: () => setState(() {
            _focus = p.focus;
            _rest = p.rest;
          }),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Column(
              children: [
                Text(
                  '${p.focus} / ${p.rest}',
                  style: AppText.h2.copyWith(fontSize: 26),
                ),
                const SizedBox(height: 4),
                Text(
                  p.name,
                  style: TextStyle(
                    fontSize: 15,
                    color: selected ? AppColors.tomato : AppColors.brownSoft,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _rhythmSection() => [
    Text('Pick your rhythm', style: AppText.h2.copyWith(fontSize: 22)),
    const SizedBox(height: 12),
    Row(
      children: [
        for (var i = 0; i < AppConstants.presets.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          _presetCard(AppConstants.presets[i]),
        ],
      ],
    ),
  ];

  Widget _focusStepper() => StepperCard(
    title: 'Focus',
    value: '$_focus min',
    onMinus: _focus > 5 ? () => setState(() => _focus -= 5) : null,
    onPlus: _focus < 90 ? () => setState(() => _focus += 5) : null,
  );

  Widget _breakStepper() => StepperCard(
    title: 'Short break',
    value: '$_rest min',
    onMinus: _rest > 1 ? () => setState(() => _rest -= 1) : null,
    onPlus: _rest < 30 ? () => setState(() => _rest += 1) : null,
  );

  Widget _roundsStepper() => StepperCard(
    title: 'Rounds',
    value: '$_rounds ×',
    onMinus: _rounds > 1 ? () => setState(() => _rounds -= 1) : null,
    onPlus: _rounds < 8 ? () => setState(() => _rounds += 1) : null,
  );

  List<Widget> _customSection({required bool wide}) => [
    Text('Or make it yours', style: AppText.h2.copyWith(fontSize: 22)),
    const SizedBox(height: 12),
    if (wide) ...[
      _focusStepper(),
      const SizedBox(height: 12),
      _breakStepper(),
      const SizedBox(height: 12),
      _roundsStepper(),
    ] else ...[
      Row(
        children: [
          Expanded(child: _focusStepper()),
          const SizedBox(width: 12),
          Expanded(child: _breakStepper()),
        ],
      ),
      const SizedBox(height: 12),
      Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: _roundsStepper(),
        ),
      ),
    ],
  ];

  List<Widget> _studyingSection(List<StudyTask> todoTasks) => [
    Text('What are you studying?', style: AppText.h2.copyWith(fontSize: 22)),
    const SizedBox(height: 12),
    AppDropdown<String>(
      value: todoTasks.any((t) => t.id == _taskId) ? _taskId : '',
      onChanged: (v) => setState(() => _taskId = v ?? ''),
      items: [
        const DropdownMenuItem(
          value: '',
          child: Text('Free focus (no task)'),
        ),
        for (final t in todoTasks)
          DropdownMenuItem(
            value: t.id,
            child: Text(t.title, overflow: TextOverflow.ellipsis),
          ),
      ],
    ),
  ];

  Widget _lockCard() => AppCard(
    color: AppColors.peach,
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lock-in mode · ON',
          style: AppText.h2.copyWith(fontSize: 22, color: AppColors.leaf),
        ),
        const SizedBox(height: 6),
        const Text(
          'Stay in the app until the timer ends. Leaving or ending early means the session won’t count.',
          style: AppText.body,
        ),
      ],
    ),
  );

  Widget _startButton(List<StudyTask> todoTasks) => AppButton(
    'Start ${formatClock(_focus * 60)} focus',
    color: AppColors.leaf,
    onPressed: () => _start(todoTasks),
  );

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= _kWideBreakpoint;
    final taskGroups = ref.watch(taskGroupsProvider);
    final todoTasks = taskGroups.todo;

    if (wide) {
      return AppPage(
        title: 'Start a session',
        maxWidth: 980,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ..._rhythmSection(),
                    const SizedBox(height: 24),
                    ..._customSection(wide: true),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ..._studyingSection(todoTasks),
                    const SizedBox(height: 20),
                    _lockCard(),
                    const SizedBox(height: 24),
                    _startButton(todoTasks),
                  ],
                ),
              ),
            ],
          ),
          const FooterNote('Lock in to ripen up.'),
        ],
      );
    }

    return AppPage(
      title: 'Start a session',
      children: [
        ..._rhythmSection(),
        const SizedBox(height: 24),
        ..._customSection(wide: false),
        const SizedBox(height: 24),
        ..._studyingSection(todoTasks),
        const SizedBox(height: 20),
        _lockCard(),
        const SizedBox(height: 24),
        _startButton(todoTasks),
        const FooterNote('Lock in to ripen up.'),
      ],
    );
  }
}