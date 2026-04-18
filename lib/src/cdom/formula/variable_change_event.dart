// Copyright (c) Tom Parker, 2016.
//
// Translation of pcgen.cdom.formula.VariableChangeEvent

/// Event indicating that a variable value has changed.
class VariableChangeEvent<T> {
  final Object source;
  final dynamic varID;
  final T oldValue;
  final T newValue;

  VariableChangeEvent(this.source, this.varID, this.oldValue, this.newValue);

  dynamic getVarID() => varID;
  T getOldValue() => oldValue;
  T getNewValue() => newValue;
}
