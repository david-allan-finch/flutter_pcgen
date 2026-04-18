// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.doomsdaybook.variableException

/// Exception thrown when a variable operation fails in the doomsdaybook system.
class VariableException implements Exception {
  final String? message;

  const VariableException([this.message]);

  @override
  String toString() =>
      message == null ? 'VariableException' : 'VariableException: $message';
}
