import 'package:flutter_pcgen/src/formula/base/variable_id.dart';

abstract interface class DynamicManager {
  void addDynamicVariable(VariableID<dynamic> varID);
}
