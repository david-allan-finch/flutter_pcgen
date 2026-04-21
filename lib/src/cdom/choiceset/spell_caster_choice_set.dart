//
// Copyright 2006 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.choiceset.SpellCasterChoiceSet
import '../base/constants.dart';
import '../enumeration/fact_key.dart';
import '../enumeration/grouping_state.dart';
import '../reference/cdom_group_ref.dart';

// stub: ChoiceSet base class (not yet translated)
class _ChoiceSetBase {
  final String _name;
  final dynamic _pcs;

  _ChoiceSetBase(String name, dynamic pcs)
      : _name = name,
        _pcs = pcs;

  String getName() => _name;
}

// An empty PrimitiveChoiceSet for PCClass used when no type-based classes exist.
class _EmptyChoiceSet {
  Type getChoiceClass() => dynamic;
  String getLSTformat(bool useAny) => Constants.emptyString;
  Set<dynamic> getSet(dynamic pc) => {};
  GroupingState getGroupingState() => GroupingState.any;
}

// A PrimitiveChoiceSet for PCClass objects, combining:
//   - Group-based class references (types), filtered to classes the PC has levels in
//   - Individual (primitive) class references, added unconditionally
//   - Spell-type strings matched against all known classes
class SpellCasterChoiceSet extends _ChoiceSetBase {
  static final _EmptyChoiceSet _emptyChoiceSet = _EmptyChoiceSet();

  // Cache of all PCClass objects (avoids ReferenceContext at runtime).
  final CDOMGroupRef<dynamic> _allClasses; // CDOMGroupRef<PCClass>

  // Spell type strings.
  final List<String> _spelltypes;

  // Group-based class references (TYPE= style).
  final dynamic _types; // PrimitiveChoiceSet<PCClass>?

  // Individual (primitive) class references.
  final dynamic _primitives; // PrimitiveChoiceSet<PCClass>?

  SpellCasterChoiceSet(
    CDOMGroupRef<dynamic> allRef,
    List<String> spelltype,
    dynamic typePCS,
    dynamic primPCS,
  )   : _allClasses = allRef,
        _spelltypes = List<String>.from(spelltype),
        _types = typePCS,
        _primitives = primPCS,
        super('SPELLCASTER', typePCS ?? _emptyChoiceSet);

  String getLSTformat([bool useAny = true]) {
    final List<String> list = [];
    if (_primitives != null) {
      list.add(_primitives.getLSTformat(useAny) as String);
    }
    if (_types != null) {
      list.add(_types.getLSTformat(useAny) as String);
    }
    if (_spelltypes.isNotEmpty) {
      list.addAll(_spelltypes);
    }
    return list.join(Constants.comma);
  }

  Type getChoiceClass() => dynamic; // stub: PCClass

  // Returns the set of PCClass objects available for the given PlayerCharacter.
  // Group refs are filtered to classes the PC already has levels in;
  // primitive refs are added unconditionally;
  // spell-type strings are matched against all known classes.
  Set<dynamic> getSet(dynamic pc) {
    final FactKey<String> fk = FactKey.valueOf<String>('SpellType');
    final Set<dynamic> returnSet = {};

    if (_types != null) {
      for (final dynamic pcc in (_types.getSet(pc) as Iterable)) {
        // stub: pcc.get(fk) and pc.getClassKeyed(pcc.getKeyName())
        final bool hasSpellType = pcc.get(fk) != null; // stub
        final bool hasPcLevel =
            pc.getClassKeyed(pcc.getKeyName()) != null; // stub
        if (hasSpellType && hasPcLevel) {
          returnSet.add(pcc);
        }
      }
    }

    if (_primitives != null) {
      returnSet.addAll(_primitives.getSet(pc) as Iterable);
    }

    for (final dynamic pcc in _allClasses.getContainedObjects()) {
      outer:
      for (final String type in _spelltypes) {
        // stub: pcc.getResolved(fk) and pc.getClassKeyed(pcc.getKeyName())
        final String? spelltype = pcc.getResolved(fk) as String?; // stub
        if (spelltype != null &&
            type.toLowerCase() == spelltype.toLowerCase() &&
            pc.getClassKeyed(pcc.getKeyName()) != null) { // stub
          returnSet.add(pcc);
          break outer;
        }
      }
    }

    return returnSet;
  }

  @override
  int get hashCode =>
      (_types == null ? 0 : (_types.hashCode as int) * 29) +
      (_primitives == null ? 0 : _primitives.hashCode as int);

  @override
  bool operator ==(Object obj) {
    if (identical(this, obj)) return true;
    if (obj is SpellCasterChoiceSet) {
      if (_types == null) {
        if (obj._types != null) return false;
      } else {
        if (_types != obj._types) return false;
      }
      if (_primitives == null) {
        return obj._primitives == null;
      }
      return _primitives == obj._primitives;
    }
    return false;
  }

  GroupingState getGroupingState() {
    GroupingState state = GroupingState.empty;
    if (_primitives != null) {
      state = (_primitives.getGroupingState() as GroupingState).add(state);
    }
    if (_types != null) {
      state = (_types.getGroupingState() as GroupingState).add(state);
    }
    if (_spelltypes.isNotEmpty) {
      state = GroupingState.any.add(state);
    }
    // TODO: may need state.compound(GroupingState.allowsUnion)
    return state;
  }
}
