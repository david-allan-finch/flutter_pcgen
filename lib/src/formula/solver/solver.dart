import 'package:flutter_pcgen/src/base/util/format_manager.dart';
import 'package:flutter_pcgen/src/formula/base/evaluation_manager.dart';
import 'modifier.dart';
import 'process_step.dart';

class Solver<T> {
  final FormatManager<T> _formatManager;
  final T _defaultValue;
  final List<Modifier<T>> _modifiers = [];

  Solver(this._formatManager, this._defaultValue);

  void addModifier(Modifier<T> modifier, Object source) {
    _modifiers.add(modifier);
    _modifiers.sort((a, b) => a.getPriority().compareTo(b.getPriority()));
  }

  bool removeModifier(Modifier<T> modifier, Object source) {
    return _modifiers.remove(modifier);
  }

  T process(EvaluationManager manager) {
    T result = _defaultValue;
    for (final modifier in _modifiers) {
      result = modifier.process(result, manager);
    }
    return result;
  }

  List<ProcessStep<T>> diagnose(EvaluationManager manager) {
    final steps = <ProcessStep<T>>[];
    T result = _defaultValue;
    for (final modifier in _modifiers) {
      final previous = result;
      result = modifier.process(result, manager);
      steps.add(ProcessStep(modifier, previous, result));
    }
    return steps;
  }

  FormatManager<T> getFormatManager() => _formatManager;

  bool isEmpty() => _modifiers.isEmpty;
}
