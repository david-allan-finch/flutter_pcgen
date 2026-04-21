//
// Copyright 2002 (C) Bryan McRoberts <merton_monk@yahoo.com>
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
// Translation of pcgen.core.NoteItem
/// A note item attached to a PlayerCharacter.
///
/// Translated from pcgen.core.NoteItem. NoteItems can be associated with a
/// PCStringKey (for system notes) or be free-form user notes.
final class NoteItem {
  String? _name;
  String? _value;
  int _idParent;
  int _idValue;
  final String? key; // corresponds to PCStringKey (stored as string name)

  /// Create with an optional key.
  NoteItem.withKey(
    this.key,
    int myId,
    int myParent,
    String aName,
    String aValue,
  )   : _idValue = myId,
        _idParent = myParent,
        _name = aName,
        _value = aValue;

  /// Create with a required key.
  NoteItem.withRequiredKey(
    String requiredKey,
    int myId,
    int myParent,
    String aName,
    String aValue,
  )   : key = requiredKey,
        _idValue = myId,
        _idParent = myParent,
        _name = aName,
        _value = aValue;

  /// Create without a key (free-form user note).
  NoteItem(
    int myId,
    int myParent,
    String aName,
    String aValue,
  )   : key = null,
        _idValue = myId,
        _idParent = myParent,
        _name = aName,
        _value = aValue;

  /// Get an export string with surrounding markup.
  String getExportString(
    String beforeName,
    String afterName,
    String beforeValue,
    String afterValue,
  ) {
    return '$beforeName${_name ?? ''}$afterName$beforeValue${_value ?? ''}$afterValue';
  }

  int getId() => _idValue;
  void setIdValue(int x) => _idValue = x;

  void setName(String x) => _name = x;
  String getName() => _name ?? '';

  void setParentId(int x) => _idParent = x;
  int getParentId() => _idParent;

  void setValue(String x) => _value = x;
  String getValue() => _value ?? '';

  String? getPCStringKey() => key;

  @override
  String toString() => _name ?? '';

  NoteItem clone() {
    return NoteItem.withKey(key, _idValue, _idParent, _name ?? '', _value ?? '');
  }

  @override
  int get hashCode => 17 * _idValue ^ 23 * _idParent;

  @override
  bool operator ==(Object o) {
    if (o is NoteItem) {
      return _idParent == o._idParent &&
          _idValue == o._idValue &&
          _name == o._name &&
          _value == o._value &&
          key == o.key;
    }
    return false;
  }
}
