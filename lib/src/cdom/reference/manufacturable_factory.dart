import '../base/class_identity.dart';
import '../base/loadable.dart';
import 'cdom_single_ref.dart';
import 'reference_manufacturer.dart';
import 'selection_creator.dart';
import 'unconstructed_validator.dart';

// A ManufacturableFactory is a factory for Loadable objects, combining
// SelectionCreator capability with direct object construction.
abstract interface class ManufacturableFactory<T extends Loadable>
    implements SelectionCreator<T> {
  // Constructs a new instance of the object this factory creates.
  T newInstance();

  // Returns true if the given item could have been created by this factory.
  bool isMember(T item);

  // Resolves the given CDOMSingleRef with the named object from the given
  // manufacturer, consulting the validator for permissible errors.
  bool resolve(ReferenceManufacturer<T> rm, String name,
      CDOMSingleRef<T> reference, UnconstructedValidator validator);

  // Populates the given manufacturer with references from the parent
  // manufacturer (for hierarchical Category objects).
  bool populate(ReferenceManufacturer<T> parent, ReferenceManufacturer<T> rm,
      UnconstructedValidator validator);

  // Returns the parent ManufacturableFactory, or null if none.
  ManufacturableFactory<T>? getParent();

  // Returns the persistent format string for the objects created by this factory.
  String getPersistentFormat();

  // Returns the ClassIdentity for this factory.
  // WARNING: may not be valid until after load is complete.
  @override
  ClassIdentity<T> getReferenceIdentity();
}
