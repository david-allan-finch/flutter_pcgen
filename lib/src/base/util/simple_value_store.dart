import 'value_store.dart';

class SimpleValueStore implements ValueStore {
  final Map<String, Object?> _store = {};

  void addValueFor(String identifier, Object? value) {
    _store[identifier] = value;
  }

  @override
  Object? getValueFor(String identifier) => _store[identifier];
}
