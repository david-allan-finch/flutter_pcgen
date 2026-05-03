//
// Missing License Header, Copyright 2016 (C) Andrew Maitland <amaitland@users.sourceforge.net>
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
// Translation of pcgen.cdom.content.AbilitySelection
import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/base/reducible.dart';
import 'package:flutter_pcgen/src/cdom/content/selection.dart';
import 'package:flutter_pcgen/src/core/ability.dart';
import 'package:flutter_pcgen/src/rules/context/load_context.dart';
import 'package:flutter_pcgen/src/core/ability_utilities.dart';

// Pairs an Ability with an optional choice string; used with CHOOSE tokens.
class AbilitySelection extends Selection<Ability, String> implements Comparable<AbilitySelection>, Reducible {
  AbilitySelection(Ability obj, String? sel) : super(obj, sel);

  static AbilitySelection getAbilitySelectionFromPersistentFormat(LoadContext context, String persistentFormat) {
    if (!persistentFormat.contains('|')) {
      return _decodeFeatSelectionChoice(context, persistentFormat);
    }
    final parts = persistentFormat.split('|');
    if (!parts[0].startsWith('CATEGORY=')) {
      throw ArgumentError('String in getAbilitySelectionFromPersistentFormat must start with CATEGORY=, found: $persistentFormat');
    }
    final cat = parts[0].substring(9);
    final ac = context.getReferenceContext().getAbilityCategory(cat);
    if (ac == null) {
      throw ArgumentError('Category in getAbilitySelectionFromPersistentFormat must exist found: $cat');
    }
    final ab = parts[1];
    final a = context.getReferenceContext().getManufacturerId(ac).getActiveObject(ab);
    if (a == null) {
      throw ArgumentError('Second argument in String in getAbilitySelectionFromPersistentFormat must be an Ability, but it was not found: $persistentFormat');
    }
    String? sel;
    if (parts.length > 2) {
      sel = parts[2];
    } else if (persistentFormat.endsWith('|')) {
      sel = '';
    }
    if (parts.length > 3) {
      throw ArgumentError('String in getAbilitySelectionFromPersistentFormat must have 2 or 3 arguments, but found more: $persistentFormat');
    }
    return AbilitySelection(a, sel);
  }

  static AbilitySelection _decodeFeatSelectionChoice(LoadContext context, String persistentFormat) {
    final refCtx = context.getReferenceContext();
    final featCategory = refCtx.getAbilityCategory('FEAT');
    final featManufacturer = refCtx.getManufacturerId(featCategory!);
    Ability? ability = featManufacturer.getActiveObject(persistentFormat);

    if (ability == null) {
      final choices = <String>[];
      final baseKey = AbilityUtilities.getUndecoratedName(persistentFormat, choices);
      ability = featManufacturer.getActiveObject(baseKey);
      if (ability == null) {
        throw ArgumentError('String in decodeChoice must be a Feat Key (or Feat Key with Selection if appropriate), was: $persistentFormat');
      }
      return AbilitySelection(ability, choices[0]);
    } else if (ability.getSafeObject(CDOMObjectKey.getConstant('MULT')) == true) {
      // MULT:YES, CHOOSE:NOCHOICE
      return AbilitySelection(ability, '');
    } else {
      return AbilitySelection(ability, null);
    }
  }

  String getPersistentFormat() {
    final ability = getObject();
    final sb = StringBuffer('CATEGORY=');
    sb.write(ability.getCDOMCategory()?.getKeyName());
    sb.write('|');
    sb.write(ability.getKeyName());
    final sel = getSelection();
    if (sel != null) {
      sb.write('|');
      sb.write(sel);
    }
    return sb.toString();
  }

  String getAbilityKey() => getObject().getKeyName();

  @override
  String toString() {
    final sb = StringBuffer(getAbilityKey());
    final sel = getSelection();
    if (sel != null && sel.isNotEmpty) {
      sb.write(' (');
      sb.write(sel);
      sb.write(')');
    }
    return sb.toString();
  }

  @override
  int compareTo(AbilitySelection o) {
    final acompare = getObject().compareTo(o.getObject());
    if (acompare != 0) return acompare;
    final sel = getSelection();
    final osel = o.getSelection();
    if (sel == osel) return 0;
    if (sel == null) return -1;
    if (osel == null) return 1;
    return sel.compareTo(osel);
  }

  @override
  CDOMObject getCDOMObject() => getObject();
}
