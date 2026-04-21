//
// Copyright 2015 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.output.model.BooleanOptionModel

/// Output model for a boolean preference option.
class BooleanOptionModel {
  final String _pref;
  final bool _defaultValue;

  BooleanOptionModel(this._pref, this._defaultValue);

  bool get value {
    // TODO: read from PCGen preferences system
    return _defaultValue;
  }

  @override
  String toString() => value.toString();
}
