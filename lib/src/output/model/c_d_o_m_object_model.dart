//
// Copyright 2014-15 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.output.model.CDOMObjectModel

import '../base/output_actor.dart';

/// Output model wrapping a CDOMObject. Provides hash-model access to actors
/// registered for the object's type.
class CDOMObjectModel {
  final String _charId;
  final dynamic _obj;
  final Map<String, OutputActor<dynamic>> _actors;

  CDOMObjectModel(this._charId, this._obj, this._actors);

  /// Get the output for a named interpolation key.
  dynamic get(String key) {
    final actor = _actors[key];
    if (actor == null) return null;
    return actor.process(_charId, _obj);
  }
}
