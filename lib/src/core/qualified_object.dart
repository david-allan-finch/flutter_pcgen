//
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
// Current Version: $Revision$
//
// Copyright 2006 Aaron Divinsky <boomer70@yahoo.com>
//
// Translation of pcgen.core.QualifiedObject
import 'package:flutter_pcgen/src/cdom/base/concrete_prereq_object.dart';
import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/prereq/prerequisite.dart';
import 'package:flutter_pcgen/src/core/player_character.dart';

// Associates an object with a set of prerequisites — the object is only
// available when all prerequisites are met.
class QualifiedObject<T> extends ConcretePrereqObject {
  T _object;

  QualifiedObject(this._object);

  QualifiedObject.withPrereq(this._object, Prerequisite prereq) {
    addPrerequisite(prereq);
  }

  QualifiedObject.withPrereqs(this._object, List<Prerequisite> prereqs) {
    addAllPrerequisites(prereqs);
  }

  /// Returns the object if [aPC] is null or qualifies, otherwise null.
  T? getObject(PlayerCharacter? aPC, CDOMObject? owner) {
    if (aPC == null || qualifies(aPC, owner)) return _object;
    return null;
  }

  T getRawObject() => _object;

  void setObject(T obj) { _object = obj; }

  @override
  String toString() => 'Object:$_object, Prereq:${getPrerequisiteList()}';

  @override
  bool operator ==(Object obj) {
    if (obj is! QualifiedObject<T>) return false;
    if (!equalsPrereqObject(obj)) return false;
    return _object == obj._object;
  }

  @override
  int get hashCode => getPrerequisiteCount() * 23 + _object.hashCode;
}
