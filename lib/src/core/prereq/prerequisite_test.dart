// Copyright (c) Chris Ward, 2003.
//
// Translation of pcgen.core.prereq.PrerequisiteTest

import 'prerequisite.dart';
import 'prerequisite_exception.dart';

/// Interface for classes that can evaluate a specific kind of prerequisite.
abstract interface class PrerequisiteTest {
  /// Tests the prerequisite against a player character.
  /// Returns the number of matching items (0 = fail, >0 = pass).
  int passesForCharacter(
      Prerequisite prereq, dynamic character, dynamic source);

  /// Tests the prerequisite against a piece of equipment.
  int passesForEquipment(
      Prerequisite prereq, dynamic equipment, dynamic character);

  /// Returns an HTML description of the prerequisite.
  String toHtmlString(Prerequisite prereq);

  /// Returns the kind of prerequisite this tester handles (e.g. 'CLASS').
  String kindHandled();
}
