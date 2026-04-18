// A Processor takes an object of type T and returns a (possibly modified) T.
abstract interface class Processor<T> {
  // Applies this processor to the given input in the given context.
  T applyProcessor(T obj, Object context);

  // The class of object this Processor acts upon.
  Type getModifiedClass();

  // Returns the LST representation of this Processor.
  String getLSTformat();
}
