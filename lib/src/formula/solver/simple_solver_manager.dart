import 'package:flutter_pcgen/src/base/util/format_manager.dart';
import 'package:flutter_pcgen/src/formula/base/evaluation_manager.dart';
import 'package:flutter_pcgen/src/formula/base/variable_id.dart';
import 'package:flutter_pcgen/src/formula/solver/modifier.dart';
import 'package:flutter_pcgen/src/formula/solver/process_step.dart';
import 'package:flutter_pcgen/src/formula/solver/solver.dart';
import 'package:flutter_pcgen/src/formula/solver/solver_manager.dart';

class SimpleSolverManager implements SolverManager {
  final Map<VariableID<dynamic>, Solver<dynamic>> _solvers = {};
  final Map<VariableID<dynamic>, dynamic> _defaults;

  SimpleSolverManager(this._defaults);

  Solver<T> _getSolver<T>(VariableID<T> varID) {
    return _solvers.putIfAbsent(varID, () {
      final defaultVal = _defaults[varID] as T? ?? varID.getFormatManager().initializeFrom(_EmptyValueStore());
      return Solver<T>(varID.getFormatManager(), defaultVal as T);
    }) as Solver<T>;
  }

  @override
  void addModifier<T>(VariableID<T> varID, Modifier<T> modifier, Object source) {
    _getSolver(varID).addModifier(modifier, source);
  }

  @override
  bool removeModifier<T>(VariableID<T> varID, Modifier<T> modifier, Object source) {
    return _getSolver(varID).removeModifier(modifier, source);
  }

  @override
  T solve<T>(VariableID<T> varID, EvaluationManager manager) {
    return _getSolver(varID).process(manager);
  }

  @override
  List<ProcessStep<dynamic>> diagnose(VariableID<dynamic> varID, EvaluationManager manager) {
    return _getSolver(varID).diagnose(manager);
  }
}

class _EmptyValueStore {
  Object? getValueFor(String identifier) => null;
}
