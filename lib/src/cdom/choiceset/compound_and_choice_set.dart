import '../base/constants.dart';
import '../enumeration/grouping_state.dart';
import 'choice_set_utilities.dart';

// A PrimitiveChoiceSet that performs a logical AND (intersection) of multiple
// underlying choice sets: only objects present in ALL sets are included.
class CompoundAndChoiceSet<T> {
  // Sorted set of underlying choice sets (sorted by LST format for determinism).
  final List<dynamic> _pcsSet = [];

  CompoundAndChoiceSet(List<dynamic> pcsCollection) {
    if (pcsCollection.isEmpty) {
      throw ArgumentError('Collection cannot be empty');
    }
    // Sort by LST format; detect duplicates.
    final sorted = List<dynamic>.from(pcsCollection)
      ..sort(ChoiceSetUtilities.compareChoiceSets);
    _pcsSet.addAll(sorted);
    if (_pcsSet.length != pcsCollection.length) {
      // stub: log duplicate warning
      // Logging.log(Level.WARNING, "Found duplicate item in $pcsCollection");
    }
  }

  // Returns the intersection of all underlying sets for the given PlayerCharacter.
  List<T> getSet(dynamic pc) {
    List<T>? returnSet;
    for (final dynamic cs in _pcsSet) {
      final List<T> current = (cs.getSet(pc) as Iterable).cast<T>().toList();
      if (returnSet == null) {
        returnSet = current;
      } else {
        returnSet = returnSet.where((e) => current.contains(e)).toList();
      }
    }
    return returnSet ?? [];
  }

  String getLSTformat(bool useAny) {
    return ChoiceSetUtilities.joinLstFormat(_pcsSet, Constants.comma, useAny);
  }

  Type getChoiceClass() {
    return (_pcsSet.first.getChoiceClass()) as Type;
  }

  @override
  int get hashCode => _pcsSet.fold(0, (h, e) => h ^ e.hashCode);

  @override
  bool operator ==(Object obj) {
    if (obj is CompoundAndChoiceSet) {
      if (_pcsSet.length != obj._pcsSet.length) return false;
      for (int i = 0; i < _pcsSet.length; i++) {
        if (_pcsSet[i] != obj._pcsSet[i]) return false;
      }
      return true;
    }
    return false;
  }

  GroupingState getGroupingState() {
    GroupingState state = GroupingState.empty;
    for (final dynamic pcs in _pcsSet) {
      state = (pcs.getGroupingState() as GroupingState).add(state);
    }
    return state.compound(GroupingState.allowsIntersection);
  }
}
