import '../enumeration/grouping_state.dart';
import '../../core/player_character.dart';

// Wraps an ObjectContainer as a PrimitiveCollection.
class ObjectContainerPrimitive<T> {
  final dynamic _group; // ObjectContainer<T>

  ObjectContainerPrimitive(dynamic oc) : _group = oc;

  List getCollection(PlayerCharacter pc, dynamic c) =>
      List.from(c.convert(_group));

  Type getReferenceClass() => _group.getReferenceClass();

  GroupingState getGroupingState() => GroupingState.any;

  String getLSTformat(bool useAny) => _group.getLSTformat(useAny) as String;

  @override
  int get hashCode => _group.hashCode - 1;

  @override
  bool operator ==(Object obj) =>
      obj is ObjectContainerPrimitive && obj._group == _group;
}
