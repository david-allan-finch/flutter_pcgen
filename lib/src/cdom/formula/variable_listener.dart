// Copyright (c) Tom Parker, 2016.
//
// Translation of pcgen.cdom.formula.VariableListener

import 'variable_change_event.dart';

/// Listener notified when a variable value changes.
abstract interface class VariableListener<T> {
  void variableChanged(VariableChangeEvent<T> vcEvent);
}
