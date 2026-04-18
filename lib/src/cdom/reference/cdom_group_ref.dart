import '../base/cdom_reference.dart';

// A reference to a group of CDOMObjects (e.g., all Weapons, all Armor).
abstract interface class CDOMGroupRef<T> implements CDOMReference<T> {
  // Returns all objects contained in this group reference.
  List<T> getContainedObjects();

  // Adds an object to this group reference.
  void addResolution(T obj);
}
