// Operators for prerequisites.
enum PrerequisiteOperator {
  eq('='),
  neq('!='),
  lt('<'),
  lteq('<='),
  gt('>'),
  gteq('>=');

  final String symbol;
  const PrerequisiteOperator(this.symbol);

  static PrerequisiteOperator getOperatorByName(String name) {
    return PrerequisiteOperator.values.firstWhere(
      (op) => op.name.toUpperCase() == name.toUpperCase() ||
               op.symbol == name,
      orElse: () => throw ArgumentError('Unknown operator: $name'),
    );
  }
}
