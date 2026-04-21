//
// Copyright (c) 2014-15 Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.primitive.ObjectContainerPrimitive
import '../enumeration/grouping_state.dart';
import '../../core/player_character.dart';

// Wraps an ObjectContainer as a PrimitiveCollection.
class ObjectContainerPrimitive<T> {
  final dynamic _group; // ObjectContainer<T>

  ObjectContainerPrimitive(dynamic oc) : _group = oc;

  List getCollection(PlayerCharacter pc, dynamic c) =>
      List.from(c.convert(_group));

  Type getReferenceClass() => _group.getReferenceClass();

  GroupingState getGroupingState() => GroupingState.any;

  String getLSTformat(bool useAny) => _group.getLSTformat(useAny) as String;

  @override
  int get hashCode => _group.hashCode - 1;

  @override
  bool operator ==(Object obj) =>
      obj is ObjectContainerPrimitive && obj._group == _group;
}
