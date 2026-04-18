import '../base/variable_id.dart';
import '../base/writeable_variable_store.dart';

class SimpleVariableStore implements WriteableVariableStore {
  final Map<VariableID<dynamic>, dynamic> _store = {};

  @override
  T? get<T>(VariableID<T> varID) => _store[varID] as T?;

  @override
  bool containsVariable(VariableID<dynamic> varID) => _store.containsKey(varID);

  @override
  Iterable<VariableID<dynamic>> getVariables() => _store.keys;

  @override
  void put<T>(VariableID<T> varID, T value) => _store[varID] = value;
}
