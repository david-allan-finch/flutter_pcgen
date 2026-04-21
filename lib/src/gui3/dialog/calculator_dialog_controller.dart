// Translation of pcgen.gui3.dialog.CalculatorDialogController

import 'package:flutter/foundation.dart';
import 'dart:math' as math;

/// Controller for the dice/formula calculator dialog.
class CalculatorDialogController extends ChangeNotifier {
  String _expression = '';
  String _result = '';
  String _error = '';
  final List<String> _history = [];

  String get expression => _expression;
  String get result => _result;
  String get error => _error;
  List<String> get history => List.unmodifiable(_history);

  void setExpression(String expr) {
    _expression = expr;
    _error = '';
    notifyListeners();
  }

  void calculate() {
    if (_expression.trim().isEmpty) return;
    try {
      final value = _evaluate(_expression);
      _result = value.toString();
      _error = '';
      _history.insert(0, '$_expression = $_result');
      if (_history.length > 20) _history.removeLast();
    } catch (e) {
      _result = '';
      _error = e.toString();
    }
    notifyListeners();
  }

  void clear() {
    _expression = '';
    _result = '';
    _error = '';
    notifyListeners();
  }

  // Very simple expression evaluator (numbers and basic operators only).
  double _evaluate(String expr) {
    final cleaned = expr.replaceAll(' ', '');
    // Support basic dice notation: XdY
    final diceMatch = RegExp(r'^(\d+)d(\d+)$').firstMatch(cleaned);
    if (diceMatch != null) {
      final count = int.parse(diceMatch.group(1)!);
      final sides = int.parse(diceMatch.group(2)!);
      double total = 0;
      for (var i = 0; i < count; i++) {
        total += math.Random().nextInt(sides) + 1;
      }
      return total;
    }
    // Fallback: try to parse as plain number
    return double.parse(cleaned);
  }
}
