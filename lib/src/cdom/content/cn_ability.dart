//
// Copyright (c) 2008-14 Tom Parker <thpr@users.sourceforge.net>
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
//
// Translation of pcgen.cdom.content.CNAbility
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
