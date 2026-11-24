/// The three tabs on the Pomodori screen.
enum ShopCategory { outfit, color, extra }

class ShopItem {
  const ShopItem({
    required this.id,
    required this.name,
    required this.category,
    required this.cost,
  });

  final String id;
  final String name;
  final ShopCategory category;

  /// Study Points. 0 means it is free and everyone owns it.
  final int cost;

  bool get isFree => cost == 0;
}

/// The shop catalog is fixed in code (it matches the design), so there is
/// nothing to seed in Firestore. To add an item, add a line here and ship the
/// matching artwork.
class ShopCatalog {
  ShopCatalog._();

  static const items = <ShopItem>[
    // Outfits: "Pick a study look"
    ShopItem(id: 'outfit_classic', name: 'Classic', category: ShopCategory.outfit, cost: 0),
    ShopItem(id: 'outfit_scholar', name: 'Scholar', category: ShopCategory.outfit, cost: 80),
    ShopItem(id: 'outfit_cozy', name: 'Cozy', category: ShopCategory.outfit, cost: 120),
    // Colors: "Pick Pip's color"
    ShopItem(id: 'color_classic', name: 'Classic', category: ShopCategory.color, cost: 0),
    ShopItem(id: 'color_golden', name: 'Golden', category: ShopCategory.color, cost: 80),
    ShopItem(id: 'color_rosy', name: 'Rosy', category: ShopCategory.color, cost: 120),
    // Extras: "Add a little extra"
    ShopItem(id: 'extra_none', name: 'None', category: ShopCategory.extra, cost: 0),
    ShopItem(id: 'extra_glasses', name: 'Glasses', category: ShopCategory.extra, cost: 60),
    ShopItem(id: 'extra_book', name: 'Study book', category: ShopCategory.extra, cost: 100),
  ];

  static const defaultOutfitId = 'outfit_classic';
  static const defaultColorId = 'color_classic';
  static const defaultExtraId = 'extra_none';

  static const defaultOwnedIds = <String>[
    defaultOutfitId,
    defaultColorId,
    defaultExtraId,
  ];

  static ShopItem? byId(String id) {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  static List<ShopItem> inCategory(ShopCategory category) =>
      items.where((i) => i.category == category).toList();
}

/// One card on the Pomodori screen: an item plus what the user can do with it.
/// Equipped -> "Equipped ✓", owned -> tap to equip, otherwise "Buy · 80 pts".
class ShopEntry {
  const ShopEntry({
    required this.item,
    required this.owned,
    required this.equipped,
    required this.canAfford,
  });

  final ShopItem item;
  final bool owned;
  final bool equipped;
  final bool canAfford;
}
