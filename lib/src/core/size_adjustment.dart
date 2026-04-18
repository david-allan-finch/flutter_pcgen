import '../cdom/enumeration/string_key.dart';
import 'pcobject.dart';

/// Represents a size category (Fine, Diminutive, Tiny, Small, Medium, Large, etc).
///
/// Translated from pcgen.core.SizeAdjustment. Provides size-based bonus
/// activation and scoping under "PC.SIZE".
final class SizeAdjustment extends PObject {
  String? getSortKey() => get(StringKey.sortKey);

  /// Returns the local scope name for variable resolution.
  String getLocalScopeName() => 'PC.SIZE';

  /// Activates bonuses and returns all active BonusObj list.
  /// [aPC] is a dynamic reference to PlayerCharacter.
  List<dynamic> getActiveBonuses(dynamic aPC) {
    // BonusActivation.activateBonuses(this, aPC) would run here in full impl
    return [];
  }

  @override
  String toString() => getDisplayName();
}
