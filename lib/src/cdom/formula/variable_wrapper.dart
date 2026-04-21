// Copyright (c) Tom Parker, 2016.
//
// Translation of pcgen.cdom.formula.VariableWrapper

import 'package:flutter_pcgen/src/cdom/formula/monitorable_variable_store.dart';
import 'package:flutter_pcgen/src/cdom/formula/variable_change_event.dart';
import 'package:flutter_pcgen/src/cdom/formula/variable_listener.dart';

/// A read-only wrapper around a variable backed by a SolverManager.
/// Notifies listeners when the variable changes.
class VariableWrapper<T> implements VariableListener<T> {
  final dynamic _manager;
  final dynamic _varID;
  final MonitorableVariableStore _varStore;
  final List<void Function(T oldVal, T newVal)> _referenceListeners = [];

  VariableWrapper._(this._manager, this._varStore, this._varID);

  static VariableWrapper<T> construct<T>(
      dynamic manager, MonitorableVariableStore varStore, dynamic varID) {
    final w = VariableWrapper<T>._(manager, varStore, varID);
    varStore.addVariableListener(varID, w);
    return w;
  }

  T get() {
    final value = _varStore.get(_varID) as T?;
    if (value == null) {
      return _manager.getDefaultValue(_varID.getFormatManager()) as T;
    }
    return value;
  }

  @override
  void variableChanged(VariableChangeEvent<T> event) {
    for (final l in _referenceListeners) {
      l(event.oldValue, event.newValue);
    }
  }

  void addReferenceListener(void Function(T oldVal, T newVal) listener) {
    _referenceListeners.add(listener);
  }

  void removeReferenceListener(void Function(T oldVal, T newVal) listener) {
    _referenceListeners.remove(listener);
  }

  void disconnect() {
    _varStore.removeVariableListener(_varID, this);
  }

  dynamic getVariableID() => _varID;
}
