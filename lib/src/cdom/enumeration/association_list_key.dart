import '../../base/util/fixed_string_list.dart';

// Type-safe list key for use with AssociatedObject.
final class AssociationListKey<T> {
  static final Map<String, AssociationListKey<dynamic>> _map = {};

  static final AssociationListKey<FixedStringList> choices = AssociationListKey._('CHOICES');
  static final AssociationListKey<Object> add = AssociationListKey._('ADD');

  final String _name;

  AssociationListKey._(this._name) {
    _map[_name.toLowerCase()] = this;
  }

  static AssociationListKey<OT> getKeyFor<OT>(String keyName) {
    final key = _map[keyName.toLowerCase()];
    if (key != null) return key as AssociationListKey<OT>;
    final newKey = AssociationListKey<OT>._(keyName.toUpperCase());
    return newKey;
  }

  T cast(Object obj) => obj as T;

  @override
  String toString() {
    return _map.entries
        .where((e) => e.value == this)
        .map((e) => e.key.toUpperCase())
        .firstOrNull ?? '';
  }
}
