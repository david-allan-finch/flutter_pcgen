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
// Translation of pcgen.cdom.helper.CNAbilitySelection
import '../base/cdom_object.dart';
import '../base/concrete_prereq_object.dart';
import '../base/qualifying_object.dart';
import '../base/reducible.dart';
import '../content/cn_ability.dart';
import '../content/cn_ability_factory.dart';
import '../enumeration/nature.dart';
import '../../core/ability.dart';
import '../../rules/context/load_context.dart';

// Pairs a CNAbility with an optional selection string.
class CnAbilitySelection extends ConcretePrereqObject implements QualifyingObject, Reducible {
  final CnAbility _cna;
  final String? _selection;

  CnAbilitySelection(CnAbility cna, [String? choice])
      : _cna = cna,
        _selection = choice;

  CnAbility getCNAbility() => _cna;
  String? getSelection() => _selection;
  String getAbilityKey() => _cna.getAbilityKey();

  bool containsAssociation(String? assoc) =>
      assoc == null ? _selection == null : assoc == _selection;

  String getPersistentFormat() {
    final sb = StringBuffer('CATEGORY=');
    sb.write(_cna.getAbilityCategory().getKeyName());
    sb.write('|NATURE=');
    sb.write(_cna.getNature());
    sb.write('|');
    sb.write(_cna.getAbilityKey());
    if (_selection != null) {
      sb.write('|');
      sb.write(_selection);
    }
    return sb.toString();
  }

  static CnAbilitySelection getAbilitySelectionFromPersistentFormat(LoadContext context, String persistentFormat) {
    final parts = persistentFormat.split('|');
    if (!parts[0].startsWith('CATEGORY=')) {
      throw ArgumentError('String in getAbilitySelectionFromPersistentFormat must start with CATEGORY=, found: $persistentFormat');
    }
    final cat = parts[0].substring(9);
    final ac = context.getReferenceContext().getAbilityCategory(cat);
    if (ac == null) {
      throw ArgumentError('Category in getAbilitySelectionFromPersistentFormat must exist found: $cat');
    }
    if (parts.length < 2 || !parts[1].startsWith('NATURE=')) {
      throw ArgumentError('Second argument must start with NATURE=, found: $persistentFormat');
    }
    final natString = parts[1].substring(7);
    final nat = Nature.values.firstWhere((n) => n.name.toLowerCase() == natString.toLowerCase(),
        orElse: () => throw ArgumentError('Invalid Nature: $natString'));
    if (parts.length < 3) {
      throw ArgumentError('getAbilitySelectionFromPersistentFormat must have at least 3 arguments: $persistentFormat');
    }
    final ab = parts[2];
    final a = context.getReferenceContext().getManufacturerId(ac).getActiveObject(ab);
    if (a == null) {
      throw ArgumentError('Third argument must be an Ability key, not found: $persistentFormat');
    }
    String? sel;
    if (parts.length > 3) {
      sel = parts[3];
    } else if (persistentFormat.endsWith('|')) {
      sel = '';
    }
    if (parts.length > 4) {
      throw ArgumentError('getAbilitySelectionFromPersistentFormat must have 3 or 4 arguments: $persistentFormat');
    }
    final cna = CnAbilityFactory.getCNAbility(ac, nat, a);
    return CnAbilitySelection(cna, sel);
  }

  String getFullAbilityKey() {
    final sb = StringBuffer(_cna.getAbilityKey());
    if (_selection != null && _selection!.isNotEmpty) {
      sb.write('(');
      sb.write(_selection);
      sb.write(')');
    }
    return sb.toString();
  }

  @override
  String toString() {
    final sb = StringBuffer(_cna.getAbility().getDisplayName());
    if (_selection != null && _selection!.isNotEmpty) {
      sb.write('(');
      sb.write(_selection);
      sb.write(')');
    }
    return sb.toString();
  }

  @override
  bool operator ==(Object other) {
    if (other is CnAbilitySelection) {
      return _selection == other._selection && _cna == other._cna;
    }
    return false;
  }

  @override
  int get hashCode => _cna.hashCode;

  @override
  CdomObject getCDOMObject() => _cna.getCDOMObject();
}
