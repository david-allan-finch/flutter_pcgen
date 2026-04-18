import '../base/category.dart';
import '../enumeration/nature.dart';
import 'cn_ability.dart';
import '../../core/ability.dart';

// Factory that interns CNAbility instances to avoid duplicates.
abstract final class CNAbilityFactory {
  static final Map<CNAbility, CNAbility> _map = {};

  static CNAbility getCNAbility(Category<Ability> cat, Nature n, Ability a) {
    final toMatch = CNAbility(cat, a, n);
    return _map.putIfAbsent(toMatch, () => toMatch);
  }

  static void reset() { _map.clear(); }
}
