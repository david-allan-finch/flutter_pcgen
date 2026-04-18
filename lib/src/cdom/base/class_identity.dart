// ClassIdentity uniquely identifies a type of object in PCGen, handling both
// plain class equality and categorized object equality (e.g. Abilities by Category).
abstract interface class ClassIdentity<T> {
  String getName();
  Type getReferenceClass();
  T newInstance();
  String getReferenceDescription();
  bool isMember(T item);
  String getPersistentFormat();
}
