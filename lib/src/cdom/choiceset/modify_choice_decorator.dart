import '../content/cn_ability.dart';
import '../enumeration/grouping_state.dart';

// A PrimitiveChoiceSet that returns the MULT:YES feats possessed by a
// PlayerCharacter that also appear in an underlying set of Ability objects.
// This is a special-case decorator for the MODIFYFEATCHOICE token.
class ModifyChoiceDecorator {
  // The underlying set that identifies Ability (Feat) objects from the LST file.
  final dynamic _pcs; // PrimitiveChoiceSet<Ability>

  ModifyChoiceDecorator(dynamic underlyingSet) : _pcs = underlyingSet;

  Type getChoiceClass() => CNAbility;

  String getLSTformat(bool useAny) => _pcs.getLSTformat(useAny) as String;

  // Returns CNAbility objects that are in the underlying set AND are MULT:YES
  // feats possessed by the PlayerCharacter.
  Set<CNAbility> getSet(dynamic pc) {
    final collection = _pcs.getSet(pc) as Iterable; // Ability objects
    // stub: pc.getPoolAbilities(AbilityCategory.FEAT)
    final List<CNAbility> pcFeats =
        (pc.getPoolAbilities(null) as List).cast<CNAbility>(); // stub
    final Set<CNAbility> returnSet = {};
    for (final CNAbility cna in pcFeats) {
      final dynamic a = cna.getAbility();
      // stub: a.getSafe(ObjectKey.MULTIPLE_ALLOWED)
      final bool multAllowed = a.getSafe(null) as bool; // stub
      if (multAllowed && collection.contains(a)) {
        returnSet.add(cna);
      }
    }
    return returnSet;
  }

  @override
  bool operator ==(Object obj) {
    return obj is ModifyChoiceDecorator && obj._pcs == _pcs;
  }

  @override
  int get hashCode => _pcs.hashCode as int;

  GroupingState getGroupingState() =>
      _pcs.getGroupingState() as GroupingState;
}
