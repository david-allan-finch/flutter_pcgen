// Copyright (c) Tom Parker, 2010.
//
// Translation of pcgen.core.utils.LastGroupSeparator

/// Parses a string containing parenthesised groups, returns the content of
/// the last top-level group and accumulates everything outside into a root.
///
/// Example: "foo(bar)(baz)" → process() returns "baz", getRoot() returns "foo(bar)".
class LastGroupSeparator {
  final String startingString;
  StringBuffer? _root;

  LastGroupSeparator(this.startingString);

  /// Processes the string and returns the content of the last top-level group,
  /// or null if there are no groups. Throws [GroupingMismatchException] on
  /// unbalanced parentheses.
  String? process() {
    _root = StringBuffer();
    StringBuffer temp = StringBuffer();
    bool isValid = false;
    final expected = <String>[];
    int i = 0;

    while (i < startingString.length) {
      final ch = startingString[i];

      if (expected.isEmpty) {
        if (isValid) {
          _root!.write('(');
          _root!.write(temp);
          _root!.write(')');
        }
        temp = StringBuffer();
        isValid = false;
      }

      if (ch == '(') {
        if (expected.isNotEmpty) temp.write(ch);
        isValid = true;
        expected.add(')');
      } else if (ch == ')') {
        if (expected.isEmpty) {
          throw GroupingMismatchException(
              '$startingString did not have an open parenthesis before close: $temp');
        } else if (expected.last != ')') {
          throw GroupingMismatchException(
              '$startingString did not have matching parenthesis inside of brackets: $temp');
        } else {
          expected.removeLast();
          if (expected.isNotEmpty) temp.write(ch);
        }
      } else if (expected.isEmpty) {
        _root!.write(ch);
      } else {
        temp.write(ch);
      }

      i++;
    }

    if (expected.isEmpty) {
      if (!isValid) return null;
      return temp.toString();
    }
    throw GroupingMismatchException(
        '$startingString reached end of String while attempting to match: ${expected.last}');
  }

  /// Returns the portion of the string outside of the last parenthesised group.
  /// Must be called after [process].
  String getRoot() {
    if (_root == null) throw StateError('process() must be called first');
    return _root!.toString();
  }
}

/// Thrown when parentheses in the input string are unbalanced.
class GroupingMismatchException implements Exception {
  final String message;
  const GroupingMismatchException(this.message);
  @override
  String toString() => 'GroupingMismatchException: $message';
}
