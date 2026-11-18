import 'dart:async';

import 'package:flutter/material.dart';

import '../models/study_task.dart';
import '../theme.dart';
import '../widgets/app_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.name,
    required this.points,
    required this.tasks,
    required this.todayMinutes,
    required this.completedSessions,
    required this.onOpenProfile,
    required this.onOpenLearn,
    required this.onStartSession,
    required this.onToggleTask,
    super.key,
  });

  final String name;
  final int points;
  final List<StudyTask> tasks;
  final int todayMinutes;
  final int completedSessions;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenLearn;
  final VoidCallback onStartSession;
  final ValueChanged<String> onToggleTask;

  @override
  Widget build(BuildContext context) {
    final visibleTasks = tasks
        .where((task) => !task.isDone)
        .take(3)
        .toList(growable: false);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BrandHeader(onProfile: onOpenProfile),
          const SizedBox(height: 18),
          Text('Hi, $name!', style: AppTextStyles.heading),
          const SizedBox(height: 4),
          const Text('Ready to ripen up?', style: AppTextStyles.body),
          const SizedBox(height: 18),
          Material(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(28),
            child: InkWell(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Study points are ready to spend in your wardrobe.',
                  ),
                ),
              ),
              borderRadius: BorderRadius.circular(28),
              child: AppCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                radius: 28,
                child: Row(
                  children: [
                    const Icon(Icons.star, color: AppColors.red, size: 25),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Study Points',
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.title.copyWith(fontSize: 18),
                      ),
                    ),
                    Text(
                      '$points',
                      style: AppTextStyles.title.copyWith(fontSize: 24),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right, color: AppColors.brown),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          AppCard(
            color: AppColors.peach,
            padding: const EdgeInsets.fromLTRB(18, 18, 14, 14),
            child: Row(
              children: [
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Let’s grow\nyour focus!',
                        style: AppTextStyles.heading.copyWith(fontSize: 27),
                      ),
                      const SizedBox(height: 7),
                      const Text(
                        'One session at a time.',
                        style: AppTextStyles.body,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 46,
                        child: FilledButton(
                          onPressed: onStartSession,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: const Text('Start session'),
                        ),
                      ),
                    ],
                  ),
                ),
                const Expanded(
                  flex: 4,
                  child: Center(child: TomatoMascot(size: 132)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 5),
            child: Row(
              children: [
                _StatItem(
                  value: '$todayMinutes min',
                  label: 'Today',
                  color: AppColors.brown,
                ),
                const _StatDivider(),
                _StatItem(
                  value: '$completedSessions',
                  label: 'Sessions',
                  color: AppColors.brown,
                ),
                const _StatDivider(),
                const _StatItem(
                  value: '5 days',
                  label: 'Streak',
                  color: AppColors.green,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SectionHeader(
            'To Learn',
            trailing: TextButton(
              onPressed: onOpenLearn,
              child: const Text(
                'See all  ›',
                style: TextStyle(color: AppColors.red, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 9),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
            child: Column(
              children: [
                if (visibleTasks.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(14),
                    child: Text(
                      'Your list is clear. Nice work!',
                      style: AppTextStyles.body,
                    ),
                  )
                else
                  for (var i = 0; i < visibleTasks.length; i++) ...[
                    TaskRow(
                      task: visibleTasks[i],
                      compact: true,
                      onToggle: () => onToggleTask(visibleTasks[i].id),
                    ),
                    if (i != visibleTasks.length - 1)
                      const Divider(height: 1, color: AppColors.border),
                  ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.title.copyWith(color: color, fontSize: 21),
          ),
          const SizedBox(height: 3),
          Text(label, style: AppTextStyles.body.copyWith(fontSize: 14)),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 48, width: 1, color: AppColors.border);
  }
}

class TaskRow extends StatelessWidget {
  const TaskRow({
    required this.task,
    required this.onToggle,
    this.compact = false,
    super.key,
  });

  final StudyTask task;
  final VoidCallback onToggle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: compact ? 8 : 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: task.isDone,
            onChanged: (_) => onToggle(),
            activeColor: AppColors.green,
            side: const BorderSide(color: AppColors.border, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: AppTextStyles.title.copyWith(
                    fontSize: compact ? 15 : 19,
                    decoration: task.isDone ? TextDecoration.lineThrough : null,
                    color: task.isDone ? AppColors.muted : AppColors.brown,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${task.subject} · ${task.dueLabel.toLowerCase() == 'today' ? 'Due today' : task.dueLabel}',
                  style: AppTextStyles.body.copyWith(
                    fontSize: compact ? 13 : 15,
                  ),
                ),
                if (!compact) ...[
                  const SizedBox(height: 6),
                  Text(
                    '${task.completedSessions} / ${task.sessionsGoal} sessions',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.green,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LearnScreen extends StatefulWidget {
  const LearnScreen({
    required this.tasks,
    required this.onBack,
    required this.onAddTask,
    required this.onToggleTask,
    super.key,
  });

  final List<StudyTask> tasks;
  final VoidCallback onBack;
  final VoidCallback onAddTask;
  final ValueChanged<String> onToggleTask;

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  int _filter = 0;

  @override
  Widget build(BuildContext context) {
    final todoCount = widget.tasks.where((task) => !task.isDone).length;
    final todayTasks = widget.tasks
        .where((task) => task.dueLabel.toLowerCase() == 'today' && !task.isDone)
        .toList();
    final upcoming = widget.tasks
        .where((task) => task.dueLabel.toLowerCase() != 'today' && !task.isDone)
        .toList();
    final done = widget.tasks.where((task) => task.isDone).toList();
    final visible = switch (_filter) {
      1 => todayTasks,
      2 => done,
      _ => todayTasks,
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageTitle(title: 'To Learn', onBack: widget.onBack),
          const SizedBox(height: 20),
          const Text(
            'A little plan goes a long way.',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _FilterChip(
                label: 'To do · $todoCount',
                selected: _filter == 0,
                onTap: () => setState(() => _filter = 0),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Today · ${todayTasks.length}',
                selected: _filter == 1,
                onTap: () => setState(() => _filter = 1),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Done · ${done.length}',
                selected: _filter == 2,
                onTap: () => setState(() => _filter = 2),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SectionHeader(
            _filter == 2 ? 'Completed' : 'Today',
            trailing: Text(
              '${visible.length} tasks',
              style: AppTextStyles.body,
            ),
          ),
          const SizedBox(height: 8),
          if (visible.isEmpty)
            const AppCard(
              child: Text(
                'Nothing here yet. Add a task to get started.',
                style: AppTextStyles.body,
              ),
            )
          else
            for (final task in visible)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TaskRow(
                    task: task,
                    onToggle: () => widget.onToggleTask(task.id),
                  ),
                ),
              ),
          if (_filter == 0 && upcoming.isNotEmpty) ...[
            const SizedBox(height: 8),
            const SectionHeader('Coming up'),
            const SizedBox(height: 8),
            for (final task in upcoming)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TaskRow(
                    task: task,
                    onToggle: () => widget.onToggleTask(task.id),
                  ),
                ),
              ),
          ],
          const SizedBox(height: 14),
          PrimaryButton(
            label: '+  Add a task',
            onPressed: widget.onAddTask,
            height: 56,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => setState(() => _filter = 2),
            child: Text(
              '${done.length} completed tasks  ⌄',
              style: AppTextStyles.body,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: selected ? AppColors.green : AppColors.peach,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: TextStyle(
                color: selected ? AppColors.white : AppColors.muted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({required this.onBack, required this.onSave, super.key});

  final VoidCallback onBack;
  final ValueChanged<StudyTask> onSave;

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String _subject = 'Biology';
  String _due = 'Today';
  int _sessions = 2;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    widget.onSave(
      StudyTask(
        title: _titleController.text.trim(),
        subject: _subject,
        dueLabel: _due,
        sessionsGoal: _sessions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageTitle(title: 'Add a task', onBack: widget.onBack, size: 26),
            const SizedBox(height: 20),
            const Text(
              'Plant your next study goal.',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 20),
            const _FormLabel('Task name'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'e.g. Cell division review',
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Give your task a name'
                  : null,
            ),
            const SizedBox(height: 18),
            const _FormLabel('Subject'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _subject,
              decoration: const InputDecoration(),
              items:
                  const [
                        'Biology',
                        'Mathematics',
                        'Literature',
                        'History',
                        'Other',
                      ]
                      .map(
                        (subject) => DropdownMenuItem(
                          value: subject,
                          child: Text(subject),
                        ),
                      )
                      .toList(),
              onChanged: (value) =>
                  setState(() => _subject = value ?? _subject),
            ),
            const SizedBox(height: 18),
            const _FormLabel('How many focus sessions?'),
            const SizedBox(height: 8),
            AppCard(
              color: AppColors.peach,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              borderColor: AppColors.peach,
              child: Row(
                children: [
                  IconButton(
                    onPressed: _sessions > 1
                        ? () => setState(() => _sessions--)
                        : null,
                    icon: const Icon(Icons.remove),
                  ),
                  Expanded(
                    child: Text(
                      '$_sessions ${_sessions == 1 ? 'session' : 'sessions'}',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.title.copyWith(fontSize: 17),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _sessions++),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const _FormLabel('Due date'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _due,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.calendar_today_outlined, size: 20),
              ),
              items: const ['Today', 'Tomorrow', 'This week', 'No due date']
                  .map((due) => DropdownMenuItem(value: due, child: Text(due)))
                  .toList(),
              onChanged: (value) => setState(() => _due = value ?? _due),
            ),
            const SizedBox(height: 12),
            const Text(
              'Start small. You can always add more later.',
              style: TextStyle(color: AppColors.muted, fontSize: 13),
            ),
            const SizedBox(height: 24),
            PrimaryButton(label: 'Save task', onPressed: _save),
          ],
        ),
      ),
    );
  }
}

class _FormLabel extends StatelessWidget {
  const _FormLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.brown,
        fontWeight: FontWeight.w700,
        fontSize: 15,
      ),
    );
  }
}

class SessionSetupScreen extends StatefulWidget {
  const SessionSetupScreen({
    required this.tasks,
    required this.selectedTaskId,
    required this.onBack,
    required this.onStart,
    super.key,
  });

  final List<StudyTask> tasks;
  final String selectedTaskId;
  final VoidCallback onBack;
  final void Function(String taskId, int minutes, int breakMinutes, int rounds)
  onStart;

  @override
  State<SessionSetupScreen> createState() => _SessionSetupScreenState();
}

class _SessionSetupScreenState extends State<SessionSetupScreen> {
  late String _selectedTaskId;
  int _duration = 25;
  int _breakDuration = 5;
  int _rounds = 4;

  @override
  void initState() {
    super.initState();
    final available = widget.tasks.where((task) => !task.isDone).toList();
    _selectedTaskId = available.any((task) => task.id == widget.selectedTaskId)
        ? widget.selectedTaskId
        : available.firstOrNull?.id ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final available = widget.tasks.where((task) => !task.isDone).toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageTitle(title: 'Start a session', onBack: widget.onBack, size: 26),
          const SizedBox(height: 20),
          const Text('Pick your rhythm', style: AppTextStyles.body),
          const SizedBox(height: 14),
          Row(
            children: [
              _PresetCard(
                main: '25 / 5',
                label: 'Classic',
                selected: _duration == 25,
                onTap: () => setState(() {
                  _duration = 25;
                  _breakDuration = 5;
                }),
              ),
              const SizedBox(width: 8),
              _PresetCard(
                main: '50 / 10',
                label: 'Deep work',
                selected: _duration == 50,
                onTap: () => setState(() {
                  _duration = 50;
                  _breakDuration = 10;
                }),
              ),
              const SizedBox(width: 8),
              _PresetCard(
                main: '15 / 3',
                label: 'Quick',
                selected: _duration == 15,
                onTap: () => setState(() {
                  _duration = 15;
                  _breakDuration = 3;
                }),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _FormLabel('Or make it yours'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _StepperCard(
                  label: 'Focus',
                  value: _duration,
                  unit: 'min',
                  onChanged: (delta) => setState(
                    () => _duration = (_duration + delta).clamp(5, 90),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StepperCard(
                  label: 'Short break',
                  value: _breakDuration,
                  unit: 'min',
                  onChanged: (delta) => setState(
                    () =>
                        _breakDuration = (_breakDuration + delta).clamp(1, 30),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
            child: Row(
              children: [
                const Icon(Icons.refresh_rounded, color: AppColors.green),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Rounds', style: AppTextStyles.body),
                ),
                IconButton(
                  onPressed: _rounds > 1
                      ? () => setState(() => _rounds--)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('$_rounds×', style: AppTextStyles.title),
                IconButton(
                  onPressed: () => setState(() => _rounds++),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _FormLabel('What are you studying?'),
          const SizedBox(height: 8),
          if (available.isEmpty)
            const AppCard(
              child: Text(
                'Add a task first to begin a focus session.',
                style: AppTextStyles.body,
              ),
            )
          else
            DropdownButtonFormField<String>(
              initialValue: _selectedTaskId,
              isExpanded: true,
              decoration: const InputDecoration(),
              items: available
                  .map(
                    (task) => DropdownMenuItem(
                      value: task.id,
                      child: Text(task.title, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => _selectedTaskId = value ?? _selectedTaskId),
            ),
          const SizedBox(height: 14),
          AppCard(
            color: AppColors.peach,
            borderColor: AppColors.peach,
            child: const Row(
              children: [
                Icon(Icons.lock_outline, color: AppColors.red),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Lock-in mode · ON\nStay in the app and give your focus room to grow.',
                    style: AppTextStyles.body,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'Start $_duration:00 focus',
            color: AppColors.green,
            onPressed: available.isEmpty
                ? null
                : () => widget.onStart(
                    _selectedTaskId,
                    _duration,
                    _breakDuration,
                    _rounds,
                  ),
          ),
        ],
      ),
    );
  }
}

class _PresetCard extends StatelessWidget {
  const _PresetCard({
    required this.main,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String main;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: selected ? AppColors.peach : AppColors.card,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected ? AppColors.red : AppColors.border,
                width: selected ? 1.7 : 1,
              ),
            ),
            child: Column(
              children: [
                Text(main, style: AppTextStyles.title.copyWith(fontSize: 16)),
                const SizedBox(height: 4),
                Text(label, style: AppTextStyles.body.copyWith(fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepperCard extends StatelessWidget {
  const _StepperCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.onChanged,
  });

  final String label;
  final int value;
  final String unit;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.peach,
      borderColor: AppColors.peach,
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Text(label, style: AppTextStyles.body.copyWith(fontSize: 13)),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _RoundControl(icon: Icons.remove, onTap: () => onChanged(-1)),
              const SizedBox(width: 4),
              Text(
                '$value $unit',
                style: AppTextStyles.title.copyWith(fontSize: 14),
              ),
              const SizedBox(width: 4),
              _RoundControl(icon: Icons.add, onTap: () => onChanged(1)),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundControl extends StatelessWidget {
  const _RoundControl({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: CircleAvatar(
        radius: 12,
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.red,
        child: Icon(icon, size: 15),
      ),
    );
  }
}

class FocusSessionScreen extends StatefulWidget {
  const FocusSessionScreen({
    required this.title,
    required this.subject,
    required this.durationMinutes,
    required this.rounds,
    required this.onEnd,
    required this.onComplete,
    super.key,
  });

  final String title;
  final String subject;
  final int durationMinutes;
  final int rounds;
  final VoidCallback onEnd;
  final VoidCallback onComplete;

  @override
  State<FocusSessionScreen> createState() => _FocusSessionScreenState();
}

class _FocusSessionScreenState extends State<FocusSessionScreen> {
  late int _secondsRemaining;
  Timer? _timer;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.durationMinutes * 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _isPaused) return;
      if (_secondsRemaining <= 1) {
        _timer?.cancel();
        widget.onComplete();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _timeLabel {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _confirmEnd() async {
    final endNow = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cream,
        title: const Text('End this session?'),
        content: const Text(
          'Ending early means this focus session won’t count toward your growth.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep focusing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'End session',
              style: TextStyle(color: AppColors.red),
            ),
          ),
        ],
      ),
    );
    if (endNow == true) {
      _timer?.cancel();
      widget.onEnd();
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        (1 - (_secondsRemaining / (widget.durationMinutes * 60)).clamp(0, 1))
            .toDouble();
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 26),
      child: Column(
        children: [
          PageTitle(title: 'Focus session', size: 27),
          const SizedBox(height: 22),
          SizedBox(
            width: 286,
            height: 286,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 9,
                    strokeCap: StrokeCap.round,
                    backgroundColor: AppColors.peach,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.red,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _timeLabel,
                      style: AppTextStyles.heading.copyWith(fontSize: 51),
                    ),
                    Text(
                      'of ${widget.durationMinutes}:00 · Round 1 of ${widget.rounds}',
                      style: AppTextStyles.body.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 15),
                    const TomatoMascot(size: 94),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.rounds.clamp(1, 6),
              (index) => Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: index == 0 ? AppColors.red : AppColors.peach,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          AppCard(
            color: AppColors.peach,
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: AppTextStyles.heading.copyWith(fontSize: 23),
                  ),
                  const SizedBox(height: 5),
                  Text('$subjectLabel · Due today', style: AppTextStyles.body),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '★  +25 Study Points when you finish',
            style: AppTextStyles.body.copyWith(color: AppColors.green),
          ),
          const SizedBox(height: 18),
          AppCard(
            child: Row(
              children: [
                const Icon(Icons.lock_outline, color: AppColors.green),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lock-in mode is on',
                        style: AppTextStyles.title,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Leaving the app or ending early won’t count.',
                        style: AppTextStyles.body.copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: _confirmEnd,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              foregroundColor: AppColors.red,
              side: const BorderSide(color: AppColors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: const Text('End session'),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => setState(() => _isPaused = !_isPaused),
            icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
            label: Text(_isPaused ? 'Resume focus' : 'Pause timer'),
            style: TextButton.styleFrom(foregroundColor: AppColors.muted),
          ),
          const SizedBox(height: 4),
          const Text(
            'Stay here until the timer ends.',
            style: AppTextStyles.body,
          ),
        ],
      ),
    );
  }

  String get subjectLabel => widget.subject;
}

class SessionCompleteScreen extends StatelessWidget {
  const SessionCompleteScreen({
    required this.taskTitle,
    required this.taskIsDone,
    required this.points,
    required this.totalPoints,
    required this.onMarkDone,
    required this.onStartBreak,
    required this.onHome,
    super.key,
  });

  final String taskTitle;
  final bool taskIsDone;
  final int points;
  final int totalPoints;
  final VoidCallback onMarkDone;
  final VoidCallback onStartBreak;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageTitle(title: 'Your little win', onBack: onHome, size: 26),
          const SizedBox(height: 28),
          const Center(child: TomatoMascot(size: 176)),
          const SizedBox(height: 12),
          const Center(
            child: Text('Session complete!', style: AppTextStyles.heading),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              '25 min on $taskTitle',
              textAlign: TextAlign.center,
              style: AppTextStyles.body,
            ),
          ),
          const SizedBox(height: 22),
          AppCard(
            child: Column(
              children: [
                _RewardRow(
                  label: 'Study Points',
                  value: '+$points',
                  valueColor: AppColors.green,
                ),
                const Divider(color: AppColors.border),
                const _RewardRow(label: 'Pomodori ripeness', value: '+8%'),
                const Divider(color: AppColors.border),
                const _RewardRow(
                  label: 'Daily streak',
                  value: '5 days',
                  valueColor: AppColors.green,
                ),
                const SizedBox(height: 12),
                Text(
                  '$totalPoints points total · Pip is 46% ripe',
                  style: AppTextStyles.body.copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Material(
            color: AppColors.peach,
            borderRadius: BorderRadius.circular(22),
            child: InkWell(
              onTap: onMarkDone,
              borderRadius: BorderRadius.circular(22),
              child: AppCard(
                color: AppColors.peach,
                borderColor: AppColors.peach,
                child: Row(
                  children: [
                    Icon(
                      taskIsDone
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: AppColors.red,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        taskIsDone
                            ? 'Task marked as done'
                            : 'Mark “$taskTitle” as done',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.brown,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'Start a 5-minute break',
            color: AppColors.green,
            onPressed: onStartBreak,
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: onHome,
              child: const Text(
                'Back to Home',
                style: TextStyle(color: AppColors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardRow extends StatelessWidget {
  const _RewardRow({
    required this.label,
    required this.value,
    this.valueColor = AppColors.brown,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.body)),
          Text(
            value,
            style: AppTextStyles.title.copyWith(
              color: valueColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
