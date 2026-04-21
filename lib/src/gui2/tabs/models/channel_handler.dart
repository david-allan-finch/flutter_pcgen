// Translation of pcgen.gui2.tabs.models.ChannelHandler

import 'package:flutter/foundation.dart';

/// Bridges a character facade "channel" (a VariableChannel) to a Flutter
/// ChangeNotifier so UI can observe and write back to the model.
class ChannelHandler<T> extends ChangeNotifier {
  T? _value;
  final T? Function(dynamic character) _reader;
  final void Function(dynamic character, T value)? _writer;

  ChannelHandler({
    required T? Function(dynamic character) reader,
    void Function(dynamic character, T value)? writer,
  })  : _reader = reader,
        _writer = writer;

  T? get value => _value;

  set value(T? v) {
    if (_value == v) return;
    _value = v;
    notifyListeners();
  }

  void install(dynamic character) {
    _value = _reader(character);
    notifyListeners();
  }

  void commit(dynamic character) {
    if (_value != null) _writer?.call(character, _value as T);
  }
}
