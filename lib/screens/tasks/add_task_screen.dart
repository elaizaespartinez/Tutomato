import 'package:flutter/material.dart';

import '../../core/theme/app_text.dart';
import '../../core/utils/date_helpers.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_fields.dart';
import '../../core/widgets/app_page.dart';
import '../../core/widgets/steppers.dart';
import '../../providers/app_state.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _name = TextEditingController();
  final _subject = TextEditingController();
  int _sessions = 2;
  DateTime _due = dayOnly(DateTime.now());
  String? _nameError;
  String? _subjectError;

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

  void _save() {
    final name = _name.text.trim();
    final subject = _subject.text.trim();

    setState(() {
      _nameError = name.isEmpty ? 'Give your task a name.' : null;
      _subjectError = subject.isEmpty ? 'Enter a subject.' : null;
    });
    if (name.isEmpty || subject.isEmpty) return;

    AppState.instance.addTask(
      name: name,
      subject: subject,
      due: _due,
      sessions: _sessions,
    );
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(
      SnackBar(content: Text('Added “$name” to To Learn.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Add a task',
      close: true,
      children: [
        Text(
          'Plant your next study goal.',
          style: AppText.body.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 24),
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
        const SizedBox(height: 24),
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
        const SizedBox(height: 20),
        AppPickerField(
          label: 'Due date',
          text: dueField(_due),
          onTap: _pickDate,
        ),
        const SizedBox(height: 16),
        const Text(
          'Start small. You can always add more later.',
          style: AppText.body,
        ),
        const SizedBox(height: 24),
        AppButton('Save task', onPressed: _save),
        const FooterNote('Lock in to ripen up.'),
      ],
    );
  }
}