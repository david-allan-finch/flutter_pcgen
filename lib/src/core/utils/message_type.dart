// Copyright (c) Chris Ward, 2004.
//
// Translation of pcgen.core.utils.MessageType

/// Represents the type/severity of a dialog message.
class MessageType {
  static final MessageType information = MessageType._('Information');
  static final MessageType warning = MessageType._('Warning');
  static final MessageType error = MessageType._('Error');
  static final MessageType question = MessageType._('Question');

  final String _name;
  MessageType._(this._name);

  @override
  String toString() => _name;
}
