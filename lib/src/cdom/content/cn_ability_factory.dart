//
// Copyright (c) 2014 Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.content.CNAbilityFactory
import 'package:flutter_pcgen/src/cdom/base/category.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/nature.dart';
import 'cn_ability.dart';
import 'package:flutter_pcgen/src/core/ability.dart';

// Factory that interns CNAbility instances to avoid duplicates.
abstract final class CNAbilityFactory {
  static final Map<CNAbility, CNAbility> _map = {};

  static CNAbility getCNAbility(Category<Ability> cat, Nature n, Ability a) {
    final toMatch = CNAbility(cat, a, n);
    return _map.putIfAbsent(toMatch, () => toMatch);
  }

  static void reset() { _map.clear(); }
}
