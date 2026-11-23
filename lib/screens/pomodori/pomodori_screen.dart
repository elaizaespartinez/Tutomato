import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_exception.dart';
import '../../core/async_utils.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/pill_chip.dart';
import '../../core/widgets/pomodori_avatar.dart';
import '../../core/widgets/tab_page.dart';
import '../../models/shop_item.dart';
import '../../models/user_profile.dart';
import '../../providers/actions.dart';
import '../../providers/data_providers.dart';

class PomodoriScreen extends ConsumerStatefulWidget {
  const PomodoriScreen({super.key});

  @override
  ConsumerState<PomodoriScreen> createState() => _PomodoriScreenState();
}

class _PomodoriScreenState extends ConsumerState<PomodoriScreen> {
  ShopCategory _category = ShopCategory.outfit;

  static const _tabs = [
    (ShopCategory.outfit, 'Outfits'),
    (ShopCategory.color, 'Colors'),
    (ShopCategory.extra, 'Extras'),
  ];

  String get _heading {
    switch (_category) {
      case ShopCategory.outfit:
        return 'Pick a study look';
      case ShopCategory.color:
        return 'Pick your Pomodori’s color';
      case ShopCategory.extra:
        return 'Add a little extra';
    }
  }

  (String, String) get _footer {
    switch (_category) {
      case ShopCategory.outfit:
        return (
        'Your focus funds the fun.',
        'Finish a session to earn Study Points. Spend them on a new look for your Pomodori.',
        );
      case ShopCategory.color:
        return (
        'A fresh shade for your study buddy.',
        'Choose a colorway. Outfits and extras stay the same. Finish focus sessions to earn more Study Points.',
        );
      case ShopCategory.extra:
        return (
        'Little details. Big personality.',
        'Equip one extra alongside your outfit and color. Complete focus sessions to grow your point balance.',
        );
    }
  }

  Future<void> _choose(ShopItem item) async {
    try {
      await ref.read(actionsProvider).buyAndEquipItem(item);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Equipped ${item.name}!'), backgroundColor: AppColors.leaf),
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

  Widget _wardrobeCard(UserProfile profile) {
    final percent = (profile.ripeness * 100).round();
    return AppCard(
      color: AppColors.peach,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'POMODORI’S LITTLE WARDROBE',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                    color: AppColors.brownSoft,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: AppColors.tomato, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '${profile.points} points',
                      style: const TextStyle(
                        color: AppColors.tomato,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          PomodoriAvatar(
            size: 220,
            color: profile.equipped.color,
            outfit: profile.equipped.outfit,
            extra: profile.equipped.extra,
          ),
          Text(
            'Looking ripe!',
            textAlign: TextAlign.center,
            style: AppText.h2.copyWith(fontSize: 28),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text('Level ${profile.level} · Ripeness', style: AppText.body),
              const Spacer(),
              Text(
                '$percent%',
                style: const TextStyle(
                  color: AppColors.leaf,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: profile.ripeness.clamp(0.0, 1.0),
              minHeight: 12,
              backgroundColor: Colors.white,
              color: AppColors.leaf,
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemCard(ShopEntry entry) {
    final item = entry.item;
    final equipped = entry.isEquipped;
    final owned = entry.isOwned;

    final avatar = PomodoriAvatar(
      size: 84,
      color: item.category == ShopCategory.color ? item.id : 'classic',
      outfit: item.category == ShopCategory.outfit ? item.id : 'classic',
      extra: item.category == ShopCategory.extra ? item.id : 'none',
    );

    final String status;
    final Color statusBg;
    final Color statusText;
    if (equipped) {
      status = 'Equipped ✓';
      statusBg = kMint;
      statusText = AppColors.leaf;
    } else if (owned) {
      status = 'Equip';
      statusBg = AppColors.peach;
      statusText = AppColors.brown;
    } else {
      status = 'Buy · ${item.price} pts';
      statusBg = AppColors.peach;
      statusText = AppColors.brown;
    }

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
      side: BorderSide(
        color: equipped ? AppColors.tomato : AppColors.border,
        width: equipped ? 2 : 1,
      ),
    );

    return Expanded(
      child: Material(
        color: AppColors.card,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _choose(item),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 14, 8, 12),
            child: Column(
              children: [
                avatar,
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    item.name,
                    textAlign: TextAlign.center,
                    style: AppText.h2.copyWith(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusText,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider).dataOrNull ?? UserProfile.fallback();
    final shopEntries = ref.watch(shopEntriesProvider(_category));
    final footer = _footer;

    return TabPage(
      title: 'Your Pomodori',
      sideChildren: [
        const SizedBox(height: 20),
        Row(
          children: [
            for (var i = 0; i < _tabs.length; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              Expanded(
                child: PillChip(
                  label: _tabs[i].$2,
                  selected: _category == _tabs[i].$1,
                  activeColor: AppColors.tomato,
                  outlined: true,
                  onTap: () => setState(() => _category = _tabs[i].$1),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 24),
        Text(_heading, style: AppText.h2.copyWith(fontSize: 26)),
        const SizedBox(height: 14),
        Row(
          children: [
            for (var i = 0; i < shopEntries.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              _itemCard(shopEntries[i]),
            ],
          ],
        ),
        const SizedBox(height: 24),
        Text(footer.$1, style: AppText.h2.copyWith(fontSize: 20)),
        const SizedBox(height: 6),
        Text(footer.$2, style: AppText.body.copyWith(fontSize: 16)),
      ],
      children: [_wardrobeCard(profile)],
    );
  }
}