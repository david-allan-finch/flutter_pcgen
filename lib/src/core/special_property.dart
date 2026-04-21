//
// Copyright 2004 (C) Devon Jones
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
// Translation of pcgen.core.SpecialProperty
import '../cdom/prereq/prerequisite.dart';
import 'text_property.dart';

/// Represents a Special Property (SPROP) in PCGen.
///
/// SpecialProperty is used on equipment and similar objects to add
/// descriptive properties that may be conditionally displayed based on
/// prerequisites.
final class SpecialProperty extends TextProperty implements Comparable<Object> {
  SpecialProperty();

  SpecialProperty.withName(String name) : super.withName(name);

  /// Create a SpecialProperty from an LST string.
  ///
  /// The input format is: name[|prereq1][|prereq2]...
  /// Returns null if the input is invalid.
  static SpecialProperty? createFromLst(String input) {
    final parts = input.split('|');
    final sp = SpecialProperty();

    if (parts.isEmpty) return sp;

    final spName = parts[0];

    // Check for leading PRExxx
    if (_isPreReqString(spName)) {
      // Error: Leading PRExxx found in SPROP
      return null;
    }

    final sb = StringBuffer(spName);
    bool hitPre = false;
    bool warnedPre = false;

    for (int i = 1; i < parts.length; i++) {
      final cString = parts[i];

      if (_isPreReqString(cString)) {
        hitPre = true;
        // Parse prereq - simplified; full implementation requires PreParserFactory
        final prereq = Prerequisite();
        prereq.kind = cString;
        sp.addPrerequisite(prereq);
      } else {
        if (hitPre && !warnedPre) {
          warnedPre = true;
          // Deprecation warning: PRExxx should be at the end of SPROP
        }
        sb.write('|');
        sb.write(cString);

        if (cString == '.CLEAR') {
          // Error: Invalid/Embedded .CLEAR found in SPROP
          return null;
        }
      }
    }

    sp.setName(sb.toString());
    return sp;
  }

  static bool _isPreReqString(String s) {
    return s.startsWith('PRE') || s.startsWith('!PRE');
  }

  @override
  int compareTo(Object obj) {
    return getKeyName().toLowerCase().compareTo(obj.toString().toLowerCase());
  }

  @override
  String toString() => getDisplayName();
}
