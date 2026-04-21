//
// Copyright (c) 2009 Mark Jeffries <motorviper@users.sourceforge.net>
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
//
// Translation of pcgen.rules.persistence.token.ComplexParseResult
import 'dart:developer' as developer;

import 'package:flutter_pcgen/src/rules/persistence/token/parse_result.dart';

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
