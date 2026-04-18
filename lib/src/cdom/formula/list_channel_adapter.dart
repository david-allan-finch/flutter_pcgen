// Copyright (c) Tom Parker, 2016.
//
// Translation of pcgen.cdom.formula.ListChannelAdapter

import 'variable_channel.dart';

/// Adapts a VariableChannel of array type to a mutable list facade.
class ListChannelAdapter<T> {
  final VariableChannel<List<T>> _variableChannel;
  final List<void Function()> _listeners = [];

  ListChannelAdapter(VariableChannel<List<T>> underlyingChannel)
      : _variableChannel = underlyingChannel {
    underlyingChannel.addReferenceListener((oldVal, newVal) => _fireChanged());
  }

  T getElementAt(int index) => _variableChannel.get()[index];

  int get size => _variableChannel.get().length;

  void addElement(T element) {
    final current = List<T>.from(_variableChannel.get())..add(element);
    _variableChannel.set(current);
  }

  void addElementAt(int index, T element) {
    final current = List<T>.from(_variableChannel.get())..insert(index, element);
    _variableChannel.set(current);
  }

  bool removeElement(T element) {
    final current = List<T>.from(_variableChannel.get());
    final removed = current.remove(element);
    if (removed) _variableChannel.set(current);
    return removed;
  }

  void removeElementAt(int index) {
    final current = List<T>.from(_variableChannel.get())..removeAt(index);
    _variableChannel.set(current);
  }

  List<T> toList() => List.unmodifiable(_variableChannel.get());

  void addListListener(void Function() listener) => _listeners.add(listener);
  void removeListListener(void Function() listener) => _listeners.remove(listener);

  void _fireChanged() {
    for (final l in _listeners) l();
  }
}
