//
// Copyright 2010-14 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.choiceset.CollectionToAbilitySelection
import 'package:flutter_pcgen/src/cdom/base/cdom_reference.dart';
import 'package:flutter_pcgen/src/cdom/content/ability_selection.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/grouping_state.dart';

// Wraps a PrimitiveCollection of Ability objects and provides AbilitySelection
// objects, expanding MULT:YES abilities to all available sub-choices.
class CollectionToAbilitySelection {
  // The underlying collection of Ability objects.
  final dynamic _collection; // PrimitiveCollection<Ability>

  // The AbilityCategory from which Ability objects are drawn.
  final dynamic _category; // AbilityCategory

  // Infinite loop detection stack (shared across all instances as in Java).
  static final List<dynamic> _infiniteLoopDetectionStack = [];

  CollectionToAbilitySelection(dynamic category, dynamic collection)
      : _category = category,
        _collection = collection {
    ArgumentError.checkNotNull(category, 'category');
    ArgumentError.checkNotNull(collection, 'collection');
  }

  Type getChoiceClass() => AbilitySelection;

  GroupingState getGroupingState() =>
      _collection.getGroupingState() as GroupingState;

  String getLSTformat([bool useAny = false]) =>
      _collection.getLSTformat(useAny) as String;

  List<AbilitySelection> getSet(dynamic pc) {
    final Iterable aColl =
        _collection.getCollection(pc, ExpandingConverter(pc)) as Iterable;
    final Set<AbilitySelection> returnSet = {};
    for (final dynamic awc in aColl) {
      _processAbility(pc, returnSet, awc);
    }
    return returnSet.toList();
  }

  void _processAbility(
    dynamic character,
    Set<AbilitySelection> returnSet,
    dynamic awc, // AbilityWithChoice
  ) {
    final dynamic a = awc.getAbility();
    if (_infiniteLoopDetectionStack.contains(a)) {
      final current = List<dynamic>.from(_infiniteLoopDetectionStack);
      // stub: Logging.errorPrint(...)
      _reportCircularExpansion(current); // stub
      return;
    }
    _infiniteLoopDetectionStack.add(a);
    try {
      // stub: a.getSafeObject(CDOMObjectKey.MULTIPLE_ALLOWED)
      final bool multAllowed = a.getSafeObject(CDOMObjectKey.getConstant('MULT')) as bool; // stub
      if (multAllowed) {
        returnSet.addAll(
          _addMultiplySelectableAbility(character, a, awc.getChoice() as String?),
        );
      } else {
        returnSet.add(AbilitySelection(a, null));
      }
    } finally {
      _infiniteLoopDetectionStack.removeLast();
    }
  }

  List<AbilitySelection> _addMultiplySelectableAbility(
    dynamic aPC,
    dynamic ability,
    String? subName,
  ) {
    bool isPattern = false;
    String? nameRoot;
    if (subName != null) {
      final int percIdx = subName.indexOf('%');
      if (percIdx > -1) {
        isPattern = true;
        nameRoot = subName.substring(0, percIdx);
      } else if (subName.isNotEmpty) {
        nameRoot = subName;
      }
    }

    // stub: ability.getObject(CDOMObjectKey.CHOOSE_INFO)
    final dynamic chooseInfo = ability.get(null); // stub
    final List<String> availableList = _getAvailableList(aPC, chooseInfo);

    if (nameRoot != null && nameRoot.isNotEmpty) {
      availableList.removeWhere((s) => !s.startsWith(nameRoot!));
      if (isPattern && availableList.isNotEmpty) {
        availableList.add(nameRoot!);
      }
    }

    return availableList
        .map((s) => AbilitySelection(ability, s))
        .toList();
  }

  List<String> _getAvailableList(dynamic aPC, dynamic chooseInfo) {
    final List<String> availableList = [];
    // stub: chooseInfo.getSet(aPC)
    final Iterable tempAvailList = chooseInfo.getSet(aPC) as Iterable; // stub
    for (final dynamic o in tempAvailList) {
      availableList.add(chooseInfo.encodeChoice(o) as String);
    }
    return availableList;
  }

  // stub: builds circular expansion error message
  String _reportCircularExpansion(List<dynamic> stack) {
    // stub
    final sb = StringBuffer();
    _processCircularExpansion(sb, stack);
    sb.write('    which is a circular reference');
    return sb.toString();
  }

  void _processCircularExpansion(StringBuffer sb, List<dynamic> stack) {
    // stub: mirrors Java recursive stack-pop approach
    if (stack.isEmpty) return;
    final dynamic a = stack.removeLast();
    if (stack.isNotEmpty) {
      _processCircularExpansion(sb, stack);
      sb.write('     which includes');
    }
    sb.write(a.getCDOMCategory());
    sb.write(' ');
    sb.write(a.getKeyName());
    sb.write(' selects items: ');
    sb.write(a.get(null)?.getLSTformat()); // stub
    sb.write('\n');
  }

  dynamic getCategory() => _category;

  @override
  int get hashCode => _collection.hashCode as int;

  @override
  bool operator ==(Object obj) {
    return obj is CollectionToAbilitySelection &&
        obj._collection == _collection;
  }
}

// Converts ObjectContainer<Ability> to AbilityWithChoice objects,
// extracting choice strings from CDOMReference containers.
class ExpandingConverter implements Converter<dynamic, _AbilityWithChoice> {
  final dynamic _character;

  ExpandingConverter(dynamic pc) : _character = pc;

  @override
  List<_AbilityWithChoice> convert(ObjectContainer<dynamic> ref) {
    final Set<_AbilityWithChoice> returnSet = {};
    for (final dynamic a in ref.getContainedObjects()) {
      _processAbility(ref, returnSet, a);
    }
    return returnSet.toList();
  }

  List<_AbilityWithChoice> convertWithFilter(
    ObjectContainer<dynamic> ref,
    dynamic lim, // PrimitiveFilter<Ability>
  ) {
    final Set<_AbilityWithChoice> returnSet = {};
    for (final dynamic a in ref.getContainedObjects()) {
      // stub: lim.allow(character, a)
      final bool allowed = lim.allow(_character, a) as bool; // stub
      if (allowed) {
        _processAbility(ref, returnSet, a);
      }
    }
    return returnSet.toList();
  }

  void _processAbility(
    ObjectContainer<dynamic> ref,
    Set<_AbilityWithChoice> returnSet,
    dynamic a,
  ) {
    String? choice;
    if (ref is CDOMReference) {
      choice = ref.getChoice();
    }
    returnSet.add(_AbilityWithChoice(a, choice));
  }
}

// Internal pairing of an Ability with an optional choice string.
// NOT an AbilitySelection — avoids premature MULT:YES enforcement.
class _AbilityWithChoice {
  final dynamic _ability;
  final String? _choice;

  _AbilityWithChoice(dynamic ability, String? choice)
      : _ability = ability,
        _choice = choice;

  dynamic getAbility() => _ability;
  String? getChoice() => _choice;

  @override
  int get hashCode =>
      _ability.hashCode ^ (_choice == null ? 17 : _choice.hashCode);

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    if (o is _AbilityWithChoice) {
      if (_choice == null) {
        if (o._choice != null) return false;
      }
      return _ability == o._ability &&
          (_choice == o._choice || _choice == o._choice);
    }
    return false;
  }
}
