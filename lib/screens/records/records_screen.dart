import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/date_helpers.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/tab_page.dart';
import '../../providers/app_state.dart';

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key});

  AppState get app => AppState.instance;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final totalMinutes = app.weekMinutes.fold<int>(0, (a, b) => a + b);
        final totalSessions = app.weekSessions.fold<int>(0, (a, b) => a + b);

        return TabPage(
          title: 'Your records',
          subtitle: 'Look how far you’ve grown.',
          children: [
            _periodPill(context),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _BigStat(hoursMinutes(totalMinutes), 'Focus time'),
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
                    minutes: app.weekMinutes,
                    todayIndex: DateTime.now().weekday - 1,
                  ),
                ],
              ),
            ),
          ],
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
                      '${app.streak} ${app.streak == 1 ? 'day' : 'days'}',
                      'Current streak',
                      AppColors.leaf,
                    ),
                  ),
                  Expanded(
                    child: _Streak(
                      '${app.bestStreak} ${app.bestStreak == 1 ? 'day' : 'days'}',
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
            if (app.todaySessions.isEmpty)
              const Text(
                'No sessions yet today. Start one to see it here.',
                style: AppText.body,
              )
            else
              for (final s in app.todaySessions)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${s.subject} · ${s.minutes} min',
                          style: AppText.body.copyWith(fontSize: 17),
                        ),
                      ),
                      Text(
                        timeLabel(s.at),
                        style: AppText.body.copyWith(fontSize: 17),
                      ),
                    ],
                  ),
                ),
          ],
        );
      },
    );
  }

  Widget _periodPill(BuildContext context) {
    return Material(
      color: AppColors.card,
      shape: const StadiumBorder(side: BorderSide(color: AppColors.border)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('More date ranges are coming soon.')),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'This week · ${weekRangeLabel(DateTime.now())}',
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
