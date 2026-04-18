import '../../core/ability.dart';
import '../base/category.dart';
import '../base/concrete_prereq_object.dart';
import '../enumeration/nature.dart';

// An CNAbility represents a categorized Ability with a Nature (automatic, virtual, normal).
class CNAbility extends ConcretePrereqObject implements Comparable<CNAbility> {
  final Category<Ability> category;
  final Ability ability;
  final Nature nature;

  CNAbility(this.category, this.ability, this.nature) {
    if (ability.getKeyName() == null || ability.getKeyName()!.isEmpty) {
      throw ArgumentError('Cannot build CNAbility when Ability has no key');
    }
    final origCategory = ability.getCDOMCategory();
    if (origCategory == null) {
      throw ArgumentError(
          'Cannot build CNAbility for $ability when Ability has null original Category');
    }
    final parentCat = category.getParentCategory();
    if (parentCat != origCategory) {
      throw ArgumentError(
          'Cannot build CNAbility for $ability with incompatible Category: '
          '$category is not compatible with Ability\'s Category: $origCategory');
    }
  }

  String getAbilityKey() => ability.getKeyName() ?? '';
  Category<Ability> getAbilityCategory() => category;
  Nature getNature() => nature;
  Ability getAbility() => ability;

  @override
  int get hashCode => ability.hashCode;

  @override
  bool operator ==(Object o) {
    if (o is CNAbility) {
      return category == o.category && ability == o.ability && nature == o.nature;
    }
    return false;
  }

  @override
  int compareTo(CNAbility other) {
    int compare = ability.compareTo(other.ability);
    if (compare != 0) return compare;
    compare = category.toString().compareTo(other.category.toString());
    if (compare != 0) return compare;
    return nature.index.compareTo(other.nature.index);
  }

  @override
  String toString() => ability.getDisplayName() ?? '';
}
