import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/async_utils.dart';
import '../../core/format.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/date_helpers.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/tab_page.dart';
import '../../logic/records.dart';
import '../../models/user_profile.dart';
import '../../providers/data_providers.dart';

class RecordsScreen extends ConsumerWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedWeek = ref.watch(selectedWeekProvider);
    final stats = ref.watch(weeklyStatsProvider(selectedWeek));
    final profile = ref.watch(userProfileProvider).dataOrNull ?? UserProfile.fallback();

    final todayIndex = DateTime.now().weekday - 1;
    final totalMinutes = stats.totalMinutes;
    final totalSessions = stats.totalSessions;
    final dayMinutes = stats.dayMinutes;

    return TabPage(
      title: 'Your records',
      subtitle: 'Look how far you’ve grown.',
      sideChildren: [
        const SizedBox(height: 24),
        Text('Your consistency', style: AppText.h2.copyWith(fontSize: 26)),
        const SizedBox(height: 12),
        AppCard(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: _Streak(
                  '${profile.currentStreak} ${profile.currentStreak == 1 ? 'day' : 'days'}',
                  'Current streak',
                  AppColors.leaf,
                ),
              ),
              Expanded(
                child: _Streak(
                  '${profile.bestStreak} ${profile.bestStreak == 1 ? 'day' : 'days'}',
                  'Best streak',
                  AppColors.brown,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('Today’s sessions', style: AppText.h2.copyWith(fontSize: 26)),
        const SizedBox(height: 12),
        if (stats.todaySessions.isEmpty)
          const Text(
            'No sessions yet today. Start one to see it here.',
            style: AppText.body,
          )
        else
          for (final s in stats.todaySessions)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${s.subject ?? 'Free study'} · ${s.plannedMinutes} min',
                      style: AppText.body.copyWith(fontSize: 17),
                    ),
                  ),
                  Text(
                    formatTimeOfDay(s.startedAt),
                    style: AppText.body.copyWith(fontSize: 17),
                  ),
                ],
              ),
            ),
      ],
      children: [
        _periodPill(context, ref, selectedWeek),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _BigStat(formatMinutes(totalMinutes), 'Focus time'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _BigStat('$totalSessions', 'Sessions completed'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AppCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'A week of showing up',
                style: AppText.h2.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 4),
              const Text('Minutes focused', style: AppText.body),
              const SizedBox(height: 16),
              _WeekChart(
                minutes: dayMinutes,
                todayIndex: todayIndex,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _periodPill(BuildContext context, WidgetRef ref, DateTime selectedWeek) {
    return Material(
      color: AppColors.card,
      shape: const StadiumBorder(side: BorderSide(color: AppColors.border)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: () {
          // Toggle between this week and last week
          final now = DateTime.now();
          if (sameDay(selectedWeek, now)) {
            ref.read(selectedWeekProvider.notifier).state = now.subtract(const Duration(days: 7));
          } else {
            ref.read(selectedWeekProvider.notifier).state = now;
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  weekRangeLabel(selectedWeek),
                  style: AppText.h2.copyWith(fontSize: 18),
                ),
              ),
              const Icon(Icons.keyboard_arrow_down, color: AppColors.brown),
            ],
          ),
        ),
      ),
    );
  }
}

class _BigStat extends StatelessWidget {
  final String value;
  final String label;
  const _BigStat(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppText.h1.copyWith(fontSize: 36, color: AppColors.tomato),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: AppText.body),
        ],
      ),
    );
  }
}

class _Streak extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _Streak(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(value, style: AppText.h2.copyWith(fontSize: 28, color: color)),
      const SizedBox(height: 4),
      Text(label, style: AppText.body),
    ],
  );
}

class _WeekChart extends StatelessWidget {
  final List<int> minutes;
  final int todayIndex;
  const _WeekChart({required this.minutes, required this.todayIndex});

  static const _letters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final biggest = minutes.fold<int>(0, (a, b) => math.max(a, b));
    final scale = biggest == 0 ? 1 : biggest;
    return SizedBox(
      height: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var i = 0; i < 7; i++)
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('${minutes[i]}', style: AppText.small),
                const SizedBox(height: 6),
                Container(
                  width: 30,
                  height: minutes[i] == 0
                      ? 4
                      : math.max(8.0, 130.0 * minutes[i] / scale),
                  decoration: BoxDecoration(
                    color: minutes[i] == 0
                        ? AppColors.peach
                        : (i == todayIndex ? AppColors.tomato : AppColors.leaf),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(_letters[i], style: AppText.body),
              ],
            ),
        ],
      ),
    );
  }
}