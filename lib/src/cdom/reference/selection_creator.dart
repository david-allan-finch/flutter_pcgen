import '../base/class_identity.dart';
import '../base/loadable.dart';
import 'cdom_group_ref.dart';
import 'cdom_single_ref.dart';

// A SelectionCreator can create various forms of CDOMReferences for a supported
// type of object (as identified by its ClassIdentity).
abstract interface class SelectionCreator<T extends Loadable> {
  // Returns a single-object reference for the given key.
  CDOMSingleRef<T> getReference(String key);

  // Returns a type-filtered group reference for the given types.
  CDOMGroupRef<T> getTypeReference(List<String> types);

  // Returns a reference to ALL objects of the represented type.
  CDOMGroupRef<T> getAllReference();

  // The runtime class of the represented type.
  Type getReferenceClass();

  // Human-readable description of the contents.
  String getReferenceDescription();

  // The ClassIdentity for this SelectionCreator.
  ClassIdentity<T> getReferenceIdentity();
}
