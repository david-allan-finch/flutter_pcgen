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
// Translation of pcgen.cdom.inst.EquipmentHead
import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';

// Represents one "head" of a weapon (weapons can have multiple heads, e.g. double axe).
final class EquipmentHead extends CDOMObject {
  static const String pcEquipmentPart = 'PC.EQUIPMENT.PART';

  final dynamic _headSource; // VarScoped owner
  final int _index;

  EquipmentHead(dynamic source, int idx)
      : _headSource = source,
        _index = idx {
    if (source == null) throw ArgumentError('Source for EquipmentHead cannot be null');
  }

  int getHeadIndex() => _index;

  dynamic getOwner() => _headSource;

  @override
  int get hashCode => _index ^ _headSource.hashCode;

  @override
  bool operator ==(Object obj) {
    if (identical(this, obj)) return true;
    if (obj is! EquipmentHead) return false;
    return obj._index == _index && obj._headSource == _headSource;
  }

  @override
  bool isType(String type) => false;

  @override
  String? getLocalScopeName() => pcEquipmentPart;
}
