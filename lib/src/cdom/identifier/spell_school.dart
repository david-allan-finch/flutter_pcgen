//
// Copyright (c) 2010 Tom Parker <thpr@users.sourceforge.net>
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
//
// Translation of pcgen.cdom.identifier.SpellSchool
import 'package:flutter_pcgen/src/cdom/base/loadable.dart';

// Identifies a spell school (e.g. "Abjuration") as a Loadable object.
class SpellSchool implements Loadable, Comparable<SpellSchool> {
  String? _sourceUri;
  String? _name;

  @override
  String getDisplayName() => _name ?? '';

  @override
  String getKeyName() => _name ?? '';

  @override
  bool isInternal() => false;

  @override
  bool isType(String type) => false;

  @override
  void setName(String newName) => _name = newName;

  @override
  String toString() => _name ?? '';

  @override
  bool operator ==(Object other) =>
      other is SpellSchool && _name == other._name;

  @override
  int get hashCode => _name.hashCode;

  @override
  int compareTo(SpellSchool other) => (_name ?? '').compareTo(other._name ?? '');

  @override
  String? getSourceURI() => _sourceUri;

  @override
  void setSourceURI(String source) => _sourceUri = source;
}
