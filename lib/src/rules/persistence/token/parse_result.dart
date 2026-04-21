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
// Translation of pcgen.rules.persistence.token.ParseResult
import 'dart:developer' as developer;

// QueuedMessage holds a log level + message text (mirrors Java's QueuedMessage).
class QueuedMessage {
  final String level; // e.g. 'LST_ERROR', 'LST_WARNING', 'LST_INFO'
  final String message;

  QueuedMessage(this.level, this.message);
}

/// Interface providing feedback on parsing operations.
abstract interface class ParseResult {
  /// Shared singleton for a successful parse with no messages.
  static final ParseResult success = _Pass();

  /// Shared singleton for an internal error.
  static final ParseResult internalError = ParseResultFail('Internal error.');

  /// Returns true if the parse succeeded.
  bool passed();

  /// Log messages associated with this result at the given source URI.
  void printMessages(String uri);

  /// Add messages to the deferred parse-message log.
  void addMessagesToLog(String uri);

  /// Generate text for a queued message + source URI.
  static String generateText(QueuedMessage message, String uri) {
    return '${message.message} (Source: $uri )';
  }
}

// ─── Pass (SUCCESS) ──────────────────────────────────────────────────────────

class _Pass implements ParseResult {
  const _Pass();

  @override
  bool passed() => true;

  @override
  void addMessagesToLog(String uri) {
    // No messages — we passed.
  }

  @override
  void printMessages(String uri) {
    // No messages — we passed.
  }
}

// ─── Fail ────────────────────────────────────────────────────────────────────

class ParseResultFail implements ParseResult {
  final QueuedMessage error;

  ParseResultFail(String errorMessage)
      : error = QueuedMessage('LST_ERROR', errorMessage);

  @override
  bool passed() => false;

  QueuedMessage getError() => error;

  @override
  void addMessagesToLog(String uri) {
    developer.log(ParseResult.generateText(error, uri), name: error.level);
  }

  @override
  void printMessages(String uri) {
    developer.log(ParseResult.generateText(error, uri), name: error.level);
  }

  @override
  String toString() => error.message;
}
