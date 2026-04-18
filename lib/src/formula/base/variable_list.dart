import 'variable_id.dart';

abstract interface class VariableList {
  void add(VariableID<dynamic> varID);
  List<VariableID<dynamic>> getVariables();
}
