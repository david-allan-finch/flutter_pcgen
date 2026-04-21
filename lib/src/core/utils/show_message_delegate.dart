// Copyright (c) Bryan McRoberts, 2001.
//
// Translation of pcgen.core.utils.ShowMessageDelegate

import 'package:flutter_pcgen/src/core/utils/message_type.dart';
import 'package:flutter_pcgen/src/core/utils/message_wrapper.dart';

typedef MessageObserver = void Function(MessageWrapper msg);

/// Singleton facade for displaying dialog messages from core code.
/// GUI layers register observers; core code calls [showMessageDialog].
class ShowMessageDelegate {
  static final ShowMessageDelegate _instance = ShowMessageDelegate._();
  final List<MessageObserver> _observers = [];

  ShowMessageDelegate._();

  static ShowMessageDelegate getInstance() => _instance;

  void addObserver(MessageObserver observer) => _observers.add(observer);
  void removeObserver(MessageObserver observer) => _observers.remove(observer);

  static void showMessageDialog(Object message, String title,
      MessageType messageType) {
    showMessageWrapper(MessageWrapper(message, title, messageType));
  }

  static void showMessageWrapper(MessageWrapper wrapper) {
    if (_instance._observers.isEmpty) {
      final msg = wrapper.getMessage();
      if (msg != null && msg.toString().isNotEmpty) {
        print('${wrapper.getTitle()}: $msg');
      }
      return;
    }
    for (final obs in _instance._observers) {
      obs(wrapper);
    }
  }
}
