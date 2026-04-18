import '../enumeration/grouping_state.dart';
import '../../core/player_character.dart';
import 'primitive_utilities.dart';

// PrimitiveCollection that returns the intersection of multiple sub-collections.
class CompoundAndPrimitive<T> {
  final Type? _refClass;
  final List<dynamic> _primCollection; // sorted by LST format

  CompoundAndPrimitive(List<dynamic> pcfCollection)
      : _primCollection = List.from(pcfCollection)
          ..sort(PrimitiveUtilities.collectionSorter),
        _refClass = pcfCollection.isEmpty
            ? null
            : pcfCollection.first.getReferenceClass() as Type {
    if (pcfCollection.isEmpty) {
      throw ArgumentError('Collection for CompoundAndPrimitive cannot be empty');
    }
  }

  Set<dynamic> getCollection(PlayerCharacter pc, dynamic c) {
    Set<dynamic>? returnSet;
    for (final cs in _primCollection) {
      final col = Set<dynamic>.from(cs.getCollection(pc, c) as Iterable);
      if (returnSet == null) {
        returnSet = col;
      } else {
        returnSet = returnSet.intersection(col);
      }
    }
    return returnSet ?? {};
  }

  Type? getReferenceClass() => _refClass;

  GroupingState getGroupingState() {
    var state = GroupingState.empty;
    for (final pcs in _primCollection) {
      state = (pcs.getGroupingState() as GroupingState).add(state);
    }
    return state.compound(GroupingState.allowsIntersection);
  }

  String getLSTformat(bool useAny) =>
      PrimitiveUtilities.joinLstFormat(_primCollection, ',', useAny);

  @override
  int get hashCode => _primCollection.fold(0, (h, e) => h ^ e.hashCode);

  @override
  bool operator ==(Object obj) =>
      obj is CompoundAndPrimitive &&
      _listEquals(obj._primCollection, _primCollection);

  static bool _listEquals(List a, List b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
