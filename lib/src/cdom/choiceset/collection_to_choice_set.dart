//
// Copyright 2010 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.choiceset.CollectionToChoiceSet
import 'package:flutter_pcgen/src/cdom/base/cdom_reference.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/grouping_state.dart';

// A PrimitiveChoiceSet that wraps a PrimitiveCollection, dereferencing objects
// through a DereferencingConverter for the given PlayerCharacter.
class CollectionToChoiceSet<T> {
  final PrimitiveCollection<T> _primitive;

  CollectionToChoiceSet(PrimitiveCollection<T> prim) : _primitive = prim;

  Type getChoiceClass() => _primitive.getReferenceClass();

  GroupingState getGroupingState() => _primitive.getGroupingState();

  String getLSTformat([bool useAny = false]) => _primitive.getLSTformat(useAny);

  List<T> getSet(dynamic pc) {
    // stub: DereferencingConverter
    return _primitive.getCollection(pc, _DereferencingConverter<T>(pc))
        .cast<T>();
  }

  @override
  int get hashCode => _primitive.hashCode;

  @override
  bool operator ==(Object obj) {
    return obj is CollectionToChoiceSet &&
        obj._primitive == _primitive;
  }
}

// stub: Dereferencing converter that resolves references for a PlayerCharacter.
class _DereferencingConverter<T> implements Converter<T, T> {
  final dynamic _pc;

  _DereferencingConverter(this._pc);

  @override
  List<T> convert(ObjectContainer<T> container) {
    // stub
    return container.getContainedObjects();
  }
}
