// Copyright (c) Chris Ward, 2003.
//
// Translation of pcgen.core.prereq.PrerequisiteOperator

import 'package:flutter_pcgen/src/core/prereq/prerequisite_exception.dart';

/// Comparison operator for prerequisites.
enum PrerequisiteOperator {
  gteq('>='),
  gt('>'),
  eq('='),
  neq('!='),
  lt('<'),
  lteq('<=');

  final String formulaSyntax;

  const PrerequisiteOperator(this.formulaSyntax);

  PrerequisiteOperator invert() {
    switch (this) {
      case PrerequisiteOperator.gteq:
        return PrerequisiteOperator.lt;
      case PrerequisiteOperator.gt:
        return PrerequisiteOperator.lteq;
      case PrerequisiteOperator.eq:
        return PrerequisiteOperator.neq;
      case PrerequisiteOperator.neq:
        return PrerequisiteOperator.eq;
      case PrerequisiteOperator.lt:
        return PrerequisiteOperator.gteq;
      case PrerequisiteOperator.lteq:
        return PrerequisiteOperator.gt;
    }
  }

  bool booleanCompare(double a, double b) {
    switch (this) {
      case PrerequisiteOperator.gteq:
        return a >= b;
      case PrerequisiteOperator.gt:
        return a > b;
      case PrerequisiteOperator.eq:
        return (a - b).abs() < 1e-10;
      case PrerequisiteOperator.neq:
        return (a - b).abs() >= 1e-10;
      case PrerequisiteOperator.lt:
        return a < b;
      case PrerequisiteOperator.lteq:
        return a <= b;
    }
  }

  int compareInt(int leftHandOp, int rightHandOp) {
    return compareDouble(leftHandOp.toDouble(), rightHandOp.toDouble()).toInt();
  }

  double compareDouble(double leftHandOp, double rightHandOp) {
    if (booleanCompare(leftHandOp, rightHandOp)) {
      if (leftHandOp < 0.0 || leftHandOp == 0.0) return 1;
      return leftHandOp;
    }
    return 0;
  }

  static PrerequisiteOperator getOperatorByName(String operatorName) {
    final upper = operatorName.toUpperCase();
    for (final op in PrerequisiteOperator.values) {
      if (op.name.toUpperCase() == upper) return op;
    }
    for (final op in PrerequisiteOperator.values) {
      if (op.formulaSyntax == operatorName) return op;
    }
    throw PrerequisiteException('Invalid operator: $operatorName');
  }
}
