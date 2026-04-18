import '../base/cdom_reference.dart';
import '../enumeration/grouping_state.dart';

// A PrimitiveChoiceSet that wraps a PrimitiveCollection, dereferencing objects
// through a DereferencingConverter for the given PlayerCharacter.
class CollectionToChoiceSet<T> {
  final PrimitiveCollection<T> _primitive;

  CollectionToChoiceSet(PrimitiveCollection<T> prim) : _primitive = prim;

  Type getChoiceClass() => _primitive.getReferenceClass();

  GroupingState getGroupingState() => _primitive.getGroupingState();

  String getLSTformat(bool useAny) => _primitive.getLSTformat(useAny);

  List<T> getSet(dynamic pc) {
    // stub: DereferencingConverter
    return _primitive.getCollection(pc, _DereferencingConverter<T>(pc))
        .cast<T>();
  }

  @override
  int get hashCode => _primitive.hashCode;

  @override
  bool operator ==(Object obj) {
    return obj is CollectionToChoiceSet &&
        obj._primitive == _primitive;
  }
}

// stub: Dereferencing converter that resolves references for a PlayerCharacter.
class _DereferencingConverter<T> implements Converter<T, T> {
  final dynamic _pc;

  _DereferencingConverter(this._pc);

  @override
  List<T> convert(ObjectContainer<T> container) {
    // stub
    return container.getContainedObjects();
  }
}
