import 'variable_id.dart';
import 'variable_store.dart';

abstract interface class WriteableVariableStore implements VariableStore {
  void put<T>(VariableID<T> varID, T value);
}
