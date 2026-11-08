import 'package:tutomato/models/shop_item.dart';
import 'package:tutomato/models/user_profile.dart';

/// The cards for one tab of the Pomodori screen, with ownership resolved.
List<ShopEntry> buildShopEntries(UserProfile profile, ShopCategory category) {
  return ShopCatalog.inCategory(category).map((item) {
    return ShopEntry(
      item: item,
      owned: profile.owns(item.id),
      equipped: profile.equipped.idFor(category) == item.id,
      canAfford: profile.points >= item.cost,
    );
  }).toList();
}
