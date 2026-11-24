import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/date_helpers.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_fields.dart';
import '../../core/widgets/app_page.dart';
import '../../core/widgets/steppers.dart';
import '../../providers/actions.dart';

const double _kWideBreakpoint = 800;

class AddTaskScreen extends ConsumerStatefulWidget {
  const AddTaskScreen({super.key});

  @override
  ConsumerState<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends ConsumerState<AddTaskScreen> {
  final _name = TextEditingController();
  final _subject = TextEditingController();
  int _sessions = 2;
  DateTime _due = dayOnly(DateTime.now());
  String? _nameError;
  String? _subjectError;
  bool _isLoading = false;

  @override
  void dispose() {
    _name.dispose();
    _subject.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = dayOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _due.isBefore(today) ? today : _due,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
    );
    if (picked != null && mounted) setState(() => _due = picked);
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final subject = _subject.text.trim();

    setState(() {
      _nameError = name.isEmpty ? 'Give your task a name.' : null;
      _subjectError = subject.isEmpty ? 'Enter a subject.' : null;
    });
    if (name.isEmpty || subject.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(actionsProvider).addTask(
            title: name,
            subject: subject,
            plannedSessions: _sessions,
            dueDate: _due,
          );
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        Navigator.pop(context);
        messenger.showSnackBar(
          SnackBar(content: Text('Added “$name” to To Learn.')),
        );
      }
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: AppColors.tomato),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding task: $e'), backgroundColor: AppColors.tomato),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _intro() => Text(
    'Plant your next study goal.',
    style: AppText.body.copyWith(fontSize: 18),
  );

  List<Widget> _nameAndSubject() => [
    AppTextField(
      label: 'Task name',
      boldLabel: false,
      hint: 'e.g. Cell division review',
      controller: _name,
      error: _nameError,
      onChanged: (_) {
        if (_nameError != null) setState(() => _nameError = null);
      },
    ),
    const SizedBox(height: 20),
    AppTextField(
      label: 'Subject',
      boldLabel: false,
      hint: 'e.g. English, Mathematics',
      controller: _subject,
      error: _subjectError,
      onChanged: (_) {
        if (_subjectError != null) setState(() => _subjectError = null);
      },
    ),
  ];

  List<Widget> _sessionsSection() => [
    Text(
      'How many focus sessions?',
      style: AppText.h2.copyWith(fontSize: 20),
    ),
    const SizedBox(height: 4),
    const Text('One session = 25 minutes of focus', style: AppText.body),
    const SizedBox(height: 12),
    StepperBar(
      label: '$_sessions ${_sessions == 1 ? 'session' : 'sessions'}',
      onMinus: _sessions > 1 ? () => setState(() => _sessions--) : null,
      onPlus: _sessions < 12 ? () => setState(() => _sessions++) : null,
    ),
  ];

  Widget _dueDate() => AppPickerField(
    label: 'Due date',
    text: dueField(_due),
    onTap: _pickDate,
  );

  Widget _hint() => const Text(
    'Start small. You can always add more later.',
    style: AppText.body,
  );

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= _kWideBreakpoint;

    if (wide) {
      return AppPage(
        title: 'Add a task',
        close: true,
        maxWidth: 980,
        children: [
          _intro(),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ..._nameAndSubject(),
                    const SizedBox(height: 20),
                    _dueDate(),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ..._sessionsSection(),
                    const SizedBox(height: 16),
                    _hint(),
                    const SizedBox(height: 24),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator(color: AppColors.tomato))
                        : AppButton('Save task', onPressed: _save),
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
      title: 'Add a task',
      close: true,
      children: [
        _intro(),
        const SizedBox(height: 24),
        ..._nameAndSubject(),
        const SizedBox(height: 24),
        ..._sessionsSection(),
        const SizedBox(height: 20),
        _dueDate(),
        const SizedBox(height: 16),
        _hint(),
        const SizedBox(height: 24),
        _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.tomato))
            : AppButton('Save task', onPressed: _save),
        const FooterNote('Lock in to ripen up.'),
      ],
    );
  }
}