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
// Translation of pcgen.rules.context.AssociatedCollectionChanges
import 'package:flutter_pcgen/src/base/util/map_to_list.dart';
import 'package:flutter_pcgen/src/cdom/base/associated_prereq_object.dart';
import 'associated_changes.dart';

class AssociatedCollectionChanges<T> implements AssociatedChanges<T> {
  final MapToList<T, AssociatedPrereqObject>? _positive;
  final MapToList<T, AssociatedPrereqObject>? _negative;
  final bool _clear;

  AssociatedCollectionChanges(
    MapToList<T, AssociatedPrereqObject>? added,
    MapToList<T, AssociatedPrereqObject>? removed,
    bool globallyCleared,
  )   : _positive = added,
        _negative = removed,
        _clear = globallyCleared;

  @override
  bool includesGlobalClear() => _clear;

  bool isEmpty() => !_clear && !hasAddedItems() && !hasRemovedItems();

  @override
  List<T>? getAdded() => _positive?.getKeySet().toList();

  bool hasAddedItems() => _positive != null && !_positive!.isEmpty();

  @override
  List<T>? getRemoved() {
    if (_negative == null) return null;
    return _negative!.getKeySet().toList();
  }

  bool hasRemovedItems() => _negative != null && !_negative!.isEmpty();

  @override
  MapToList<T, AssociatedPrereqObject>? getAddedAssociations() => _positive;

  @override
  MapToList<T, AssociatedPrereqObject>? getRemovedAssociations() => _negative;
}
