//
// Copyright 2008 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.choiceset.QualifiedDecorator
import 'package:flutter_pcgen/src/cdom/enumeration/grouping_state.dart';

// Decorates a PrimitiveChoiceSet to restrict its items to those for which the
// PlayerCharacter meets the prerequisites defined by each item itself.
class QualifiedDecorator<T> {
  // The underlying choice set from which qualifying items are returned.
  final dynamic _underlyingPcs; // PrimitiveChoiceSet<T>

  QualifiedDecorator(dynamic underlyingSet) : _underlyingPcs = underlyingSet;

  Type getChoiceClass() => _underlyingPcs.getChoiceClass() as Type;

  String getLSTformat([bool useAny = false]) =>
      _underlyingPcs.getLSTformat(useAny) as String;

  // Returns only items that the PlayerCharacter qualifies for.
  Set<T> getSet(dynamic pc) {
    final Set<T> returnSet = {};
    for (final T item in (_underlyingPcs.getSet(pc) as Iterable).cast<T>()) {
      // stub: item.qualifies(pc, item)
      final bool qualifies = (item as dynamic).qualifies(pc, item) as bool; // stub
      if (qualifies) {
        returnSet.add(item);
      }
    }
    return returnSet;
  }

  @override
  bool operator ==(Object obj) {
    return obj is QualifiedDecorator &&
        obj._underlyingPcs == _underlyingPcs;
  }

  @override
  int get hashCode => 1 - (_underlyingPcs.hashCode as int);

  GroupingState getGroupingState() =>
      (_underlyingPcs.getGroupingState() as GroupingState).reduce();
}
