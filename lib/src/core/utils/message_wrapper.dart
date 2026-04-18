// Copyright (c) Frugal, 2004.
//
// Translation of pcgen.core.utils.MessageWrapper

import 'message_type.dart';

/// Wraps a dialog message with its title, type, and optional parent widget.
class MessageWrapper {
  final Object? message;
  final String title;
  final MessageType messageType;
  final Object? parent;

  const MessageWrapper(this.message, this.title, this.messageType,
      [this.parent]);

  Object? getMessage() => message;
  MessageType getMessageType() => messageType;
  String getTitle() => title;
  Object? getParent() => parent;
}
