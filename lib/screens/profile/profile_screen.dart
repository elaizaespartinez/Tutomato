import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_page.dart';
import '../../providers/app_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  AppState get app => AppState.instance;

  void _soon(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

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

  Future<void> _editName(BuildContext context) async {
    final controller = TextEditingController(text: app.fullName);
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
      app.update(() {
        app.fullName = name;
        app.userName = name.split(' ').first;
      });
    }
  }

  Future<void> _pickRhythm(BuildContext context) async {
    final index = await _pickOne<int>(context, 'Timer preferences', [
      for (var i = 0; i < kPresets.length; i++)
        (
        value: i,
        label:
        '${kPresets[i].focus} / ${kPresets[i].rest} min · ${kPresets[i].name}',
        ),
    ]);
    if (index != null) {
      app.update(() {
        app.defaultFocus = kPresets[index].focus;
        app.defaultBreak = kPresets[index].rest;
      });
    }
  }

  Future<void> _pickGoal(BuildContext context) async {
    final goal = await _pickOne<int>(context, 'Daily focus goal', [
      for (final n in const [2, 3, 4, 5, 6, 8])
        (value: n, label: '$n sessions'),
    ]);
    if (goal != null) app.update(() => app.dailyGoal = goal);
  }

  Widget _header() {
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
                Text(app.fullName, style: AppText.h2.copyWith(fontSize: 28)),
                const SizedBox(height: 2),
                Text(app.email, style: AppText.body),
                const SizedBox(height: 6),
                // Sample text from the design.
                const Text(
                  'Student · Growing since October',
                  style: TextStyle(color: AppColors.leaf, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _accountSection(BuildContext context) => [
    const SizedBox(height: 24),
    Text('Account', style: AppText.h2.copyWith(fontSize: 26)),
    const SizedBox(height: 12),
    AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _SettingRow(
            title: 'Personal information',
            onTap: () => _editName(context),
          ),
          const Divider(height: 1, color: AppColors.border),
          _SettingRow(
            title: 'Password & security',
            onTap: () => _soon(
              context,
              'Password changes will work once accounts are connected.',
            ),
          ),
        ],
      ),
    ),
  ];

  List<Widget> _preferencesSection(BuildContext context) => [
    const SizedBox(height: 24),
    Text('Make it yours', style: AppText.h2.copyWith(fontSize: 26)),
    const SizedBox(height: 12),
    AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _SettingRow(
            title: 'Timer preferences',
            subtitle: '${app.defaultFocus} / ${app.defaultBreak} min',
            onTap: () => _pickRhythm(context),
          ),
          const Divider(height: 1, color: AppColors.border),
          _SettingRow(
            title: 'Daily focus goal',
            subtitle: '${app.dailyGoal} sessions',
            onTap: () => _pickGoal(context),
          ),
          const Divider(height: 1, color: AppColors.border),
          _SettingRow(
            title: 'Sound & reminders',
            subtitle: app.soundOn ? 'On' : 'Off',
            onTap: () => app.update(() => app.soundOn = !app.soundOn),
            trailing: Switch(
              value: app.soundOn,
              onChanged: (v) => app.update(() => app.soundOn = v),
            ),
          ),
        ],
      ),
    ),
    const SizedBox(height: 24),
    AppButton(
      'Log out',
      kind: AppButtonKind.outlined,
      onPressed: () => Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.welcome,
            (route) => false,
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final desktop = Responsive.isDesktop(context);
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        return AppPage(
          title: 'Your profile',
          maxWidth: desktop ? 980 : 600,
          children: [
            _header(),
            LayoutBuilder(
              builder: (context, c) {
                final account = _accountSection(context);
                final prefs = _preferencesSection(context);
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
      },
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
