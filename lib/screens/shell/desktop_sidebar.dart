import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/async_utils.dart';
import '../../core/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../models/user_profile.dart';
import '../../providers/data_providers.dart';

class DesktopSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onCreate;

  const DesktopSidebar({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    required this.onCreate,
  });

  static const _items = [
    (icon: Icons.home_outlined, label: 'Home'),
    (icon: Icons.eco_outlined, label: 'Pomodori'),
    (icon: Icons.bar_chart, label: 'Records'),
    (icon: Icons.people_outline, label: 'Friends'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 264,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Tutomato',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.tomato,
            ),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add),
            label: const Text('Create'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.tomato,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 24),
          for (var i = 0; i < _items.length; i++)
            _SideItem(
              icon: _items[i].icon,
              label: _items[i].label,
              selected: selectedIndex == i,
              onTap: () => onSelect(i),
            ),
          const Spacer(),
          const _ProfileTile(),
          const SizedBox(height: 12),
          const Text(
            'Lock in to ripen up.',
            textAlign: TextAlign.center,
            style: AppText.small,
          ),
        ],
      ),
    );
  }
}

class _SideItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SideItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.tomato : AppColors.brownSoft;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: selected ? AppColors.peach : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          hoverColor: AppColors.peach.withValues(alpha: 0.6),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileTile extends ConsumerWidget {
  const _ProfileTile();

  static final _fallbackProfile = UserProfile(
    uid: '',
    displayName: 'Student',
    email: '',
    createdAt: DateTime.now(),
    points: 0,
    level: 1,
    ripeness: 0,
    currentStreak: 0,
    bestStreak: 0,
    lastActiveDay: null,
    todayDay: null,
    todayMinutes: 0,
    todaySessions: 0,
    totalSessions: 0,
    totalFocusMinutes: 0,
    equipped: const EquippedItems(),
    ownedItemIds: const [],
    settings: const TimerSettings(),
    inviteCode: '',
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).dataOrNull ?? _fallbackProfile;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: AppColors.border),
    );
    return Material(
      color: AppColors.cream,
      shape: shape,
      child: InkWell(
        customBorder: shape,
        onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.tomato,
                child: Icon(Icons.person_outline, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.title,
                    ),
                    const Text('Student', style: AppText.small),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.brownSoft),
            ],
          ),
        ),
      ),
    );
  }
}