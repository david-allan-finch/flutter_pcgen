import '../enumeration/grouping_state.dart';
import '../../core/player_character.dart';

// A PrimitiveCollection that returns all objects EXCEPT those in its wrapped primitive.
class NegatingPrimitive<T> {
  final dynamic _primitive; // PrimitiveCollection<T>
  final dynamic _all; // PrimitiveCollection<T>

  NegatingPrimitive(dynamic prim, dynamic all)
      : _primitive = prim,
        _all = all;

  List getCollection(PlayerCharacter pc, dynamic c) {
    final result = List.from(_all.getCollection(pc, c));
    result.removeWhere((e) => _primitive.getCollection(pc, c).contains(e));
    return result;
  }

  Type getReferenceClass() => _primitive.getReferenceClass();

  GroupingState getGroupingState() =>
      (_primitive.getGroupingState() as GroupingState).negate();

  String getLSTformat(bool useAny) =>
      '!${_primitive.getLSTformat(useAny)}';

  @override
  int get hashCode => _primitive.hashCode - 1;

  @override
  bool operator ==(Object obj) =>
      obj is NegatingPrimitive && obj._primitive == _primitive;
}
