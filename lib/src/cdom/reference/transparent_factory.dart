import '../base/class_identity.dart';
import '../base/loadable.dart';
import 'cdom_group_ref.dart';
import 'cdom_single_ref.dart';
import 'cdom_transparent_all_ref.dart';
import 'cdom_transparent_single_ref.dart';
import 'cdom_transparent_type_ref.dart';
import 'manufacturable_factory.dart';
import 'reference_manufacturer.dart';
import 'unconstructed_validator.dart';

// A ManufacturableFactory that produces Transparent CDOMReferences (i.e.,
// references that will be re-resolved per campaign load, not directly resolved).
class TransparentFactory<T extends Loadable> implements ManufacturableFactory<T> {
  final Type _refClass;
  final String _formatRepresentation;

  TransparentFactory(String formatRepresentation, Type objClass)
      : _refClass = objClass,
        _formatRepresentation = formatRepresentation;

  @override
  CDOMGroupRef<T> getAllReference() =>
      CDOMTransparentAllRef<T>(_formatRepresentation, _refClass);

  @override
  CDOMGroupRef<T> getTypeReference(List<String> types) =>
      CDOMTransparentTypeRef<T>(_formatRepresentation, _refClass, types);

  @override
  CDOMSingleRef<T> getReference(String key) =>
      CDOMTransparentSingleRef<T>(_formatRepresentation, _refClass, key);

  @override
  T newInstance() {
    throw UnsupportedError('newInstance should not be called on TransparentFactory');
  }

  @override
  bool isMember(T item) => _refClass == item.runtimeType;

  @override
  Type getReferenceClass() => _refClass;

  @override
  String getReferenceDescription() => _refClass.toString();

  @override
  bool resolve(ReferenceManufacturer<T> rm, String name,
      CDOMSingleRef<T> reference, UnconstructedValidator validator) {
    throw UnsupportedError('Resolution should not occur on Transparent object');
  }

  @override
  bool populate(ReferenceManufacturer<T> parent, ReferenceManufacturer<T> rm,
      UnconstructedValidator validator) {
    return true;
  }

  @override
  ManufacturableFactory<T>? getParent() {
    throw UnsupportedError('Resolution of Parent should not occur on Transparent object');
  }

  @override
  ClassIdentity<T> getReferenceIdentity() {
    throw UnsupportedError('Resolution to Identity should not occur on Transparent object');
  }

  @override
  String getPersistentFormat() => _formatRepresentation;
}
