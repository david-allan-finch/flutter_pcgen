// Copyright (c) Chris Ward, 2003.
//
// Translation of pcgen.core.prereq.PrerequisiteException

/// Exception thrown when a prerequisite cannot be evaluated.
class PrerequisiteException implements Exception {
  final String? message;
  final Object? cause;

  const PrerequisiteException([this.message, this.cause]);

  @override
  String toString() {
    final buf = StringBuffer('PrerequisiteException');
    if (message != null) buf.write(': $message');
    if (cause != null) buf.write(' (caused by: $cause)');
    return buf.toString();
  }
}
