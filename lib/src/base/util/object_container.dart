abstract interface class ObjectContainer<T> {
  List<T> getContainedObjects();
  String getLSTformat([bool useAny = false]);
}
