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

import 'package:flutter_pcgen/src/cdom/enumeration/formula_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/object_key.dart';
import 'package:flutter_pcgen/src/core/pcobject.dart';

/// Represents a divine domain (e.g., Fire, War, Protection).
///
/// Domains can grant bonus spells, special abilities, and feat choices
/// to divine casters who select them.
final class Domain extends PObject {
  String getLocalScopeName() => 'PC.DOMAIN';

  /// Returns the CHOOSE formula, if any (for domain-granted choices).
  dynamic getChooseInfo() =>
      getSafeObject(ObjectKey.getConstant<dynamic>('CHOOSE_INFO'));

  /// Returns the SELECT formula used by CHOOSE processing.
  dynamic getSelectFormula() =>
      getSafeObject(ObjectKey.getConstant<dynamic>('SELECT'));

  /// Returns the CHOOSE actors list.
  List<dynamic> getActors() =>
      getSafeListFor<dynamic>(ListKey.getConstant<dynamic>('NEW_CHOOSE_ACTOR'));

  /// Returns the formula source string used by the formula engine.
  String getFormulaSource() => getKeyName();

  /// Returns the NUM_CHOICES formula.
  dynamic getNumChoices() =>
      getSafeObject(ObjectKey.getConstant<dynamic>('NUM_CHOICES'));

  // ---- Domain spells & abilities -------------------------------------------

  /// Domain spells: list of 'Level:SpellName' strings from SPELLLEVEL token.
  /// E.g. ['1:Burning Hands', '2:Produce Flame', ...] for the Fire domain.
  List<String> getDomainSpellEntries() {
    try {
      final list =
          getSafeListFor(ListKey.getConstant<String>('DOMAIN_SPELLS')) as List?;
      return list?.cast<String>() ?? const [];
    } catch (_) {
      return const [];
    }
  }

  /// Returns a sorted map of level → spell name for this domain.
  Map<int, String> getDomainSpellMap() {
    final result = <int, String>{};
    for (final entry in getDomainSpellEntries()) {
      final colon = entry.indexOf(':');
      if (colon > 0) {
        final level = int.tryParse(entry.substring(0, colon));
        final spell = entry.substring(colon + 1);
        if (level != null && spell.isNotEmpty) result[level] = spell;
      }
    }
    return result;
  }

  /// Ability names automatically granted by this domain (ABILITY:|AUTOMATIC| tokens).
  List<String> getAutoGrantedAbilities() {
    try {
      final list =
          getSafeListFor(ListKey.getConstant<String>('AUTO_ABILITIES')) as List?;
      return list?.cast<String>() ?? const [];
    } catch (_) {
      return const [];
    }
  }
}
