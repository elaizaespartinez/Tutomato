import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_exception.dart';
import '../../core/async_utils.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/pomodori_image.dart';
import '../../core/widgets/tab_page.dart';
import '../../models/user_profile.dart';
import '../../providers/actions.dart';
import '../../providers/data_providers.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _cheer(String friendUid, String name) async {
    try {
      await ref.read(actionsProvider).cheer(friendUid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You cheered $name!'), backgroundColor: AppColors.leaf),
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
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.tomato),
        );
      }
    }
  }

  Future<void> _addFriendDialog() async {
    _codeController.clear();
    final add = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cream,
        title: const Text('Add a study friend'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your friend’s invite code:'),
            const SizedBox(height: 12),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                hintText: 'e.g. TOMATO-7K4P',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (add == true && mounted) {
      final code = _codeController.text.trim();
      if (code.isEmpty) return;
      try {
        await ref.read(actionsProvider).addFriendByCode(code);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Friend added!'), backgroundColor: AppColors.leaf),
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
            SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.tomato),
          );
        }
      }
    }
  }

  Future<void> _showInviteCode(String inviteCode) async {
    final copy = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cream,
        title: const Text('Your invite code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Share this code with friends so they can add you:'),
            const SizedBox(height: 16),
            SelectableText(
              inviteCode,
              style: const TextStyle(
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
      await Clipboard.setData(ClipboardData(text: inviteCode));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Code copied.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider).dataOrNull ?? UserProfile.fallback();
    final friendCards = ref.watch(friendCardsProvider);
    final hero = ref.watch(friendsHeroProvider);
    final cheers = ref.watch(cheersProvider);

    final cheeredSet = cheers.map((c) => c.fromUid).toSet();

    return TabPage(
      title: 'Better together',
      subtitle: 'Good habits grow together.',
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
              '${friendCards.length} ${friendCards.length == 1 ? 'friend' : 'friends'}',
              style: AppText.body,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (friendCards.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'No friends yet. Add a friend with their invite code.',
              textAlign: TextAlign.center,
              style: AppText.body,
            ),
          ),
        for (final card in friendCards)
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
                          card.friendName,
                          style: AppText.h2.copyWith(fontSize: 20),
                        ),
                        Text(
                          '${card.sharedStreak}-day shared streak',
                          style: AppText.body,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          card.statusLabel,
                          style: TextStyle(
                            color: card.isFocusingNow ? AppColors.tomato : AppColors.leaf,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _CheerButton(
                    cheered: cheeredSet.contains(card.friendUid),
                    onTap: () => _cheer(card.friendUid, card.friendName),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: AppButton(
                'Add friend',
                icon: Icons.person_add,
                color: AppColors.leaf,
                onPressed: _addFriendDialog,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                'Share my code',
                icon: Icons.share,
                kind: AppButtonKind.outlined,
                onPressed: () => _showInviteCode(profile.inviteCode),
              ),
            ),
          ],
        ),
      ],
      children: [
        if (hero != null)
          _sharedStreakCard(hero, profile.displayName),
      ],
    );
  }

  Widget _sharedStreakCard(FriendsHero hero, String myName) {
    return AppCard(
      color: AppColors.peach,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOU + ${hero.friendName.toUpperCase()}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              color: AppColors.leaf,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${hero.sharedStreak} ${hero.sharedStreak == 1 ? 'day' : 'days'} of showing up',
            style: AppText.h2.copyWith(fontSize: 30),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Buddy(name: hero.iFocusedToday ? '$myName ✓' : myName),
              const SizedBox(width: 20),
              _Buddy(
                name: hero.friendFocusedToday
                    ? '${hero.friendName} ✓'
                    : hero.friendName,
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
              '${(hero.iFocusedToday ? 1 : 0) + (hero.friendFocusedToday ? 1 : 0)} of 2 focused today · Keep it growing',
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
    color: AppColors.peach,
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