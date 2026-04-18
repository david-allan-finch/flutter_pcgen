// Copyright (c) Thomas Parker, 2016.
//
// Translation of pcgen.cdom.formula.MonitorableVariableStore

import '../../formula/base/variable_id.dart';

// TODO: Translate VariableListener and full listener infrastructure.

/// A variable store that allows [VariableListener] objects to listen for
/// changes to variables. Backed by a simple map keyed by [VariableID].
class MonitorableVariableStore {
  final Map<VariableID<dynamic>, dynamic> _values = {};

  T? get<T>(VariableID<T> varID) => _values[varID] as T?;

  void put<T>(VariableID<T> varID, T value) {
    _values[varID] = value;
  }

  /// Copies all values from [other] into this store.
  void importFrom(MonitorableVariableStore other) {
    _values.addAll(other._values);
  }

  // TODO: implement listener infrastructure (DoubleKeyMapToList equivalent).
  void addVariableListener<T>(VariableID<T> varID, Object listener) {}
  void removeVariableListener<T>(VariableID<T> varID, Object listener) {}
}
