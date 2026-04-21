//
// Copyright 2005 (c) Stefan Raderamcher <radermacher@netcologne.de>
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
// Translation of pcgen.core.SpellProhibitor
import 'package:flutter_pcgen/src/cdom/base/concrete_prereq_object.dart';

// Defines what spells are prohibited for a class/subclass (by alignment, school, etc.).
enum ProhibitedSpellType { alignment, school, subSchool, descriptor, spell }

class SpellProhibitor extends ConcretePrereqObject {
  ProhibitedSpellType? type;
  List<String> valueList = [];

  void addValue(String value) => valueList.add(value);

  bool isProhibited(dynamic spell, dynamic aPC, dynamic owner) {
    if (!qualifies(aPC, owner)) return false;
    // Full implementation requires spell descriptor lookup
    return false;
  }

  @override
  String toString() => '${type?.name ?? ''}:${valueList.join(',')}';

  @override
  int get hashCode => (type?.hashCode ?? 0) ^ valueList.length;

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    if (o is! SpellProhibitor) return false;
    return type == o.type && valueList.toString() == o.valueList.toString();
  }
}
