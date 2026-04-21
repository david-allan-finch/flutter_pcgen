import 'package:flutter_pcgen/src/formula/base/variable_id.dart';

abstract interface class VariableStore {
  T? get<T>(VariableID<T> varID);
  bool containsVariable(VariableID<dynamic> varID);
  Iterable<VariableID<dynamic>> getVariables();
}
