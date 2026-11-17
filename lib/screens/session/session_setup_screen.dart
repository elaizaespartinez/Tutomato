import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/date_helpers.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_fields.dart';
import '../../core/widgets/app_page.dart';
import '../../core/widgets/steppers.dart';
import '../../providers/app_state.dart';
import '../../providers/session_controller.dart';

class SessionSetupScreen extends StatefulWidget {
  const SessionSetupScreen({super.key});

  @override
  State<SessionSetupScreen> createState() => _SessionSetupScreenState();
}

class _SessionSetupScreenState extends State<SessionSetupScreen> {
  final AppState app = AppState.instance;
  late int _focus = app.defaultFocus;
  late int _rest = app.defaultBreak;
  int _rounds = 4;
  String _taskId = ''; // empty = no task
  bool _readArgs = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_readArgs) return;
    _readArgs = true;

    // A task can be passed in when opening this screen from To Learn or Home.
    final arg = ModalRoute.of(context)?.settings.arguments;
    final passed = arg is String ? app.taskById(arg) : null;
    if (passed != null && !passed.done) {
      _taskId = passed.id;
    } else if (app.todo.isNotEmpty) {
      _taskId = app.todo.first.id;
    }
  }

  void _start() {
    SessionController.instance.start(
      focus: _focus,
      rest: _rest,
      rounds: _rounds,
      taskId: _taskId.isEmpty ? null : _taskId,
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

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Start a session',
      children: [
        Text('Pick your rhythm', style: AppText.h2.copyWith(fontSize: 22)),
        const SizedBox(height: 12),
        Row(
          children: [
            for (var i = 0; i < kPresets.length; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              _presetCard(kPresets[i]),
            ],
          ],
        ),
        const SizedBox(height: 24),
        Text('Or make it yours', style: AppText.h2.copyWith(fontSize: 22)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StepperCard(
                title: 'Focus',
                value: '$_focus min',
                onMinus: _focus > 5 ? () => setState(() => _focus -= 5) : null,
                onPlus: _focus < 90 ? () => setState(() => _focus += 5) : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StepperCard(
                title: 'Short break',
                value: '$_rest min',
                onMinus: _rest > 1 ? () => setState(() => _rest -= 1) : null,
                onPlus: _rest < 30 ? () => setState(() => _rest += 1) : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: StepperCard(
              title: 'Rounds',
              value: '$_rounds ×',
              onMinus: _rounds > 1 ? () => setState(() => _rounds -= 1) : null,
              onPlus: _rounds < 8 ? () => setState(() => _rounds += 1) : null,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'What are you studying?',
          style: AppText.h2.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 12),
        AppDropdown<String>(
          value: _taskId,
          onChanged: (v) => setState(() => _taskId = v ?? ''),
          items: [
            const DropdownMenuItem(
              value: '',
              child: Text('Free focus (no task)'),
            ),
            for (final t in app.todo)
              DropdownMenuItem(
                value: t.id,
                child: Text(t.name, overflow: TextOverflow.ellipsis),
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
                'Lock-in mode · ON',
                style: AppText.h2.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 6),
              const Text(
                'Stay in the app until the timer ends. Leaving or ending early means the session won’t count.',
                style: AppText.body,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        AppButton(
          'Start ${mmss(_focus * 60)} focus',
          color: AppColors.leaf,
          onPressed: _start,
        ),
        const FooterNote('Lock in to ripen up.'),
      ],
    );
  }
}
