import '../base/cdom_reference.dart';
import '../base/constants.dart';
import '../enumeration/grouping_state.dart';

// A PrimitiveChoiceSet whose contents are defined by a collection of
// CDOMReferences. The contents are fixed and do not vary by PlayerCharacter.
class ReferenceChoiceSet<T> {
  // The underlying collection of CDOMReferences.
  final List<CDOMReference<T>> _refCollection;

  ReferenceChoiceSet(List<CDOMReference<T>> col) : _refCollection = [] {
    if (col.isEmpty) {
      throw ArgumentError('Choice Collection cannot be empty');
    }
    _refCollection.addAll(col);
  }

  String getLSTformat(bool useAny) {
    // Sort by reference LST format for determinism.
    final sorted = List<CDOMReference<T>>.from(_refCollection)
      ..sort((a, b) {
        // stub: ReferenceUtilities.REFERENCE_SORTER
        return a.getLSTformat(false).compareTo(b.getLSTformat(false)); // stub
      });
    return _joinLstFormat(sorted, Constants.comma, useAny);
  }

  // stub: inline join since ReferenceUtilities not yet translated
  String _joinLstFormat(
    List<CDOMReference<T>> refs,
    String separator,
    bool useAny,
  ) {
    final parts = refs.map((r) => r.getLSTformat(useAny));
    return parts.join(separator);
  }

  Type getChoiceClass() {
    return _refCollection.isEmpty
        ? dynamic
        : _refCollection.first.getReferenceClass();
  }

  // Returns a set containing all objects from all references.
  Set<T> getSet(dynamic pc) {
    final Set<T> returnSet = {};
    for (final CDOMReference<T> ref in _refCollection) {
      returnSet.addAll(ref.getContainedObjects());
    }
    return returnSet;
  }

  @override
  int get hashCode => _refCollection.length;

  @override
  bool operator ==(Object obj) {
    if (identical(this, obj)) return true;
    if (obj is ReferenceChoiceSet<T>) {
      if (_refCollection.length != obj._refCollection.length) return false;
      for (int i = 0; i < _refCollection.length; i++) {
        if (_refCollection[i] != obj._refCollection[i]) return false;
      }
      return true;
    }
    return false;
  }

  GroupingState getGroupingState() {
    GroupingState state = GroupingState.empty;
    for (final CDOMReference<T> ref in _refCollection) {
      state = ref.getGroupingState().add(state);
    }
    return state.compound(GroupingState.allowsUnion);
  }
}
