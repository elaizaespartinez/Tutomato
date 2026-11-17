import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/pill_chip.dart';
import '../../core/widgets/pomodori_avatar.dart';
import '../../core/widgets/tab_page.dart';
import '../../models/models.dart';
import '../../providers/app_state.dart';

class PomodoriScreen extends StatefulWidget {
  const PomodoriScreen({super.key});

  @override
  State<PomodoriScreen> createState() => _PomodoriScreenState();
}

class _PomodoriScreenState extends State<PomodoriScreen> {
  final AppState app = AppState.instance;
  WardrobeCategory _tab = WardrobeCategory.outfit;

  static const _tabs = [
    (WardrobeCategory.outfit, 'Outfits'),
    (WardrobeCategory.color, 'Colors'),
    (WardrobeCategory.extra, 'Extras'),
  ];

  String get _heading {
    switch (_tab) {
      case WardrobeCategory.outfit:
        return 'Pick a study look';
      case WardrobeCategory.color:
        return 'Pick ${app.petName}’s color';
      case WardrobeCategory.extra:
        return 'Add a little extra';
    }
  }

  (String, String) get _footer {
    switch (_tab) {
      case WardrobeCategory.outfit:
        return (
        'Your focus funds the fun.',
        'Finish a session to earn 25 Study Points. Spend them on a new look for your Pomodori.',
        );
      case WardrobeCategory.color:
        return (
        'A fresh shade for your study buddy.',
        'Choose a colorway. Outfits and extras stay the same. Finish focus sessions to earn more Study Points.',
        );
      case WardrobeCategory.extra:
        return (
        'Little details. Big personality.',
        'Equip one extra alongside your outfit and color. Complete focus sessions to grow your point balance.',
        );
    }
  }

  void _choose(WardrobeItem item) {
    final message = app.choose(item);
    if (message != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Widget _wardrobeCard() {
    final percent = (app.ripeness * 100).round();
    return AppCard(
      color: AppColors.peach,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${app.petName.toUpperCase()}’S LITTLE WARDROBE',
                  style: const TextStyle(
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
                      '${app.points} points',
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
            color: app.equippedKey(WardrobeCategory.color),
            outfit: app.equippedKey(WardrobeCategory.outfit),
            extra: app.equippedKey(WardrobeCategory.extra),
          ),
          Text(
            'Looking ripe, ${app.petName}!',
            textAlign: TextAlign.center,
            style: AppText.h2.copyWith(fontSize: 28),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text('Level ${app.level} · Ripeness', style: AppText.body),
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
              value: app.ripeness.clamp(0.0, 1.0),
              minHeight: 12,
              backgroundColor: Colors.white,
              color: AppColors.leaf,
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemCard(WardrobeItem item) {
    final equipped = app.isEquipped(item);
    final owned = app.isOwned(item);

    // Preview: show only what this card is about.
    final avatar = PomodoriAvatar(
      size: 84,
      color: item.category == WardrobeCategory.color ? item.key : 'classic',
      outfit: item.category == WardrobeCategory.outfit ? item.key : 'classic',
      extra: item.category == WardrobeCategory.extra ? item.key : 'none',
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
      status = 'Buy · ${item.cost} pts';
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
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final items = app.itemsOf(_tab);
        final footer = _footer;
        return TabPage(
          title: 'Your Pomodori',
          children: [_wardrobeCard()],
          sideChildren: [
            const SizedBox(height: 20),
            Row(
              children: [
                for (var i = 0; i < _tabs.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(
                    child: PillChip(
                      label: _tabs[i].$2,
                      selected: _tab == _tabs[i].$1,
                      activeColor: AppColors.tomato,
                      outlined: true,
                      onTap: () => setState(() => _tab = _tabs[i].$1),
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
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  _itemCard(items[i]),
                ],
              ],
            ),
            const SizedBox(height: 24),
            Text(footer.$1, style: AppText.h2.copyWith(fontSize: 20)),
            const SizedBox(height: 6),
            Text(footer.$2, style: AppText.body.copyWith(fontSize: 16)),
          ],
        );
      },
    );
  }
}
