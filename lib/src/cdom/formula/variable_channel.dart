// Copyright (c) Tom Parker, 2016.
//
// Translation of pcgen.cdom.formula.VariableChannel

import 'package:flutter_pcgen/src/cdom/formula/monitorable_variable_store.dart';
import 'package:flutter_pcgen/src/cdom/formula/variable_change_event.dart';
import 'package:flutter_pcgen/src/cdom/formula/variable_listener.dart';

/// A Channel providing read/write access to a variable backed by a SolverManager.
/// Notifies listeners when the variable changes.
class VariableChannel<T> {
  final dynamic _manager;
  final dynamic _varID;
  final MonitorableVariableStore _varStore;
  final List<void Function(T oldVal, T newVal)> _referenceListeners = [];
  List<bool Function(T, T)>? _vetoList;

  VariableChannel._(this._manager, this._varStore, this._varID);

  static VariableChannel<T> construct<T>(
      dynamic manager, MonitorableVariableStore varStore, dynamic varID) {
    final ch = VariableChannel<T>._(manager, varStore, varID);
    varStore.addVariableListener(varID, _VariableListenerImpl(ch));
    return ch;
  }

  T get() {
    final value = _varStore.get(_varID) as T?;
    if (value == null) {
      return _manager.getDefaultValue(_varID.getFormatManager()) as T;
    }
    return value;
  }

  void set(T object) {
    if (_vetoList != null) {
      final current = get();
      for (final veto in _vetoList!) {
        if (!veto(current, object)) return;
      }
    }
    _varStore.put(_varID, object);
  }

  void addReferenceListener(void Function(T oldVal, T newVal) listener) {
    _referenceListeners.add(listener);
  }

  void removeReferenceListener(void Function(T oldVal, T newVal) listener) {
    _referenceListeners.remove(listener);
  }

  void addVetoListener(bool Function(T oldVal, T newVal) veto) {
    _vetoList ??= [];
    _vetoList!.add(veto);
  }

  void _fireChanged(T oldVal, T newVal) {
    for (final l in _referenceListeners) {
      l(oldVal, newVal);
    }
  }

  void disconnect() {
    _varStore.removeVariableListener(_varID, null);
  }

  dynamic getVariableID() => _varID;
}

class _VariableListenerImpl<T> implements VariableListener<T> {
  final VariableChannel<T> _channel;
  _VariableListenerImpl(this._channel);

  @override
  void variableChanged(VariableChangeEvent<T> vcEvent) {
    _channel._fireChanged(vcEvent.oldValue, vcEvent.newValue);
  }
}
