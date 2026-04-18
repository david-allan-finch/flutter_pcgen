// Copyright (c) Tom Parker, 2016.
//
// Translation of pcgen.cdom.formula.AssociationUtilities

/// Utility methods for processing formula associations (e.g. PRIORITY=x).
class AssociationUtilities {
  AssociationUtilities._();

  /// Parses a PRIORITY=<n> association string and returns the integer value.
  static int processUserPriority(String assocInstructions) {
    final eqIdx = assocInstructions.indexOf('=');
    final name = assocInstructions.substring(0, eqIdx);
    final value = assocInstructions.substring(eqIdx + 1);
    if (name.toUpperCase() == 'PRIORITY') {
      final n = int.tryParse(value);
      if (n == null) {
        throw ArgumentError('Priority must be an integer: $value');
      }
      if (n < 0) {
        throw ArgumentError('Priority must be >= 0. $n is not positive');
      }
      return n;
    }
    throw ArgumentError('Association $name not recognized');
  }

  /// Converts a user priority integer back to its string form.
  static String unprocessUserPriority(int userPriority) => 'PRIORITY=$userPriority';
}
