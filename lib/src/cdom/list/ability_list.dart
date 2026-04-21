//
// Copyright 2007, 2008 (C) Tom Parker <thpr@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This library is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.cdom.list.AbilityList
import 'package:flutter_pcgen/src/cdom/base/cdom_list_object.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/nature.dart';
import 'package:flutter_pcgen/src/core/ability.dart';

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
