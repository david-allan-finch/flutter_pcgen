//
// Copyright (c) Thomas Parker, 2012.
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
// Translation of pcgen.cdom.content.Selection
import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';

// Generic container pairing a CDOMObject with an optional selection string.
class Selection<BT extends CdomObject, SEL> {
  final BT _base;
  final SEL? _selection;

  Selection(BT obj, SEL? sel)
      : _base = obj,
        _selection = sel;

  BT getObject() => _base;
  SEL? getSelection() => _selection;

  @override
  bool operator ==(Object other) {
    if (other is Selection<BT, SEL>) {
      final selEqual = _selection == other._selection;
      return selEqual && _base == other._base;
    }
    return false;
  }

  @override
  int get hashCode => _base.hashCode ^ (_selection?.hashCode ?? 0);
}
