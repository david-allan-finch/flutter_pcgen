// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.doomsdaybook.Operation

/// Types of variable operations in the doomsdaybook system.
enum OperationType { set, add, subtract, multiply, divide }

/// Encapsulates a single variable operation: type, key, value, and optional name.
class Operation {
  final OperationType type;
  final String key;
  final String value;
  final String? name;

  const Operation(this.type, this.key, this.value, [this.name]);

  @override
  String toString() => 'Operation($type, $key, $value, $name)';
}
