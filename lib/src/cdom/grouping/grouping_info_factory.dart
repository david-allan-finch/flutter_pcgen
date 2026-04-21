//
// Copyright 2018 (C) Tom Parker <thpr@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or modify it under the terms
// of the GNU Lesser General Public License as published by the Free Software Foundation;
// either version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along with
// this library; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
// Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.cdom.grouping.GroupingInfoFactory
import 'package:flutter_pcgen/src/cdom/grouping/grouping_info.dart';
import 'package:flutter_pcgen/src/cdom/grouping/grouping_tokenizer.dart';

// Constructs GroupingInfo objects given a PCGenScope and instruction string.
// Warning: NOT thread safe.
class GroupingInfoFactory {
  // Characters expected in future parsing.
  final List<String> _expected = [];

  // Current depth of grouping.
  int _depth = 0;

  // Scope name parts for the instructions being analyzed.
  List<String> _scopeName = [];

  // Tokenizer for the instructions.
  late GroupingTokenizer _fullTokenizer;

  // Active GroupingInfo for the instructions being analyzed.
  late GroupingInfo _activeInfo;

  // Processes the given scope and instructions to generate a GroupingInfo.
  GroupingInfo process(dynamic scope, String instructions) {
    // stub: LegalScope.getFullName(scope)
    final String fullScopeName = _getFullName(scope); // stub
    _scopeName = fullScopeName.split('.');
    _depth = 0;
    _expected.clear();
    _fullTokenizer = GroupingTokenizer(instructions);
    final GroupingInfo topInfo = GroupingInfo();
    topInfo.scope = scope;
    _activeInfo = topInfo;
    _consumeGrouping();
    if (_fullTokenizer.hasNext()) {
      throw GroupingStateException(
        'After ${_fullTokenizer.getConsumed()} expected end of string, '
        'but had additional content: ${_fullTokenizer.next()}',
      );
    }
    return topInfo;
  }

  // stub: returns the full name of a scope
  String _getFullName(dynamic scope) {
    // stub
    return (scope as dynamic).getFullName?.call() ?? scope.toString();
  }

  // Consumes a grouping (with potential child).
  void _consumeGrouping() {
    if (!_fullTokenizer.hasNext()) {
      throw GroupingStateException(
        'Expected a Grouping, but string ended: ${_fullTokenizer.getConsumed()}',
      );
    }
    final String item = _fullTokenizer.next();
    if (_isSeparator(item)) {
      throw GroupingStateException(
        'Expected text, but $item was found: ${_fullTokenizer.getConsumed()}',
      );
    }
    if (_fullTokenizer.hasNext()) {
      final String next = _fullTokenizer.peek();
      if ('=' == next) {
        _activeInfo.characteristic = item;
        // Skip the Equals
        _fullTokenizer.next();
        _consumeTarget();
        _allowChild();
      } else if ('[' == next) {
        _activeInfo.value = item;
        _allowChild();
      } else if (']' == next) {
        _consumeCloseBracket();
      } else {
        if (_expected.isEmpty) {
          throw GroupingStateException(
            "Expected '=' or '[', but $item was found: ${_fullTokenizer.getConsumed()}",
          );
        } else {
          throw GroupingStateException(
            "Expected '=' or '[' or ']', but $item was found: ${_fullTokenizer.getConsumed()}",
          );
        }
      }
    } else {
      // Could be simply "ALL" (so no additional tokens).
      _activeInfo.value = item;
    }
  }

  // Consumes a target (item after '=').
  void _consumeTarget() {
    if (!_fullTokenizer.hasNext()) {
      throw GroupingStateException(
        "Expected target after '=', but string ended: ${_fullTokenizer.getConsumed()}",
      );
    }
    final String expectedTarget = _fullTokenizer.next();
    if (_isSeparator(expectedTarget)) {
      throw GroupingStateException(
        'Expected target type, but $expectedTarget was found: ${_fullTokenizer.getConsumed()}',
      );
    }
    _activeInfo.value = expectedTarget;
  }

  // Allows and consumes a child if present (not required).
  void _allowChild() {
    if (!_fullTokenizer.hasNext()) {
      // This is allow, not require.
      return;
    }
    final String expectedOpenBracket = _fullTokenizer.next();
    if ('[' != expectedOpenBracket) {
      throw GroupingMismatchException(
        "Expected '[' to start a child but found: $expectedOpenBracket"
        ' in ${_fullTokenizer.getConsumed()}',
      );
    }
    _expected.add(']');
    _consumeChild();
  }

  // Consumes the child.
  void _consumeChild() {
    if (_scopeName.length <= _depth) {
      throw GroupingStateException(
        'Encountered a Child, but didn\'t have sufficient format: $_scopeName',
      );
    }
    final String expectedType = _scopeName[_depth++];
    final GroupingInfo newInfo = GroupingInfo();
    _activeInfo.child = newInfo;
    newInfo.objectType = expectedType;
    _activeInfo = newInfo;
    _consumeGrouping();
  }

  // Consumes the close bracket at the end of a grouping.
  void _consumeCloseBracket() {
    if (!_fullTokenizer.hasNext()) {
      throw GroupingStateException(
        "Expected a ']', but string ended: ${_fullTokenizer.getConsumed()}",
      );
    }
    final String expectedCloseBracket = _fullTokenizer.next();
    if (']' != expectedCloseBracket) {
      throw GroupingMismatchException(
        "Expected ']' but found: $expectedCloseBracket in ${_fullTokenizer.getConsumed()}",
      );
    }
    if (_expected.isEmpty) {
      throw GroupingMismatchException(
        'Did not have an open bracket before close: ${_fullTokenizer.getConsumed()}',
      );
    }
    final String nextExpected = _expected.removeLast();
    if (']' != nextExpected) {
      throw GroupingMismatchException(
        'Expected $nextExpected but did not have matching brackets: ${_fullTokenizer.getConsumed()}',
      );
    }
    if (_expected.isNotEmpty) {
      _consumeCloseBracket();
    }
  }

  // Indicates key separator characters in a grouping.
  bool _isSeparator(String item) {
    return '=' == item || '[' == item || ']' == item;
  }
}

// An Exception indicating a problem in analyzing the instructions.
class GroupingStateException implements Exception {
  final String message;
  GroupingStateException(this.message);

  @override
  String toString() => 'GroupingStateException: $message';
}

// Indicates a mismatch in brackets when parsing the instructions.
class GroupingMismatchException extends GroupingStateException {
  GroupingMismatchException(super.message);

  @override
  String toString() => 'GroupingMismatchException: $message';
}
