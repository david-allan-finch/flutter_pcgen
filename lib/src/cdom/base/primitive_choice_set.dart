import '../enumeration/grouping_state.dart';

// PrimitiveChoiceSet contains references to objects (often CDOMObjects) and
// can resolve its contents given a PlayerCharacter.
abstract interface class PrimitiveChoiceSet<T> {
  /// Returns the objects contained in this set for the given PlayerCharacter.
  Iterable<T> getSet(dynamic pc);

  /// Returns the runtime Type of the objects in this set.
  Type getChoiceClass();

  /// Returns an LST representation suitable for storing in a data file.
  String getLSTformat(bool useAny);

  /// Returns the GroupingState indicating how this set can be combined.
  GroupingState getGroupingState();

  // Sentinel "invalid" singleton.
  static final PrimitiveChoiceSet _invalid = _InvalidPrimitiveChoiceSet();

  static PrimitiveChoiceSet<T> getInvalid<T>() => _invalid as PrimitiveChoiceSet<T>;
}

class _InvalidPrimitiveChoiceSet implements PrimitiveChoiceSet<Object> {
  @override
  Iterable<Object> getSet(dynamic pc) => const [];

  @override
  Type getChoiceClass() => Object;

  @override
  GroupingState getGroupingState() => GroupingState.invalid;

  @override
  String getLSTformat(bool useAny) => 'ERROR';
}
