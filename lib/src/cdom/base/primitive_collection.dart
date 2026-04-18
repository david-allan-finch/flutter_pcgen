import '../enumeration/grouping_state.dart';
import 'converter.dart';

// PrimitiveCollection can resolve itself to a typed collection given a
// PlayerCharacter and a Converter.
abstract interface class PrimitiveCollection<T> {
  List<R> getCollection<R>(dynamic pc, Converter<T, R> c);

  GroupingState getGroupingState();

  Type getReferenceClass();

  String getLSTformat(bool useAny);

  // Sentinel "invalid" singleton.
  static final PrimitiveCollection _invalid = _InvalidPrimitiveCollection();

  static PrimitiveCollection<T> getInvalid<T>() =>
      _invalid as PrimitiveCollection<T>;
}

// PrimLibrary provides a typed way to obtain the invalid PrimitiveCollection.
abstract interface class PrimLibrary {
  PrimitiveCollection<PCT> invalid<PCT>();
}

// FIXED is a PrimLibrary that always returns the invalid PrimitiveCollection.
final PrimLibrary fixed = _FixedPrimLibrary();

class _FixedPrimLibrary implements PrimLibrary {
  @override
  PrimitiveCollection<PCT> invalid<PCT>() => PrimitiveCollection.getInvalid<PCT>();
}

class _InvalidPrimitiveCollection implements PrimitiveCollection<Object> {
  @override
  List<R> getCollection<R>(dynamic pc, Converter<Object, R> c) => const [];

  @override
  GroupingState getGroupingState() => GroupingState.invalid;

  @override
  String getLSTformat(bool useAny) => 'ERROR';

  @override
  Type getReferenceClass() => Object;
}
