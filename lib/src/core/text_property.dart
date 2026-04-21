//
// Copyright 2001 (C) Bryan McRoberts <merton_monk@yahoo.com>
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
// Translation of pcgen.core.TextProperty
import 'pcobject.dart';

/// Abstract base class for text-based properties (SpecialAbility, SpecialProperty, etc).
///
/// Extends PObject to provide named text properties with optional variable
/// substitution and prerequisite support.
abstract class TextProperty extends PObject implements Comparable<Object> {
  TextProperty();

  TextProperty.withName(String name) {
    setName(name);
  }

  @override
  int compareTo(Object obj) {
    if (obj is TextProperty) {
      return getKeyName().compareTo(obj.getKeyName());
    } else if (obj is PObject) {
      return getKeyName().toLowerCase().compareTo(obj.getKeyName().toLowerCase());
    }
    return getKeyName().toLowerCase().compareTo(obj.toString().toLowerCase());
  }

  /// Get the property text (display name by default).
  String getText() {
    return getDisplayName();
  }

  /// Get the parsed text with %CHOICE substitutions resolved.
  ///
  /// [pc] is a dynamic reference to PlayerCharacter.
  /// [varOwner] is the object that owns any variables used.
  /// [qualOwner] is the object used for qualification checks.
  String getParsedText(dynamic pc, dynamic varOwner, dynamic qualOwner) {
    return _getParsedTextInternal(pc, getText(), varOwner, qualOwner);
  }

  String _getParsedTextInternal(
      dynamic pc, String fullDesc, dynamic varOwner, dynamic qualOwner) {
    if (fullDesc.isEmpty) return '';

    String source = '';
    try {
      source = (qualOwner as dynamic).getQualifiedKey() as String;
    } catch (_) {}

    // Check prereqs via qualOwner
    bool passes = true;
    try {
      passes = qualifies(pc, qualOwner);
    } catch (_) {}

    if (!passes) return '';

    // full desc format: "description|var1|var2|..."
    final parts = fullDesc.split('|');
    final description = parts[0];

    if (parts.length <= 1) {
      return description;
    }

    final varTokens = parts.sublist(1);
    bool atLeastOneNonZero = false;
    final varValues = <int>[];

    for (final varToken in varTokens) {
      int value = 0;
      try {
        final result = (varOwner as dynamic).getVariableValue(varToken, source, pc);
        value = (result as num).truncate();
      } catch (_) {}
      if (value != 0) atLeastOneNonZero = true;
      varValues.add(value);
    }

    if (!atLeastOneNonZero) return '';

    // Replace % placeholders with variable values
    final newAbility = StringBuffer();
    int varCount = 0;
    int i = 0;
    while (i < description.length) {
      if (description[i] == '%') {
        if (varCount < varValues.length) {
          newAbility.write(varValues[varCount++]);
        } else {
          newAbility.write('%');
        }
      } else {
        newAbility.write(description[i]);
      }
      i++;
    }

    return newAbility.toString();
  }
}
