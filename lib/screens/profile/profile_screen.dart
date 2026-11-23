import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_exception.dart';
import '../../core/async_utils.dart';
import '../../core/constants.dart';
import '../../core/format.dart';
import '../../core/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_page.dart';
import '../../models/user_profile.dart';
import '../../providers/actions.dart';
import '../../providers/auth_controller.dart';
import '../../providers/data_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<T?> _pickOne<T>(
      BuildContext context,
      String title,
      List<({T value, String label})> options,
      ) {
    return showDialog<T>(
      context: context,
      builder: (ctx) => SimpleDialog(
        backgroundColor: AppColors.cream,
        title: Text(title),
        children: [
          for (final o in options)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, o.value),
              child: Text(o.label, style: const TextStyle(fontSize: 17)),
            ),
        ],
      ),
    );
  }

  Future<void> _editName(BuildContext context, WidgetRef ref, UserProfile profile) async {
    final controller = TextEditingController(text: profile.displayName);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cream,
        title: const Text('Personal information'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Your name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name != null && name.isNotEmpty) {
      try {
        await ref.read(actionsProvider).updateName(name);
      } on AppException catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message), backgroundColor: AppColors.tomato),
          );
        }
      }
    }
  }

  Future<void> _pickRhythm(BuildContext context, WidgetRef ref, UserProfile profile) async {
    final index = await _pickOne<int>(context, 'Timer preferences', [
      for (var i = 0; i < AppConstants.presets.length; i++)
        (
        value: i,
        label:
        '${AppConstants.presets[i].focus} / ${AppConstants.presets[i].rest} min · ${AppConstants.presets[i].name}',
        ),
    ]);
    if (index != null) {
      final p = AppConstants.presets[index];
      await ref.read(actionsProvider).updateSettings(
            profile.settings.copyWith(
              focusMinutes: p.focus,
              breakMinutes: p.rest,
            ),
          );
    }
  }

  Future<void> _pickGoal(BuildContext context, WidgetRef ref, UserProfile profile) async {
    final goal = await _pickOne<int>(context, 'Daily focus goal', [
      for (final n in const [2, 3, 4, 5, 6, 8])
        (value: n, label: '$n sessions'),
    ]);
    if (goal != null) {
      await ref.read(actionsProvider).updateSettings(
            profile.settings.copyWith(dailyGoalSessions: goal),
          );
    }
  }

  Widget _header(UserProfile profile) {
    return AppCard(
      color: AppColors.peach,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 44,
            backgroundColor: AppColors.tomato,
            child: Icon(Icons.person_outline, size: 56, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile.displayName, style: AppText.h2.copyWith(fontSize: 28)),
                const SizedBox(height: 2),
                Text(profile.email, style: AppText.body),
                const SizedBox(height: 6),
                Text(
                  'Growing since ${growingSinceLabel(profile.createdAt)}',
                  style: const TextStyle(color: AppColors.leaf, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _accountSection(BuildContext context, WidgetRef ref, UserProfile profile) => [
    const SizedBox(height: 24),
    Text('Account', style: AppText.h2.copyWith(fontSize: 26)),
    const SizedBox(height: 12),
    AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _SettingRow(
            title: 'Personal information',
            onTap: () => _editName(context, ref, profile),
          ),
          const Divider(height: 1, color: AppColors.border),
          _SettingRow(
            title: 'Password reset',
            onTap: () async {
              try {
                await ref.read(authControllerProvider.notifier).sendPasswordReset(profile.email);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password reset link sent to your email!'),
                      backgroundColor: AppColors.leaf,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.tomato),
                  );
                }
              }
            },
          ),
        ],
      ),
    ),
  ];

  List<Widget> _preferencesSection(BuildContext context, WidgetRef ref, UserProfile profile) => [
    const SizedBox(height: 24),
    Text('Make it yours', style: AppText.h2.copyWith(fontSize: 26)),
    const SizedBox(height: 12),
    AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _SettingRow(
            title: 'Timer preferences',
            subtitle: '${profile.settings.focusMinutes} / ${profile.settings.breakMinutes} min',
            onTap: () => _pickRhythm(context, ref, profile),
          ),
          const Divider(height: 1, color: AppColors.border),
          _SettingRow(
            title: 'Daily focus goal',
            subtitle: '${profile.settings.dailyGoalSessions} sessions',
            onTap: () => _pickGoal(context, ref, profile),
          ),
          const Divider(height: 1, color: AppColors.border),
          _SettingRow(
            title: 'Sound & reminders',
            subtitle: profile.settings.soundEnabled ? 'On' : 'Off',
            onTap: () => ref.read(actionsProvider).updateSettings(
                  profile.settings.copyWith(soundEnabled: !profile.settings.soundEnabled),
                ),
            trailing: Switch(
              value: profile.settings.soundEnabled,
              activeThumbColor: AppColors.leaf,
              onChanged: (v) => ref.read(actionsProvider).updateSettings(
                    profile.settings.copyWith(soundEnabled: v),
                  ),
            ),
          ),
        ],
      ),
    ),
    const SizedBox(height: 24),
    AppButton(
      'Log out',
      kind: AppButtonKind.outlined,
      onPressed: () async {
        await ref.read(authControllerProvider.notifier).signOut();
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.welcome,
            (route) => false,
          );
        }
      },
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final desktop = Responsive.isDesktop(context);
    final profile = ref.watch(userProfileProvider).dataOrNull ?? UserProfile.fallback();

    return AppPage(
      title: 'Your profile',
      maxWidth: desktop ? 980 : 600,
      children: [
        _header(profile),
        LayoutBuilder(
          builder: (context, c) {
            final account = _accountSection(context, ref, profile);
            final prefs = _preferencesSection(context, ref, profile);
            if (c.maxWidth < 760) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [...account, ...prefs],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: account,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: prefs,
                  ),
                ),
              ],
            );
          },
        ),
        const FooterNote('Tutomato · Lock in to ripen up'),
      ],
    );
  }
}

class _SettingRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const _SettingRow({
    required this.title,
    this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppColors.brown,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: AppText.small),
                  ],
                ],
              ),
            ),
            trailing ??
                const Icon(Icons.chevron_right, color: AppColors.brownSoft),
          ],
        ),
      ),
    );
  }
}