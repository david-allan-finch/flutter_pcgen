import '../enumeration/association_key.dart';

// Interface for objects that carry a set of type-safe Associations.
abstract interface class AssociatedObject {
  void setAssociation<T>(AssociationKey<T> key, T value);
  T? getAssociation<T>(AssociationKey<T> key);
  List<AssociationKey<dynamic>> getAssociationKeys();
  bool hasAssociations();
}
