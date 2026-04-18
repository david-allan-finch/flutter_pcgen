import '../cdom/enumeration/integer_key.dart';
import '../cdom/enumeration/list_key.dart';
import '../cdom/enumeration/object_key.dart';
import 'ability_category.dart';
import 'pcobject.dart';

/// Definition and game rules for an Ability (feat, special ability, etc).
final class Ability extends PObject {
  AbilityCategory? _category;

  String getCategory() => _category?.getKeyName() ?? '';

  AbilityCategory? getCDOMCategory() => _category;
  void setCDOMCategory(AbilityCategory? cat) { _category = cat; }

  /// Returns true if this ability can be taken multiple times.
  bool isMult() =>
      getSafe(ObjectKey.getConstant<bool>('MULT', defaultValue: false)) as bool? ?? false;

  /// Returns true if multiple copies of this ability stack.
  bool isStackable() =>
      getSafe(ObjectKey.getConstant<bool>('STACK', defaultValue: false)) as bool? ?? false;

  /// Returns the cost of this ability in pool points.
  double getCost() =>
      (getSafe(ObjectKey.getConstant<dynamic>('COST')) as num?)?.toDouble() ?? 1.0;

  /// Returns all description keys used by this ability.
  List<dynamic> getDescriptionKey() =>
      getSafeListFor<dynamic>(ListKey.getConstant<dynamic>('DESCRIPTION'));

  /// Returns all type strings.
  List<String> getTypes() =>
      getSafeListFor<String>(ListKey.getConstant<String>('TYPE'));

  int compareTo(Object other) {
    if (other is Ability) return getKeyName().compareTo(other.getKeyName());
    return -1;
  }

  @override
  bool operator ==(Object other) =>
      other is Ability && getKeyName().toLowerCase() == other.getKeyName().toLowerCase();

  @override
  int get hashCode => getKeyName().toLowerCase().hashCode;

  @override
  Ability clone() {
    final copy = Ability();
    copy.setDisplayName(getDisplayName());
    copy.setKeyName(getKeyName());
    copy._category = _category;
    return copy;
  }

  String getPCCText() => getKeyName();
}
