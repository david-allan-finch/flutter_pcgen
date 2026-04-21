//
// Copyright (c) Thomas Parker, 2010.
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
// Translation of pcgen.cdom.facet.input.LocalAddedSkillCostFacet
// Translated from PCGen Java source to Dart.
// Source: pcgen/cdom/facet/input/LocalAddedSkillCostFacet.java

/// LocalAddedSkillCostFacet stores directly set SkillCost objects, which are
/// the result of a number of possibilities: ADD:CLASSSKILLS as well as
/// CSKILL:%LIST or CCSKILL:%LIST in a Domain are both examples that use
/// LocalAddedSkillCostFacet.
///
/// Parameterized as: scope=PCClass, subscope=SkillCost, value=Skill
/// (Java: AbstractSubScopeFacet<PCClass, SkillCost, Skill>)
class LocalAddedSkillCostFacet {
  // AbstractSubScopeFacet state: Map<PCClass, Map<SkillCost, Set<Skill>>>
  final Map<dynamic, Map<dynamic, Set<dynamic>>> _cache = {};

  void add(dynamic scope, dynamic subScope, dynamic value, dynamic source) {
    _cache.putIfAbsent(scope, () => {}).putIfAbsent(subScope, () => {}).add(value);
  }

  void remove(dynamic scope, dynamic subScope, dynamic value, dynamic source) {
    _cache[scope]?[subScope]?.remove(value);
  }

  Set<dynamic> getSet(dynamic scope, dynamic subScope) {
    return _cache[scope]?[subScope] ?? {};
  }
}
