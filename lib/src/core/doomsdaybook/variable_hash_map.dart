// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.doomsdaybook.VariableHashMap

import 'package:flutter_pcgen/src/core/doomsdaybook/data_element.dart';
import 'package:flutter_pcgen/src/core/doomsdaybook/data_value.dart';
import 'package:flutter_pcgen/src/core/doomsdaybook/operation.dart';
import 'package:flutter_pcgen/src/core/doomsdaybook/variable_exception.dart';

/// A Map<String, String> that also stores DataElements and variable operations
/// for the doomsdaybook random name/text generation system.
///
/// Variables are resolved by performing arithmetic operations on stored values,
/// and DataElements can be looked up by id for text substitution.
class VariableHashMap extends Map<String, String> {
  final Map<String, DataElement> _dataElements = {};
  final List<Operation> _initialize = [];

  final Map<String, String> _inner = {};

  // Implement Map via delegation to _inner
  @override
  String? operator [](Object? key) => _inner[key];

  @override
  void operator []=(String key, String value) => _inner[key] = value;

  @override
  void clear() => _inner.clear();

  @override
  Iterable<String> get keys => _inner.keys;

  @override
  String? remove(Object? key) => _inner.remove(key);

  @override
  bool containsKey(Object? key) => _inner.containsKey(key);

  @override
  bool containsValue(Object? value) => _inner.containsValue(value);

  @override
  void forEach(void Function(String key, String value) action) =>
      _inner.forEach(action);

  @override
  bool get isEmpty => _inner.isEmpty;

  @override
  bool get isNotEmpty => _inner.isNotEmpty;

  @override
  int get length => _inner.length;

  @override
  Iterable<String> get values => _inner.values;

  // --- DataElement registration ---

  void addDataElement(DataElement element) {
    _dataElements[element.getId()] = element;
  }

  DataElement? getDataElement(String id) => _dataElements[id];

  // --- Initialize operations ---

  void addInitialize(Operation op) => _initialize.add(op);

  /// Applies all registered initialize operations to reset variables.
  void initialize() {
    for (final op in _initialize) {
      doOperation(op);
    }
  }

  // --- Operations ---

  /// Performs the given operation, updating the variable map.
  void doOperation(Operation op) {
    switch (op.type) {
      case OperationType.set:
        _inner[op.key] = op.value;
      case OperationType.add:
        _inner[op.key] = _applyArithmetic(op.key, op.value, (a, b) => a + b);
      case OperationType.subtract:
        _inner[op.key] = _applyArithmetic(op.key, op.value, (a, b) => a - b);
      case OperationType.multiply:
        _inner[op.key] = _applyArithmetic(op.key, op.value, (a, b) => a * b);
      case OperationType.divide:
        _inner[op.key] = _applyArithmetic(op.key, op.value, (a, b) => a ~/ b);
    }
  }

  String _applyArithmetic(
      String key, String value, int Function(int a, int b) fn) {
    final current = int.tryParse(_inner[key] ?? '0') ?? 0;
    final operand = int.tryParse(value) ?? 0;
    return fn(current, operand).toString();
  }

  /// Parses a template string, substituting variable references and DataElement lookups.
  ///
  /// Variable references are of the form `%VARNAME%` or `%ID%` where ID refers
  /// to a registered DataElement. Returns the substituted DataValue.
  DataValue parse(String template) {
    final buffer = StringBuffer();
    var i = 0;
    while (i < template.length) {
      if (template[i] == '%') {
        final end = template.indexOf('%', i + 1);
        if (end == -1) {
          buffer.write(template[i]);
          i++;
          continue;
        }
        final ref = template.substring(i + 1, end);
        if (_dataElements.containsKey(ref)) {
          final elem = _dataElements[ref]!;
          final dv = elem.getData() as DataValue;
          buffer.write(dv.getValue());
        } else if (_inner.containsKey(ref)) {
          buffer.write(_inner[ref]);
        } else {
          buffer.write('%$ref%');
        }
        i = end + 1;
      } else {
        buffer.write(template[i]);
        i++;
      }
    }
    return DataValue(buffer.toString());
  }
}
