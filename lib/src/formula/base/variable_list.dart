import 'package:flutter_pcgen/src/formula/base/variable_id.dart';

abstract interface class VariableList {
  void add(VariableID<dynamic> varID);
  List<VariableID<dynamic>> getVariables();
}
