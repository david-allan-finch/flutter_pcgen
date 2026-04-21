// Copyright (c) Chris Ward, 2003.
//
// Translation of pcgen.core.prereq.AbstractPrerequisiteTest

import 'package:flutter_pcgen/src/core/prereq/prerequisite.dart';
import 'package:flutter_pcgen/src/core/prereq/prerequisite_exception.dart';
import 'package:flutter_pcgen/src/core/prereq/prerequisite_test.dart';

/// Base class for PrerequisiteTest implementations. Provides default
/// implementations that throw unless overridden by the subclass.
abstract class AbstractPrerequisiteTest implements PrerequisiteTest {
  @override
  int passesForCharacter(
      Prerequisite prereq, dynamic character, dynamic source) {
    throw PrerequisiteException(
        '${runtimeType} does not support character-based testing');
  }

  @override
  int passesForEquipment(
      Prerequisite prereq, dynamic equipment, dynamic character) {
    if (character == null) {
      throw PrerequisiteException(
          '${runtimeType} does not support equipment-based testing');
    }
    // Fall back to character-based test with the equipment as source.
    return passesForCharacter(prereq, character, equipment);
  }

  @override
  String toHtmlString(Prerequisite prereq) {
    return 'PRE${prereq.kind?.toUpperCase() ?? ''}: ${prereq.operand}, '
        '${prereq.key} ${prereq.operator.formulaSyntax} ${prereq.operand}';
  }

  /// Helper: returns the running total clamped to 0 or 1 unless
  /// countMultiples or totalValues is set.
  int countedTotal(Prerequisite prereq, int runningTotal) {
    if (prereq.countMultiples || prereq.totalValues) return runningTotal;
    return runningTotal > 0 ? 1 : 0;
  }
}
