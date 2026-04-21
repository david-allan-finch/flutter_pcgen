// Copyright (c) Tom Parker, 2012; Chris Ward, 2003.
//
// Translation of pcgen.core.prereq.AbstractDisplayPrereqTest

import 'package:flutter_pcgen/src/core/prereq/abstract_prerequisite_test.dart';
import 'package:flutter_pcgen/src/core/prereq/prerequisite.dart';
import 'package:flutter_pcgen/src/core/prereq/prerequisite_exception.dart';

/// Transition base class that routes prerequisite testing through a
/// CharacterDisplay instead of directly through PlayerCharacter.
abstract class AbstractDisplayPrereqTest extends AbstractPrerequisiteTest {
  @override
  final int passesForCharacter(
      Prerequisite prereq, dynamic character, dynamic source) {
    final display = character?.getDisplay();
    return passesForDisplay(prereq, display, source);
  }

  @override
  final int passesForEquipment(
      Prerequisite prereq, dynamic equipment, dynamic character) {
    final display = character?.getDisplay();
    return passesEquipmentForDisplay(prereq, equipment, display);
  }

  /// Tests the prerequisite against a CharacterDisplay.
  int passesForDisplay(
      Prerequisite prereq, dynamic display, dynamic source) {
    throw PrerequisiteException(
        '${runtimeType} does not support character display testing');
  }

  /// Tests the prerequisite against equipment using a CharacterDisplay.
  int passesEquipmentForDisplay(
      Prerequisite prereq, dynamic equipment, dynamic display) {
    if (display == null) {
      throw PrerequisiteException(
          '${runtimeType} does not support equipment testing without a character');
    }
    return passesForDisplay(prereq, display, equipment);
  }
}
