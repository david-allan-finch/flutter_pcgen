//
// Copyright 2007 (C) Tom Parker <thpr@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This library is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.cdom.content.ChangeProf
import '../base/cdom_reference.dart';
import '../base/concrete_prereq_object.dart';
import '../reference/cdom_group_ref.dart';
import '../../core/weapon_prof.dart';

// Represents a change to a WeaponProficiency type for a PlayerCharacter.
class ChangeProf extends ConcretePrereqObject {
  final CdomReference<WeaponProf> _source;
  final CdomGroupRef<WeaponProf> _result;

  ChangeProf(CdomReference<WeaponProf> sourceProf, CdomGroupRef<WeaponProf> resultType)
      : _source = sourceProf,
        _result = resultType;

  CdomReference<WeaponProf> getSource() => _source;
  CdomGroupRef<WeaponProf> getResult() => _result;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChangeProf) return false;
    return _source == other._source && _result == other._result;
  }

  @override
  int get hashCode => 31 * _source.hashCode + _result.hashCode;

  @override
  String toString() => 'ChangeProf[$_source -> $_result]';
}
