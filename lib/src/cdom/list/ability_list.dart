import '../base/cdom_list_object.dart';
import '../enumeration/nature.dart';
import '../../core/ability.dart';

// A CDOMListObject for Ability objects, keyed by category and nature.
class AbilityList extends CDOMListObject<Ability> {
  dynamic _category; // CDOMSingleRef<AbilityCategory>
  Nature? _nature;

  // Master map: (category ref, nature) → CDOMReference<AbilityList>
  static final Map<dynamic, Map<Nature, dynamic>> masterMap = {};

  @override
  Type get listClass => Ability;

  @override
  bool isType(String type) => false;

  static dynamic getAbilityListReference(dynamic category, Nature nature) {
    final inner = masterMap[category] ??= {};
    return inner.putIfAbsent(nature, () {
      final list = AbilityList();
      list.setName('*$category:$nature');
      list._category = category;
      list._nature = nature;
      return list; // CDOMDirectSingleRef.getRef(list) — stub returns list itself
    });
  }

  dynamic getCategory() => _category;
  Nature? getNature() => _nature;
}
