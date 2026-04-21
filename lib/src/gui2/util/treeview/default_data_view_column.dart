//
// Copyright 2008 (C) Connor Petty <mistercpp2000@gmail.com>
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
// Translation of pcgen.gui2.util.treeview.DefaultDataViewColumn

import 'package:flutter_pcgen/src/gui2/util/treeview/data_view_column.dart';

/// Default implementation of DataViewColumn.
class DefaultDataViewColumn implements DataViewColumn {
  final String _header;
  final Type _dataClass;
  final bool _visible;
  final bool _editable;
  final double _preferredWidth;

  const DefaultDataViewColumn(
    this._header, {
    Type dataClass = String,
    bool visible = true,
    bool editable = false,
    double preferredWidth = 100.0,
  })  : _dataClass = dataClass,
        _visible = visible,
        _editable = editable,
        _preferredWidth = preferredWidth;

  @override
  String getHeaderValue() => _header;

  @override
  Type getDataClass() => _dataClass;

  @override
  bool isVisible() => _visible;

  @override
  bool isEditable() => _editable;

  @override
  double getPreferredWidth() => _preferredWidth;
}
