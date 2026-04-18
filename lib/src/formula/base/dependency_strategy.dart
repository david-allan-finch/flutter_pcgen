import 'variable_id.dart';
import 'dependency_manager.dart';

abstract interface class DependencyStrategy {
  void addVariable(VariableID<dynamic> varID, DependencyManager manager);
}
