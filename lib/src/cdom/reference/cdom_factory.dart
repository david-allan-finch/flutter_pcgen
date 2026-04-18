import '../base/class_identity.dart';
import '../base/loadable.dart';
import 'cdom_all_ref.dart';
import 'cdom_group_ref.dart';
import 'cdom_simple_single_ref.dart';
import 'cdom_single_ref.dart';
import 'cdom_type_ref.dart';
import 'manufacturable_factory.dart';
import 'reference_manufacturer.dart';
import 'unconstructed_validator.dart';

// A ManufacturableFactory that builds CDOMReferences for a specific ClassIdentity.
class CDOMFactory<T extends Loadable> implements ManufacturableFactory<T> {
  final ClassIdentity<T> _classIdentity;

  CDOMFactory(ClassIdentity<T> classIdentity) : _classIdentity = classIdentity;

  @override
  CDOMGroupRef<T> getAllReference() => CDOMAllRef<T>(_classIdentity.getReferenceDescription()) as CDOMGroupRef<T>;

  @override
  CDOMGroupRef<T> getTypeReference(List<String> types) =>
      CDOMTypeRef<T>(_classIdentity, types);

  @override
  CDOMSingleRef<T> getReference(String key) =>
      CDOMSimpleSingleRef<T>(_classIdentity, key);

  @override
  T newInstance() => _classIdentity.newInstance();

  @override
  bool isMember(T item) => _classIdentity.isMember(item);

  @override
  Type getReferenceClass() => _classIdentity.getReferenceClass();

  @override
  String getReferenceDescription() => _classIdentity.getReferenceDescription();

  @override
  bool resolve(ReferenceManufacturer<T> rm, String name,
      CDOMSingleRef<T> reference, UnconstructedValidator validator) {
    bool returnGood = true;
    T? activeObj = rm.getObject(name);
    if (activeObj == null) {
      if (!name.startsWith('*') &&
          !_report(validator, name)) {
        rm.fireUnconstructedEvent(reference);
        returnGood = false;
      }
      activeObj = rm.buildObject(name);
    }
    reference.addResolution(activeObj!);
    return returnGood;
  }

  bool _report(UnconstructedValidator? validator, String key) =>
      validator != null &&
      validator.allowUnconstructed(getReferenceIdentity(), key);

  @override
  bool populate(ReferenceManufacturer<T> parent, ReferenceManufacturer<T> rm,
      UnconstructedValidator validator) {
    return true; // nothing to do for non-categorized types
  }

  @override
  ManufacturableFactory<T>? getParent() => null;

  @override
  ClassIdentity<T> getReferenceIdentity() => _classIdentity;

  @override
  String getPersistentFormat() => _classIdentity.getPersistentFormat();

  @override
  String toString() => 'CDOMFactory for ${getReferenceIdentity()}';
}
