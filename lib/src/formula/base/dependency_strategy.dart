import 'package:flutter_pcgen/src/formula/base/variable_id.dart';
import 'package:flutter_pcgen/src/formula/base/dependency_manager.dart';

abstract interface class DependencyStrategy {
  void addVariable(VariableID<dynamic> varID, DependencyManager manager);
}
