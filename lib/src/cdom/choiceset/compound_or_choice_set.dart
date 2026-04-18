import '../base/constants.dart';
import '../enumeration/grouping_state.dart';
import 'choice_set_utilities.dart';

// A PrimitiveChoiceSet that performs a logical OR (union) of multiple
// underlying choice sets: objects present in ANY set are included.
class CompoundOrChoiceSet<T> {
  // Sorted set of underlying choice sets (sorted by LST format for determinism).
  final List<dynamic> _pcsSet = [];
  final String _separator;

  CompoundOrChoiceSet(List<dynamic> pcsCollection)
      : this.withSeparator(pcsCollection, Constants.pipe);

  CompoundOrChoiceSet.withSeparator(List<dynamic> pcsCollection, String sep)
      : _separator = sep {
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

  // Returns the union of all underlying sets for the given PlayerCharacter.
  Set<T> getSet(dynamic pc) {
    final Set<T> returnSet = {};
    for (final dynamic cs in _pcsSet) {
      returnSet.addAll((cs.getSet(pc) as Iterable).cast<T>());
    }
    return returnSet;
  }

  String getLSTformat(bool useAny) {
    return ChoiceSetUtilities.joinLstFormat(_pcsSet, _separator, useAny);
  }

  Type getChoiceClass() {
    return (_pcsSet.first.getChoiceClass()) as Type;
  }

  @override
  int get hashCode => _pcsSet.fold(0, (h, e) => h ^ e.hashCode);

  @override
  bool operator ==(Object obj) {
    if (obj is CompoundOrChoiceSet) {
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
    return state.compound(GroupingState.allowsUnion);
  }
}
