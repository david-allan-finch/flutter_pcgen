//
// Copyright 2019 (C) Eitan Adler <lists@eitanadler.com>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.     See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
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
