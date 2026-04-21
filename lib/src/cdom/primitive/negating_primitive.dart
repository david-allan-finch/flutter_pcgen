//
// Copyright (c) 2010 Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.primitive.NegatingPrimitive
import '../enumeration/grouping_state.dart';
import '../../core/player_character.dart';

// A PrimitiveCollection that returns all objects EXCEPT those in its wrapped primitive.
class NegatingPrimitive<T> {
  final dynamic _primitive; // PrimitiveCollection<T>
  final dynamic _all; // PrimitiveCollection<T>

  NegatingPrimitive(dynamic prim, dynamic all)
      : _primitive = prim,
        _all = all;

  List getCollection(PlayerCharacter pc, dynamic c) {
    final result = List.from(_all.getCollection(pc, c));
    result.removeWhere((e) => _primitive.getCollection(pc, c).contains(e));
    return result;
  }

  Type getReferenceClass() => _primitive.getReferenceClass();

  GroupingState getGroupingState() =>
      (_primitive.getGroupingState() as GroupingState).negate();

  String getLSTformat(bool useAny) =>
      '!${_primitive.getLSTformat(useAny)}';

  @override
  int get hashCode => _primitive.hashCode - 1;

  @override
  bool operator ==(Object obj) =>
      obj is NegatingPrimitive && obj._primitive == _primitive;
}
