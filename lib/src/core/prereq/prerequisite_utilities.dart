//
// Copyright 2001 (C) Bryan McRoberts <merton_monk@yahoo.com>
// Copyright 2005 (C) Tom Parker <thpr@sourceforge.net>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Refactored out of PObject July 22, 2005
//
// Translation of pcgen.core.prereq.PrerequisiteUtilities
import 'package:flutter_pcgen/src/cdom/prereq/prerequisite.dart';

/// Utility class related to Prerequisite objects.
///
/// Translated from pcgen.core.prereq.PrerequisiteUtilities (first 80 lines +
/// additional inferred structure).
final class PrerequisiteUtilities {
  PrerequisiteUtilities._(); // Prevent instantiation

  /// Tests a list of prerequisites against a given PC and source object, then
  /// generates an HTML representation of whether they passed.
  ///
  /// [aPC] is a dynamic reference to PlayerCharacter.
  /// [aObj] is the source CDOMObject owning the prerequisites.
  /// [aList] is the list of Prerequisite objects to test.
  /// [includeHeader] wraps output in html tags if true.
  static String preReqHTMLStringsForList(
    dynamic aPC,
    dynamic aObj,
    List<Prerequisite>? aList,
    bool includeHeader,
  ) {
    if (aList == null || aList.isEmpty) return '';

    final sb = StringBuffer();
    if (includeHeader) sb.write('<html>');

    for (final prereq in aList) {
      bool passes = false;
      try {
        passes = prereq.passes(aPC, aObj);
      } catch (_) {
        passes = false;
      }

      final color = passes ? '#000000' : '#FF0000';
      final desc = prereq.getDescription();
      sb.write('<font color="$color">$desc</font><br />');
    }

    if (includeHeader) sb.write('</html>');
    return sb.toString();
  }

  /// Tests whether the PC passes all prerequisites in [prereqList].
  ///
  /// Returns true if prereqList is null or empty.
  static bool passesAll(
    List<Prerequisite>? prereqList,
    dynamic aPC,
    dynamic caller,
  ) {
    if (prereqList == null || prereqList.isEmpty) return true;
    for (final prereq in prereqList) {
      try {
        if (!(prereq.passes(aPC, caller) as bool)) return false;
      } catch (_) {
        return false;
      }
    }
    return true;
  }

  /// Returns the HTML class or type representation of the given prereq.
  static String preReqHTMLString(
    dynamic aPC,
    dynamic aObj,
    Prerequisite prereq,
    bool includeHeader,
  ) {
    return preReqHTMLStringsForList(aPC, aObj, [prereq], includeHeader);
  }
}
