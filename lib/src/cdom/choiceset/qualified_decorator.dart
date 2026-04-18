import '../enumeration/grouping_state.dart';

// Decorates a PrimitiveChoiceSet to restrict its items to those for which the
// PlayerCharacter meets the prerequisites defined by each item itself.
class QualifiedDecorator<T> {
  // The underlying choice set from which qualifying items are returned.
  final dynamic _underlyingPcs; // PrimitiveChoiceSet<T>

  QualifiedDecorator(dynamic underlyingSet) : _underlyingPcs = underlyingSet;

  Type getChoiceClass() => _underlyingPcs.getChoiceClass() as Type;

  String getLSTformat(bool useAny) =>
      _underlyingPcs.getLSTformat(useAny) as String;

  // Returns only items that the PlayerCharacter qualifies for.
  Set<T> getSet(dynamic pc) {
    final Set<T> returnSet = {};
    for (final T item in (_underlyingPcs.getSet(pc) as Iterable).cast<T>()) {
      // stub: item.qualifies(pc, item)
      final bool qualifies = (item as dynamic).qualifies(pc, item) as bool; // stub
      if (qualifies) {
        returnSet.add(item);
      }
    }
    return returnSet;
  }

  @override
  bool operator ==(Object obj) {
    return obj is QualifiedDecorator &&
        obj._underlyingPcs == _underlyingPcs;
  }

  @override
  int get hashCode => 1 - (_underlyingPcs.hashCode as int);

  GroupingState getGroupingState() =>
      (_underlyingPcs.getGroupingState() as GroupingState).reduce();
}
