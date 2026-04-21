//
// Copyright 2001 (C) Bryan McRoberts <merton_monk@yahoo.com>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.core.Domain

import '../cdom/enumeration/formula_key.dart';
import '../cdom/enumeration/list_key.dart';
import '../cdom/enumeration/object_key.dart';
import 'pcobject.dart';

/// Represents a divine domain (e.g., Fire, War, Protection).
///
/// Domains can grant bonus spells, special abilities, and feat choices
/// to divine casters who select them.
final class Domain extends PObject {
  String getLocalScopeName() => 'PC.DOMAIN';

  /// Returns the CHOOSE formula, if any (for domain-granted choices).
  dynamic getChooseInfo() =>
      getSafe(ObjectKey.getConstant<dynamic>('CHOOSE_INFO'));

  /// Returns the SELECT formula used by CHOOSE processing.
  dynamic getSelectFormula() =>
      getSafe(ObjectKey.getConstant<dynamic>('SELECT'));

  /// Returns the CHOOSE actors list.
  List<dynamic> getActors() =>
      getSafeListFor<dynamic>(ListKey.getConstant<dynamic>('NEW_CHOOSE_ACTOR'));

  /// Returns the formula source string used by the formula engine.
  String getFormulaSource() => getKeyName();

  /// Returns the NUM_CHOICES formula.
  dynamic getNumChoices() =>
      getSafe(ObjectKey.getConstant<dynamic>('NUM_CHOICES'));
}
