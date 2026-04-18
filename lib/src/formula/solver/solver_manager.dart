import '../../base/util/format_manager.dart';
import '../base/evaluation_manager.dart';
import '../base/variable_id.dart';
import 'modifier.dart';
import 'process_step.dart';

abstract interface class SolverManager {
  void addModifier<T>(VariableID<T> varID, Modifier<T> modifier, Object source);
  bool removeModifier<T>(VariableID<T> varID, Modifier<T> modifier, Object source);
  T solve<T>(VariableID<T> varID, EvaluationManager manager);
  List<ProcessStep<dynamic>> diagnose(VariableID<dynamic> varID, EvaluationManager manager);
}
