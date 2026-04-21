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
// Translation of pcgen.cdom.facet.input.GlobalAddedSkillCostFacet
// Translated from PCGen Java source to Dart.
// Source: pcgen/cdom/facet/input/GlobalAddedSkillCostFacet.java

import '../../../enumeration/char_id.dart';
import '../base/abstract_scope_facet.dart';

/// GlobalAddedSkillCostFacet stores the Global SkillCost values as applied by
/// CSKILL:%LIST and CCSKILL:%LIST.
///
/// Parameterized as: id=CharID, scope=SkillCost, value=Skill
class GlobalAddedSkillCostFacet extends AbstractScopeFacet<CharID, dynamic, dynamic> {}
