import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_page.dart';
import '../../core/widgets/pill_chip.dart';
import '../../models/study_task.dart';
import '../../providers/actions.dart';
import '../../providers/data_providers.dart';

class ToLearnScreen extends ConsumerStatefulWidget {
  const ToLearnScreen({super.key});

  @override
  ConsumerState<ToLearnScreen> createState() => _ToLearnScreenState();
}

class _ToLearnScreenState extends ConsumerState<ToLearnScreen> {
  int _filter = 0; // 0 To do, 1 Today, 2 Done
  bool _showCompleted = false;

  Future<void> _confirmRemove(StudyTask t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove task?'),
        content: Text('“${t.title}” will be removed from your list.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await ref.read(actionsProvider).deleteTask(t.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Removed “${t.title}”.')),
        );
      }
    }
  }

  Widget _card(StudyTask t) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: _TaskCard(
      task: t,
      onToggle: () => ref.read(actionsProvider).setTaskDone(t.id, !t.isDone),
      onDelete: () => _confirmRemove(t),
      onOpen: t.isDone
          ? null
          : () => Navigator.pushNamed(
        context,
        AppRoutes.sessionSetup,
        arguments: t.id,
      ),
    ),
  );

  List<Widget> _section(
      String title,
      List<StudyTask> list, {
        bool showCount = true,
        String empty = '',
      }) {
    return [
      Row(
        children: [
          Text(title, style: AppText.h2),
          const Spacer(),
          if (showCount)
            Text(
              '${list.length} ${list.length == 1 ? 'task' : 'tasks'}',
              style: AppText.body,
            ),
        ],
      ),
      const SizedBox(height: 12),
      if (list.isEmpty)
        AppCard(
          padding: const EdgeInsets.all(20),
          child: Text(empty, style: AppText.body),
        )
      else
        for (final t in list) _card(t),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final taskGroups = ref.watch(taskGroupsProvider);
    final todo = taskGroups.todo;
    final today = taskGroups.today;
    final upcoming = taskGroups.upcoming;
    final done = taskGroups.completed;

    return AppPage(
      title: 'To Learn',
      maxWidth: Responsive.isDesktop(context) ? 980 : 600,
      children: [
        Text(
          'A little plan goes a long way.',
          style: AppText.body.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: PillChip(
                label: 'To do · ${todo.length}',
                selected: _filter == 0,
                onTap: () => setState(() => _filter = 0),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: PillChip(
                label: 'Today · ${today.length}',
                selected: _filter == 1,
                onTap: () => setState(() => _filter = 1),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: PillChip(
                label: 'Done · ${done.length}',
                selected: _filter == 2,
                onTap: () => setState(() => _filter = 2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (_filter == 2)
          ..._section('Done', done, empty: 'No finished tasks yet.')
        else
          LayoutBuilder(
            builder: (context, c) {
              final todaySection = _section(
                'Today',
                today,
                empty:
                'Nothing due today. Add a task to plant your next goal.',
              );
              final upcomingSection = (_filter == 0 && upcoming.isNotEmpty)
                  ? _section('Coming up', upcoming, showCount: false)
                  : <Widget>[];
              if (c.maxWidth < 760 || upcomingSection.isEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...todaySection,
                    if (upcomingSection.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ...upcomingSection,
                    ],
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: todaySection,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: upcomingSection,
                    ),
                  ),
                ],
              );
            },
          ),
        const SizedBox(height: 12),
        AppButton(
          'Add a task',
          icon: Icons.add,
          onPressed: () => Navigator.pushNamed(context, AppRoutes.addTask),
        ),
        if (_filter != 2 && done.isNotEmpty) ...[
          InkWell(
            onTap: () => setState(() => _showCompleted = !_showCompleted),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  Text(
                    '${done.length} completed ${done.length == 1 ? 'task' : 'tasks'}',
                    style: AppText.body,
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _showCompleted
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.brownSoft,
                  ),
                ],
              ),
            ),
          ),
          if (_showCompleted)
            for (final t in done) _card(t),
        ],
      ],
    );
  }
}

class _TaskCard extends StatelessWidget {
  final StudyTask task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback? onOpen;

  const _TaskCard({
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final done = task.isDone;
    return AppCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  width: 30,
                  height: 30,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: done ? AppColors.leaf : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: done ? AppColors.leaf : AppColors.brownSoft,
                      width: 2,
                    ),
                  ),
                  child: done
                      ? const Icon(Icons.check, size: 20, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: AppText.title.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        decoration: done ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${task.subject} · ${done ? 'Completed' : dueLabel(task.dueDay)}',
                      style: AppText.body,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      sessionsLabel(task.completedSessions, task.plannedSessions),
                      style: const TextStyle(
                        color: AppColors.leaf,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Remove task',
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                icon: const Icon(
                  Icons.remove,
                  color: AppColors.brownSoft,
                ),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}