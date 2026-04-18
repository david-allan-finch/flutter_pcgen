import '../base/cdom_reference.dart';
import '../base/constants.dart';
import '../content/cn_ability_factory.dart';
import '../enumeration/grouping_state.dart';
import '../enumeration/nature.dart';
import '../helper/cn_ability_selection.dart';
import '../reference/cdom_single_ref.dart';

// A PrimitiveChoiceSet for CNAbilitySelection objects built from a set of
// CDOMReferences to Ability objects, a category, and a nature.
class AbilityRefChoiceSet {
  // The underlying set of CDOMReferences to Ability objects.
  final Set<CDOMReference<dynamic>> _abilityRefSet;

  // The Ability Category for the abilities in this set.
  final CDOMSingleRef<dynamic> _category; // CDOMSingleRef<AbilityCategory>

  // The Nature with which abilities should be applied to a PlayerCharacter.
  final Nature _nature;

  AbilityRefChoiceSet(
    CDOMSingleRef<dynamic> cat,
    List<CDOMReference<dynamic>> arCollection,
    Nature nat,
  )   : _abilityRefSet = {},
        _category = cat,
        _nature = nat {
    if (arCollection.isEmpty) {
      throw ArgumentError('Choice Collection cannot be empty');
    }
    _abilityRefSet.addAll(arCollection);
  }

  String getLSTformat(bool useAny) {
    // Sort by LST format for determinism (stub: ReferenceUtilities.REFERENCE_SORTER).
    final sorted = _abilityRefSet.toList()
      ..sort((a, b) {
        final al = a.getLSTformat(false);
        final bl = b.getLSTformat(false);
        return al.compareTo(bl); // stub
      });
    return _joinLstFormat(sorted, Constants.comma, useAny);
  }

  // stub: inline join
  String _joinLstFormat(
    List<CDOMReference<dynamic>> refs,
    String separator,
    bool useAny,
  ) {
    return refs.map((r) => r.getLSTformat(useAny)).join(separator);
  }

  Type getChoiceClass() => CnAbilitySelection;

  // Returns a set of CNAbilitySelection objects for all abilities in all refs.
  Set<CnAbilitySelection> getSet(dynamic pc) {
    final Set<CnAbilitySelection> returnSet = {};
    for (final CDOMReference<dynamic> ref in _abilityRefSet) {
      for (final dynamic a in ref.getContainedObjects()) {
        // stub: a.getSafe(ObjectKey.MULTIPLE_ALLOWED)
        final bool multAllowed = a.getSafe(null) as bool; // stub
        if (multAllowed) {
          returnSet.addAll(
            _addMultiplySelectableAbility(pc, a, ref.getChoice()),
          );
        } else {
          returnSet.add(
            CnAbilitySelection(
              CNAbilityFactory.getCNAbility(_category.get(), _nature, a),
            ),
          );
        }
      }
    }
    return returnSet;
  }

  List<CnAbilitySelection> _addMultiplySelectableAbility(
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

    // stub: ability.get(ObjectKey.CHOOSE_INFO)
    final dynamic chooseInfo = ability.get(null); // stub
    final List<String> availableList = _getAvailableList(aPC, chooseInfo);

    // Special-case: DEITYWEAPON for WeaponProf references.
    // stub: chooseInfo.getReferenceClass().equals(WeaponProf.class)
    if ('DEITYWEAPON' == nameRoot) {
      // stub: channel lookup for deity weapon
      _applyDeityWeaponFilter(aPC, availableList); // stub
    } else if (nameRoot != null && nameRoot.isNotEmpty) {
      availableList.removeWhere((s) => !s.startsWith(nameRoot!));
      if (isPattern && availableList.isNotEmpty) {
        availableList.add(nameRoot!);
      }
    }

    return availableList
        .map((s) => CnAbilitySelection(
              CNAbilityFactory.getCNAbility(_category.get(), _nature, ability),
              s,
            ))
        .toList();
  }

  // stub: filters availableList to only deity weapon profs
  void _applyDeityWeaponFilter(dynamic aPC, List<String> availableList) {
    // stub
    // In Java: reads DEITYINPUT channel, retains only weapon profs matching the deity's weapons.
    availableList.clear(); // stub: no deity lookup implemented
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

  @override
  int get hashCode => _abilityRefSet.length;

  @override
  bool operator ==(Object obj) {
    if (identical(this, obj)) return true;
    if (obj is AbilityRefChoiceSet) {
      return _abilityRefSet.length == obj._abilityRefSet.length &&
          _abilityRefSet.containsAll(obj._abilityRefSet);
    }
    return false;
  }

  CDOMSingleRef<dynamic> getCategory() => _category;

  Nature getNature() => _nature;

  GroupingState getGroupingState() {
    GroupingState state = GroupingState.empty;
    for (final CDOMReference<dynamic> ref in _abilityRefSet) {
      state = state.add(ref.getGroupingState());
    }
    return state;
  }
}
