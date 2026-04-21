//
// Copyright 2006 (C) Aaron Divinsky <boomer70@yahoo.com>
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
// Translation of pcgen.cdom.content.DamageReduction
import '../base/concrete_prereq_object.dart';

// Encapsulates a single DamageReduction entity (e.g., 5/magic, 10/cold iron).
class DamageReduction extends ConcretePrereqObject {
  final String reduction; // formula string or constant
  final String bypass;

  DamageReduction(this.reduction, this.bypass);

  String getBypass() => bypass;
  String getReduction() => reduction;

  // Returns the raw numeric reduction if static, otherwise -1.
  int getRawReductionValue() {
    final val = int.tryParse(reduction);
    return val ?? -1;
  }

  // Returns unique bypass tokens (lowercase), excluding "or"/"and".
  Set<String> getBypassList() {
    final tokens = bypass.split(RegExp(r'\s+'));
    return tokens
        .where((t) => t.toLowerCase() != 'or' && t.toLowerCase() != 'and' && t.isNotEmpty)
        .map((t) => t.toLowerCase())
        .toSet();
  }

  String getLSTformat() => '$reduction/$bypass';

  @override
  String toString() {
    final val = getRawReductionValue();
    final reductionStr = val < 0 ? 'variable' : reduction;
    return '$reductionStr/$bypass';
  }

  @override
  bool operator ==(Object other) {
    if (other is! DamageReduction) return false;
    final coll1 = getBypassList();
    final coll2 = other.getBypassList();
    return coll1.containsAll(coll2) && coll2.containsAll(coll1) && reduction == other.reduction;
  }

  @override
  int get hashCode {
    final list = getBypassList().toList()..sort();
    int hash = list.fold(0, (h, s) => h + s.hashCode);
    return reduction.hashCode + hash;
  }
}
