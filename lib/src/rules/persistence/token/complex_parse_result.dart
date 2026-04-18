import 'dart:developer' as developer;

import 'parse_result.dart';

/// ParseResult implementation that supports multiple queued messages.
class ComplexParseResult implements ParseResult {
  final List<QueuedMessage> _queuedMessages = [];

  ComplexParseResult();

  ComplexParseResult.withError(String error) {
    addErrorMessage(error);
  }

  ComplexParseResult.copyOf(ComplexParseResult toCopy) {
    addMessages(toCopy);
  }

  void addErrorMessage(String msg) {
    _addParseMessage('LST_ERROR', msg);
  }

  void addWarningMessage(String msg) {
    _addParseMessage('LST_WARNING', msg);
  }

  void addInfoMessage(String msg) {
    _addParseMessage('LST_INFO', msg);
  }

  void _addParseMessage(String level, String msg) {
    _queuedMessages.add(QueuedMessage(level, msg));
  }

  void addMessages(ComplexParseResult pr) {
    _queuedMessages.addAll(pr._queuedMessages);
  }

  @override
  void printMessages(String uri) {
    for (final msg in _queuedMessages) {
      developer.log(ParseResult.generateText(msg, uri), name: msg.level);
    }
  }

  @override
  void addMessagesToLog(String uri) {
    for (final msg in _queuedMessages) {
      developer.log(ParseResult.generateText(msg, uri), name: msg.level);
    }
  }

  @override
  bool passed() {
    for (final msg in _queuedMessages) {
      if (msg.level == 'LST_ERROR') {
        return false;
      }
    }
    return true;
  }

  /// Copy messages from another ParseResult.
  void copyMessages(ParseResult pr) {
    if (pr is ComplexParseResult) {
      _queuedMessages.addAll(pr._queuedMessages);
    } else if (pr is ParseResultFail) {
      _queuedMessages.add(pr.getError());
    }
  }
}
