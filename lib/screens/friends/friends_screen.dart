import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/pomodori_image.dart';
import '../../core/widgets/tab_page.dart';
import '../../models/models.dart';
import '../../providers/app_state.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final AppState app = AppState.instance;
  final Set<String> _cheered = {};

  static const _inviteCode = 'TOMATO-4F7K';

  void _cheer(String name) {
    setState(() => _cheered.add(name));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You cheered ${name.split(' ').first}!')),
    );
  }

  Future<void> _invite() async {
    final messenger = ScaffoldMessenger.of(context);
    final copy = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cream,
        title: const Text('Invite a study friend'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Share this code with a friend. Linking accounts will work once the online backend is connected.',
            ),
            const SizedBox(height: 16),
            const SelectableText(
              _inviteCode,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.leaf,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Copy code'),
          ),
        ],
      ),
    );
    if (copy == true) {
      await Clipboard.setData(const ClipboardData(text: _inviteCode));
      messenger.showSnackBar(const SnackBar(content: Text('Code copied.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final friends = app.friends;
        final youFocused = app.todaySessions.isNotEmpty;

        return TabPage(
          title: 'Better together',
          subtitle: 'Good habits grow together.',
          children: [
            if (friends.isNotEmpty)
              _sharedStreakCard(friends.first, youFocused),
          ],
          sideChildren: [
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Your study circle',
                    style: AppText.h2.copyWith(fontSize: 26),
                  ),
                ),
                Text(
                  '${friends.length} ${friends.length == 1 ? 'friend' : 'friends'}',
                  style: AppText.body,
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final f in friends)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  child: Row(
                    children: [
                      const PomodoriImage(size: 64),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              f.name,
                              style: AppText.h2.copyWith(fontSize: 20),
                            ),
                            Text(
                              '${f.sharedStreak}-day shared streak',
                              style: AppText.body,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              f.status,
                              style: const TextStyle(
                                color: AppColors.leaf,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _CheerButton(
                        cheered: _cheered.contains(f.name),
                        onTap: () => _cheer(f.name),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
            AppButton(
              'Invite a study friend',
              icon: Icons.add,
              color: AppColors.leaf,
              onPressed: _invite,
            ),
          ],
        );
      },
    );
  }

  Widget _sharedStreakCard(Friend friend, bool youFocused) {
    final first = friend.name.split(' ').first;
    final focusedCount = (youFocused ? 1 : 0) + (friend.focusing ? 1 : 0);
    return AppCard(
      color: kMint,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOU + ${first.toUpperCase()}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              color: AppColors.leaf,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${friend.sharedStreak} ${friend.sharedStreak == 1 ? 'day' : 'days'} of showing up',
            style: AppText.h2.copyWith(fontSize: 30),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Buddy(name: youFocused ? '${app.userName} ✓' : app.userName),
              const SizedBox(width: 20),
              _Buddy(
                name: friend.focusing
                    ? '$first · focusing'
                    : '$first · resting',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              '$focusedCount of 2 focused today · Keep it growing',
              textAlign: TextAlign.center,
              style: AppText.body,
            ),
          ),
        ],
      ),
    );
  }
}

class _Buddy extends StatelessWidget {
  final String name;
  const _Buddy({required this.name});

  @override
  Widget build(BuildContext context) => Flexible(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const PomodoriImage(size: 120),
        const SizedBox(height: 4),
        Text(
          name,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.leaf,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
      ],
    ),
  );
}

class _CheerButton extends StatelessWidget {
  final bool cheered;
  final VoidCallback onTap;
  const _CheerButton({required this.cheered, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
    color: kMint,
    shape: const StadiumBorder(),
    child: InkWell(
      customBorder: const StadiumBorder(),
      onTap: cheered ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Text(
          cheered ? 'Cheered ✓' : 'Cheer',
          style: const TextStyle(
            color: AppColors.leaf,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
      ),
    ),
  );
}
