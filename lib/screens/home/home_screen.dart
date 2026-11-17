import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/date_helpers.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/pomodori_image.dart';
import '../../core/widgets/profile_button.dart';
import '../../providers/app_state.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onOpenPomodori;
  const HomeScreen({super.key, required this.onOpenPomodori});

  AppState get app => AppState.instance;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) => Responsive.isDesktop(context)
          ? _desktopLayout(context)
          : _phoneLayout(context),
    );
  }

  String get _streakText => '${app.streak} ${app.streak == 1 ? 'day' : 'days'}';

  // Phone and tablet: same as the design
  Widget _phoneLayout(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        const Row(
          children: [
            Text(
              'Tutomato',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: AppColors.tomato,
              ),
            ),
            Spacer(),
            ProfileButton(),
          ],
        ),
        const SizedBox(height: 20),
        Text('Hi, ${app.userName}!', style: AppText.h1),
        const SizedBox(height: 4),
        const Text('Ready to ripen up?', style: AppText.body),
        const SizedBox(height: 20),
        _pointsPill(),
        const SizedBox(height: 16),
        _heroCard(context),
        const SizedBox(height: 16),
        _statsCard(),
        const SizedBox(height: 24),
        _sectionHeader(context),
        const SizedBox(height: 12),
        _taskList(context),
      ],
    );
  }

  // Laptop
  Widget _desktopLayout(BuildContext context) {
    final overview = Column(
      children: [
        _desktopHero(context),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                value: '${app.todayMinutes} min',
                label: 'Today',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatTile(
                value: '${app.todaySessions.length}',
                label: 'Sessions',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatTile(
                value: _streakText,
                label: 'Streak',
                valueColor: AppColors.leaf,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _GoalCard(done: app.todaySessions.length, goal: app.dailyGoal),
      ],
    );

    final learn = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionHeader(context),
        const SizedBox(height: 12),
        _taskList(context),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.addTask),
          icon: const Icon(Icons.add),
          label: const Text('Add a task'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.tomato,
            side: const BorderSide(color: AppColors.tomato),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 20),
        _PipCard(onTap: onOpenPomodori),
      ],
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(40, 36, 40, 40),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi, ${app.userName}!',
                    style: AppText.h1.copyWith(fontSize: 40),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Ready to ripen up?',
                    style: TextStyle(fontSize: 17, color: AppColors.brownSoft),
                  ),
                ],
              ),
            ),
            SizedBox(width: 300, child: _pointsPill()),
          ],
        ),
        const SizedBox(height: 28),
        LayoutBuilder(
          builder: (context, c) {
            // Not enough room for two columns: stack them
            if (c.maxWidth < 840) {
              return Column(
                children: [overview, const SizedBox(height: 24), learn],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 6, child: overview),
                const SizedBox(width: 24),
                Expanded(flex: 4, child: learn),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _desktopHero(BuildContext context) {
    return AppCard(
      color: AppColors.peach,
      padding: const EdgeInsets.all(32),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Let’s grow your focus!',
                  style: AppText.h2.copyWith(fontSize: 36, height: 1.1),
                ),
                const SizedBox(height: 8),
                const Text(
                  'One session at a time.',
                  style: TextStyle(fontSize: 18, color: AppColors.brownSoft),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.sessionSetup),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.tomato,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 18,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  child: const Text('Start session'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const PomodoriImage(size: 170),
        ],
      ),
    );
  }

  Widget _pointsPill() {
    return Material(
      color: AppColors.card,
      shape: const StadiumBorder(side: BorderSide(color: AppColors.border)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onOpenPomodori,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              const Icon(Icons.star, color: AppColors.tomato),
              const SizedBox(width: 14),
              const Text('Study Points', style: AppText.title),
              const Spacer(),
              Text('${app.points}', style: AppText.h2),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, color: AppColors.brown),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heroCard(BuildContext context) {
    return AppCard(
      color: AppColors.peach,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Let’s grow your focus!',
                  style: AppText.h2.copyWith(fontSize: 28, height: 1.15),
                ),
                const SizedBox(height: 6),
                const Text('One session at a time.', style: AppText.body),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.sessionSetup),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.tomato,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  child: const Text('Start session'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const PomodoriImage(size: 110),
        ],
      ),
    );
  }

  Widget _statsCard() {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _Stat(value: '${app.todayMinutes} min', label: 'Today'),
            const VerticalDivider(color: AppColors.border, width: 1),
            _Stat(value: '${app.todaySessions.length}', label: 'Sessions'),
            const VerticalDivider(color: AppColors.border, width: 1),
            _Stat(
              value: _streakText,
              label: 'Streak',
              valueColor: AppColors.leaf,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context) {
    return Row(
      children: [
        const Text('To Learn', style: AppText.h2),
        const Spacer(),
        InkWell(
          onTap: () => Navigator.pushNamed(context, AppRoutes.toLearn),
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Text(
              'See all ›',
              style: TextStyle(color: AppColors.tomato, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _taskList(BuildContext context) {
    final items = app.todo.take(3).toList();
    if (items.isEmpty) {
      return const AppCard(
        padding: EdgeInsets.all(20),
        child: Text(
          'All caught up! Tap + to plant your next study goal.',
          style: AppText.body,
        ),
      );
    }
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppColors.border),
            _TaskRow(
              title: items[i].name,
              meta: '${shortDue(items[i].due)} · ${items[i].subject}',
              onToggle: () => app.toggleTask(items[i].id),
              onOpen: () => Navigator.pushNamed(
                context,
                AppRoutes.sessionSetup,
                arguments: items[i].id,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;

  const _Stat({
    required this.value,
    required this.label,
    this.valueColor = AppColors.brown,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(value, style: AppText.h2.copyWith(color: valueColor)),
        const SizedBox(height: 4),
        Text(label, style: AppText.body),
      ],
    ),
  );
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;

  const _StatTile({
    required this.value,
    required this.label,
    this.valueColor = AppColors.brown,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: AppText.h2.copyWith(fontSize: 32, color: valueColor),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.body,
          ),
        ],
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  final String title;
  final String meta;
  final VoidCallback onToggle;
  final VoidCallback onOpen;

  const _TaskRow({
    required this.title,
    required this.meta,
    required this.onToggle,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpen,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            GestureDetector(
              onTap: onToggle,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 2),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppText.title),
                  const SizedBox(height: 2),
                  Text(meta, style: AppText.small),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final int done;
  final int goal;
  const _GoalCard({required this.done, required this.goal});

  @override
  Widget build(BuildContext context) {
    final left = goal > done ? goal - done : 0;
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Today’s goal', style: AppText.h2),
              const Spacer(),
              Text('$done of $goal sessions', style: AppText.title),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: goal == 0 ? 0 : (done / goal).clamp(0.0, 1.0),
              minHeight: 14,
              backgroundColor: AppColors.peach,
              color: AppColors.leaf,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            left == 0
                ? 'Goal reached. Your Pomodori is proud!'
                : '$left more ${left == 1 ? 'session' : 'sessions'} to reach your daily goal.',
            style: AppText.body,
          ),
        ],
      ),
    );
  }
}

class _PipCard extends StatelessWidget {
  final VoidCallback onTap;
  const _PipCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
      side: const BorderSide(color: AppColors.border),
    );
    return Material(
      color: AppColors.peach,
      shape: shape,
      child: InkWell(
        customBorder: shape,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const PomodoriImage(size: 72),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Looking ripe, ${app.petName}!', style: AppText.title),
                    const SizedBox(height: 4),
                    Text(
                      'Level ${app.level} · Ripeness ${(app.ripeness * 100).round()}%',
                      style: AppText.small,
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: app.ripeness.clamp(0.0, 1.0),
                        minHeight: 10,
                        backgroundColor: Colors.white,
                        color: AppColors.leaf,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
