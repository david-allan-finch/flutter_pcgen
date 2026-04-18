// PrimitiveFilter tests whether a given object should be included when
// evaluating a PrimitiveCollection for a particular PlayerCharacter.
abstract interface class PrimitiveFilter<T> {
  bool allow(dynamic pc, T obj);
}
