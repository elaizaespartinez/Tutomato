import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/app_widgets.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({
    required this.points,
    required this.onOpenProfile,
    required this.onPurchase,
    required this.ownedItems,
    required this.onOwn,
    this.equippedHeadwear = TomatoHeadwear.none,
    this.equippedProp = TomatoProp.none,
    this.equippedColorway = TomatoColorway.classic,
    this.onEquipHeadwear,
    this.onEquipProp,
    this.onEquipColorway,
    super.key,
  });

  final int points;
  final VoidCallback onOpenProfile;
  final ValueChanged<int> onPurchase;
  /// All item names the user currently owns — lives in [_TutomatoHomeState]
  /// so it survives tab switches.
  final Set<String> ownedItems;
  /// Called when a new item is purchased so the parent can record ownership.
  final ValueChanged<String> onOwn;
  final TomatoHeadwear equippedHeadwear;
  final TomatoProp equippedProp;
  final TomatoColorway equippedColorway;
  final ValueChanged<TomatoHeadwear>? onEquipHeadwear;
  final ValueChanged<TomatoProp>? onEquipProp;
  final ValueChanged<TomatoColorway>? onEquipColorway;

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  int _tab = 0;
  String _outfit = 'Classic';
  String _color = 'Classic';
  String _extra = 'None';

  @override
  void initState() {
    super.initState();
    _outfit = switch (widget.equippedHeadwear) {
      TomatoHeadwear.scholarHat => 'Scholar',
      TomatoHeadwear.headphones => 'Cozy',
      TomatoHeadwear.none => 'Classic',
    };
    _color = switch (widget.equippedColorway) {
      TomatoColorway.classic => 'Classic',
      TomatoColorway.golden => 'Golden',
      TomatoColorway.rosy => 'Rosy',
    };
    _extra = switch (widget.equippedProp) {
      TomatoProp.glasses => 'Glasses',
      TomatoProp.books => 'Study book',
      TomatoProp.none => 'None',
    };
  }

  static const _outfits = [
    _WardrobeItem('Classic', 'Free', Icons.spa_outlined, 0),
    _WardrobeItem('Scholar', '80 pts', Icons.school_outlined, 80),
    _WardrobeItem('Cozy', '120 pts', Icons.favorite_border, 120),
  ];
  static const _colors = [
    _WardrobeItem('Classic', 'Equipped', Icons.circle, 0),
    _WardrobeItem('Golden', 'Buy · 80 pts', Icons.circle, 80),
    _WardrobeItem('Rosy', 'Buy · 120 pts', Icons.circle, 120),
  ];
  static const _extras = [
    _WardrobeItem('None', 'Equipped', Icons.sentiment_satisfied_alt, 0),
    _WardrobeItem('Glasses', 'Buy · 60 pts', Icons.visibility_outlined, 60),
    _WardrobeItem('Study book', 'Buy · 100 pts', Icons.menu_book_outlined, 100),
  ];

  List<_WardrobeItem> get _items => switch (_tab) {
    0 => _outfits,
    1 => _colors,
    _ => _extras,
  };

  String get _equipped => switch (_tab) {
    0 => _outfit,
    1 => _color,
    _ => _extra,
  };

  void _selectItem(_WardrobeItem item) {
    if (!widget.ownedItems.contains(item.name)) {
      if (widget.points < item.cost) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Not quite enough Study Points yet.')),
        );
        return;
      }
      widget.onPurchase(item.cost);
      widget.onOwn(item.name);
    }
    setState(() {
      if (_tab == 0) {
        _outfit = item.name;
        final hw = switch (item.name) {
          'Scholar' => TomatoHeadwear.scholarHat,
          'Cozy' => TomatoHeadwear.headphones,
          _ => TomatoHeadwear.none,
        };
        widget.onEquipHeadwear?.call(hw);
      }
      if (_tab == 1) {
        _color = item.name;
        final cw = switch (item.name) {
          'Golden' => TomatoColorway.golden,
          'Rosy' => TomatoColorway.rosy,
          _ => TomatoColorway.classic,
        };
        widget.onEquipColorway?.call(cw);
      }
      if (_tab == 2) {
        _extra = item.name;
        final p = switch (item.name) {
          'Glasses' => TomatoProp.glasses,
          'Study book' => TomatoProp.books,
          _ => TomatoProp.none,
        };
        widget.onEquipProp?.call(p);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (_tab) {
      0 => 'Pick a study look',
      1 => 'Pick Pip’s color',
      _ => 'Add a little extra',
    };
    final detail = switch (_tab) {
      0 => 'Find a cozy outfit for your next study session.',
      1 => 'Give your Pomodori a little splash of color.',
      _ => 'Equip one extra alongside your outfit and color.',
    };
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCard(
            color: AppColors.peach,
            padding: const EdgeInsets.fromLTRB(16, 13, 16, 15),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'PIP’S LITTLE WARDROBE',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        '★ ${widget.points} points',
                        style: AppTextStyles.title.copyWith(
                          color: AppColors.red,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TomatoMascotWithAccessories(
                  size: 176,
                  colorway: widget.equippedColorway,
                  headwear: widget.equippedHeadwear,
                  prop: widget.equippedProp,
                ),
                const SizedBox(height: 3),
                const Text('Looking ripe, Pip!', style: AppTextStyles.heading),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Level 3 · Ripeness',
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body,
                      ),
                    ),
                    Text(
                      '38%',
                      style: AppTextStyles.title.copyWith(
                        color: AppColors.green,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: const LinearProgressIndicator(
                    value: .38,
                    minHeight: 8,
                    backgroundColor: AppColors.card,
                    color: AppColors.green,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _WardrobeTab(
                label: 'Outfits',
                selected: _tab == 0,
                onTap: () => setState(() => _tab = 0),
              ),
              const SizedBox(width: 8),
              _WardrobeTab(
                label: 'Colors',
                selected: _tab == 1,
                onTap: () => setState(() => _tab = 1),
              ),
              const SizedBox(width: 8),
              _WardrobeTab(
                label: 'Extras',
                selected: _tab == 2,
                onTap: () => setState(() => _tab = 2),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(title, style: AppTextStyles.heading.copyWith(fontSize: 23)),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var index = 0; index < _items.length; index++) ...[
                if (index > 0) const SizedBox(width: 8),
                Expanded(
                  child: _WardrobeCard(
                    item: _items[index],
                    equipped: _equipped == _items[index].name,
                    owned: widget.ownedItems.contains(_items[index].name),
                    onTap: () => _selectItem(_items[index]),
                    previewHeadwear: _tab == 0
                        ? switch (_items[index].name) {
                            'Scholar' => TomatoHeadwear.scholarHat,
                            'Cozy' => TomatoHeadwear.headphones,
                            _ => TomatoHeadwear.none,
                          }
                        : null,
                    previewColorway: _tab == 1
                        ? switch (_items[index].name) {
                            'Golden' => TomatoColorway.golden,
                            'Rosy' => TomatoColorway.rosy,
                            _ => TomatoColorway.classic,
                          }
                        : null,
                    previewProp: _tab == 2
                        ? switch (_items[index].name) {
                            'Glasses' => TomatoProp.glasses,
                            'Study book' => TomatoProp.books,
                            _ => TomatoProp.none,
                          }
                        : null,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Little details. Big personality.',
            style: AppTextStyles.title,
          ),
          const SizedBox(height: 5),
          Text(
            '$detail Complete focus sessions to grow your point balance.',
            style: AppTextStyles.body,
          ),
        ],
      ),
    );
  }
}

class _WardrobeItem {
  const _WardrobeItem(this.name, this.price, this.icon, this.cost);
  final String name;
  final String price;
  final IconData icon;
  final int cost;
}

class _WardrobeTab extends StatelessWidget {
  const _WardrobeTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 42,
        child: selected
            ? FilledButton(
                onPressed: onTap,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(label),
              )
            : OutlinedButton(
                onPressed: onTap,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.muted,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(label),
              ),
      ),
    );
  }
}

class _WardrobeCard extends StatelessWidget {
  const _WardrobeCard({
    required this.item,
    required this.equipped,
    required this.owned,
    required this.onTap,
    this.previewHeadwear,
    this.previewColorway,
    this.previewProp,
  });

  final _WardrobeItem item;
  final bool equipped;
  final bool owned;
  final VoidCallback onTap;
  final TomatoHeadwear? previewHeadwear;
  final TomatoColorway? previewColorway;
  final TomatoProp? previewProp;

  @override
  Widget build(BuildContext context) {
    final isMascotPreview = previewHeadwear != null ||
        previewColorway != null ||
        previewProp != null;

    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Container(
          constraints: const BoxConstraints(minHeight: 170),
          padding: const EdgeInsets.fromLTRB(7, 11, 7, 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: equipped ? AppColors.red : AppColors.border,
              width: equipped ? 1.8 : 1,
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 70,
                child: Center(
                  child: isMascotPreview
                      ? TomatoMascotWithAccessories(
                          size: 70,
                          colorway: previewColorway ?? TomatoColorway.classic,
                          headwear: previewHeadwear ?? TomatoHeadwear.none,
                          prop: previewProp ?? TomatoProp.none,
                        )
                      : Icon(item.icon, size: 51, color: AppColors.green),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                item.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.title.copyWith(fontSize: 17),
              ),
              const SizedBox(height: 7),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 3),
                decoration: BoxDecoration(
                  color: equipped ? AppColors.greenSoft : AppColors.peach,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  equipped
                      ? 'Equipped ✓'
                      : owned
                      ? 'Select'
                      : item.price,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: equipped ? AppColors.green : AppColors.brown,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({
    required this.points,
    required this.todayMinutes,
    required this.completedSessions,
    required this.onOpenProfile,
    super.key,
  });

  final int points;
  final int todayMinutes;
  final int completedSessions;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    const heights = [44.0, 60.0, 38.0, 72.0, 56.0, 88.0, 34.0];
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageTitle(
            title: 'Your records',
            trailing: IconButton.filledTonal(
              onPressed: onOpenProfile,
              icon: const Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 6),
          const Text('Look how far you’ve grown.', style: AppTextStyles.body),
          const SizedBox(height: 18),
          AppCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('This week · Nov 2–8', style: AppTextStyles.title),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$todayMinutes min',
                        style: AppTextStyles.heading.copyWith(
                          color: AppColors.red,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '$completedSessions',
                        textAlign: TextAlign.right,
                        style: AppTextStyles.heading.copyWith(
                          color: AppColors.red,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ],
                ),
                const Row(
                  children: [
                    Expanded(
                      child: Text('focused today', style: AppTextStyles.body),
                    ),
                    Expanded(
                      child: Text(
                        'sessions completed',
                        textAlign: TextAlign.right,
                        style: AppTextStyles.body,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('A week of showing up', style: AppTextStyles.title),
                const SizedBox(height: 12),
                SizedBox(
                  height: 126,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(7, (index) {
                      final current = index == 5;
                      return Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: heights[index],
                              width: 18,
                              decoration: BoxDecoration(
                                color: current
                                    ? AppColors.red
                                    : AppColors.green,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              ['M', 'T', 'W', 'T', 'F', 'S', 'S'][index],
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your consistency', style: AppTextStyles.title),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _RecordValue(
                        value: '5 days',
                        label: 'Current streak',
                        color: AppColors.green,
                      ),
                    ),
                    Expanded(
                      child: _RecordValue(
                        value: '8 days',
                        label: 'Best streak',
                        color: AppColors.brown,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          const SectionHeader('Today’s sessions'),
          const SizedBox(height: 8),
          const AppCard(
            child: Column(
              children: [
                _SessionRecord(title: 'Biology · 25 min', time: '9:00 AM'),
                Divider(color: AppColors.border),
                _SessionRecord(title: 'Mathematics · 25 min', time: '10:15 AM'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '★  $points Study Points earned',
            style: AppTextStyles.body.copyWith(color: AppColors.green),
          ),
        ],
      ),
    );
  }
}

class _RecordValue extends StatelessWidget {
  const _RecordValue({
    required this.value,
    required this.label,
    required this.color,
  });
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTextStyles.title.copyWith(color: color, fontSize: 19),
        ),
        Text(label, style: AppTextStyles.body.copyWith(fontSize: 13)),
      ],
    );
  }
}

class _SessionRecord extends StatelessWidget {
  const _SessionRecord({required this.title, required this.time});
  final String title;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.green, size: 19),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: AppTextStyles.body)),
          Text(time, style: AppTextStyles.body.copyWith(fontSize: 13)),
        ],
      ),
    );
  }
}

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({required this.onOpenProfile, super.key});

  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageTitle(
            title: 'Better together',
            size: 27,
            trailing: IconButton.filledTonal(
              onPressed: onOpenProfile,
              icon: const Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 8),
          const Text('Good habits grow together.', style: AppTextStyles.body),
          const SizedBox(height: 18),
          AppCard(
            color: AppColors.greenSoft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOU + MAYA',
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.green,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '5 days of showing up',
                  style: AppTextStyles.heading.copyWith(fontSize: 25),
                ),
                const SizedBox(height: 7),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _FriendTomato(name: 'Alex ✓'),
                    _FriendTomato(name: 'Maya · focusing'),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text(
                    '1 of 2 focused today · Keep it growing',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 19),
          const SectionHeader(
            'Your study circle',
            trailing: Text('2 friends', style: AppTextStyles.body),
          ),
          const SizedBox(height: 9),
          _FriendCard(
            name: 'Maya Chen',
            detail: '5-day shared streak',
            status: 'Focusing now',
            onCheer: () => _cheer(context, 'Maya'),
          ),
          const SizedBox(height: 11),
          _FriendCard(
            name: 'Jules Santos',
            detail: '3-day shared streak',
            status: '75 min today',
            onCheer: () => _cheer(context, 'Jules'),
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: '+  Invite a study friend',
            color: AppColors.green,
            onPressed: () => _invite(context),
          ),
        ],
      ),
    );
  }

  void _cheer(BuildContext context, String name) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('You cheered $name on!')));
  }

  Future<void> _invite(BuildContext context) async {
    final controller = TextEditingController();
    final email = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cream,
        title: const Text('Invite a study friend'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(hintText: 'Friend’s email'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Invite'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (email != null && email.isNotEmpty && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Invite ready for $email')));
    }
  }
}

class _FriendTomato extends StatelessWidget {
  const _FriendTomato({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TomatoMascot(size: 94),
        Text(
          name,
          textAlign: TextAlign.center,
          style: AppTextStyles.title.copyWith(
            color: AppColors.green,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _FriendCard extends StatelessWidget {
  const _FriendCard({
    required this.name,
    required this.detail,
    required this.status,
    required this.onCheer,
  });
  final String name;
  final String detail;
  final String status;
  final VoidCallback onCheer;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          const TomatoMascot(size: 64),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.title.copyWith(fontSize: 18)),
                const SizedBox(height: 3),
                Text(detail, style: AppTextStyles.body),
                const SizedBox(height: 2),
                Text(
                  status,
                  style: AppTextStyles.body.copyWith(color: AppColors.green),
                ),
              ],
            ),
          ),
          FilledButton.tonal(
            onPressed: onCheer,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.greenSoft,
              foregroundColor: AppColors.green,
            ),
            child: const Text('Cheer'),
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    required this.name,
    required this.email,
    required this.onBack,
    required this.onLogout,
    super.key,
  });

  final String name;
  final String email;
  final VoidCallback onBack;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageTitle(title: 'Your profile', onBack: onBack, size: 28),
          const SizedBox(height: 14),
          AppCard(
            color: AppColors.peach,
            borderColor: AppColors.peach,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: AppColors.red,
                  foregroundColor: AppColors.white,
                  child: const Icon(Icons.person_outline, size: 54),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTextStyles.heading.copyWith(fontSize: 23),
                      ),
                      const SizedBox(height: 3),
                      Text(email, style: AppTextStyles.body),
                      const SizedBox(height: 4),
                      const Text(
                        'Student · Growing since October',
                        style: TextStyle(color: AppColors.green, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          const SectionHeader('Account'),
          const SizedBox(height: 9),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            child: Column(
              children: [
                _ProfileRow(
                  title: 'Personal information',
                  onTap: () => _showSetting(
                    context,
                    'Personal information',
                    'Name: $name\nEmail: $email',
                  ),
                ),
                const Divider(height: 1, color: AppColors.border),
                _ProfileRow(
                  title: 'Password & security',
                  onTap: () => _showSetting(
                    context,
                    'Password & security',
                    'Your account security settings are up to date.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader('Make it yours'),
          const SizedBox(height: 9),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            child: Column(
              children: [
                _ProfileRow(
                  title: 'Timer preferences',
                  subtitle: '25 / 5 min',
                  onTap: () => _showSetting(
                    context,
                    'Timer preferences',
                    'Classic focus is 25 minutes with a 5-minute break.',
                  ),
                ),
                const Divider(height: 1, color: AppColors.border),
                _ProfileRow(
                  title: 'Daily focus goal',
                  subtitle: '4 sessions',
                  onTap: () => _showSetting(
                    context,
                    'Daily focus goal',
                    'Your daily goal is 4 focus sessions.',
                  ),
                ),
                const Divider(height: 1, color: AppColors.border),
                _ProfileRow(
                  title: 'Sound & reminders',
                  subtitle: 'On',
                  onTap: () => _showSetting(
                    context,
                    'Sound & reminders',
                    'Session reminders are turned on.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          OutlineButton(label: 'Log out', onPressed: onLogout),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Tutomato · Lock in to ripen up',
              style: AppTextStyles.body,
            ),
          ),
        ],
      ),
    );
  }

  void _showSetting(BuildContext context, String title, String detail) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cream,
        title: Text(title),
        content: Text(detail, style: AppTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.title, required this.onTap, this.subtitle});
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 62),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.brown,
                        ),
                      ),
                      if (subtitle != null)
                        Text(subtitle!, style: AppTextStyles.body),
                    ],
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}
