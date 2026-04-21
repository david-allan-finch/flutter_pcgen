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
// Translation of pcgen.core.SpecialAbility
import 'package:flutter_pcgen/src/core/text_property.dart';

/// Represents a Special Ability in PCGen.
///
/// A special ability has a name and an optional property description (propDesc)
/// that is appended to the display text in parentheses.
final class SpecialAbility extends TextProperty implements Comparable<Object> {
  String _propDesc = '';

  /// Default constructor.
  SpecialAbility();

  /// Constructor with name.
  SpecialAbility.withName(String name) : super.withName(name);

  /// Constructor with name and property description.
  SpecialAbility.withNameAndDesc(String name, String propDesc)
      : _propDesc = propDesc,
        super.withName(name);

  /// Set the description of the Special Ability.
  void setSADesc(String saDesc) => setPropDesc(saDesc);

  /// Get the description of the Special Ability.
  String getSADesc() => getPropDesc();

  @override
  int compareTo(Object obj) {
    return getKeyName().toLowerCase().compareTo(obj.toString().toLowerCase());
  }

  @override
  String toString() => getDisplayName();

  /// Set the property description.
  void setPropDesc(String propDesc) {
    _propDesc = propDesc;
  }

  String getPropDesc() => _propDesc;

  @override
  String getText() {
    final base = super.getText();
    if (_propDesc.isEmpty) {
      return base;
    }
    return '$base ($_propDesc)';
  }
}
