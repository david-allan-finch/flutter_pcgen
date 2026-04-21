import 'package:flutter_pcgen/src/formula/base/variable_id.dart';
import 'package:flutter_pcgen/src/formula/base/variable_store.dart';

abstract interface class WriteableVariableStore implements VariableStore {
  void put<T>(VariableID<T> varID, T value);
}
