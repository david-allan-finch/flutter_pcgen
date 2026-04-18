import '../enumeration/association_key.dart';
import 'associated_object.dart';

// Delegate helper that implements AssociatedObject using a HashMap.
class AssociationSupport implements AssociatedObject {
  Map<AssociationKey<dynamic>, Object?>? _associationMap;

  @override
  void setAssociation<T>(AssociationKey<T> key, T value) {
    _associationMap ??= {};
    _associationMap![key] = value;
  }

  @override
  T? getAssociation<T>(AssociationKey<T> key) {
    if (_associationMap == null) return null;
    final v = _associationMap![key];
    return v == null ? null : key.cast(v);
  }

  @override
  List<AssociationKey<dynamic>> getAssociationKeys() {
    if (_associationMap == null) return [];
    return List.of(_associationMap!.keys);
  }

  @override
  bool hasAssociations() => _associationMap != null && _associationMap!.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AssociationSupport) return false;
    final myEmpty = _associationMap == null || _associationMap!.isEmpty;
    final otherEmpty = other._associationMap == null || other._associationMap!.isEmpty;
    if (myEmpty && otherEmpty) return true;
    if (myEmpty != otherEmpty) return false;
    return _associationMap == other._associationMap;
  }

  @override
  int get hashCode => _associationMap?.length ?? 0;
}
