import '../enumeration/association_key.dart';
import 'association_support.dart';
import 'associated_prereq_object.dart';
import 'concrete_prereq_object.dart';

// Minimal implementation of AssociatedPrereqObject combining prereqs and associations.
class SimpleAssociatedObject extends ConcretePrereqObject implements AssociatedPrereqObject {
  final AssociationSupport _assoc = AssociationSupport();

  @override
  void setAssociation<T>(AssociationKey<T> key, T value) => _assoc.setAssociation(key, value);

  @override
  T? getAssociation<T>(AssociationKey<T> key) => _assoc.getAssociation(key);

  @override
  List<AssociationKey<dynamic>> getAssociationKeys() => _assoc.getAssociationKeys();

  @override
  bool hasAssociations() => _assoc.hasAssociations();

  @override
  bool operator ==(Object other) {
    if (other is SimpleAssociatedObject) {
      return _assoc == other._assoc && equalsPrereqObject(other);
    }
    return false;
  }

  @override
  int get hashCode => _assoc.hashCode;
}
