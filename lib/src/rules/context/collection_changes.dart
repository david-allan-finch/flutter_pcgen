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
// Translation of pcgen.rules.context.CollectionChanges
import 'package:flutter_pcgen/src/rules/context/changes.dart';

class CollectionChanges<T> implements Changes<T> {
  final List<T>? _positive;
  final List<T>? _negative;
  final bool _clear;

  const CollectionChanges(List<T>? added, List<T>? removed, bool globallyCleared)
      : _positive = added,
        _negative = removed,
        _clear = globallyCleared;

  @override
  bool includesGlobalClear() => _clear;

  @override
  bool isEmpty() => !_clear && !hasAddedItems() && !hasRemovedItems();

  @override
  List<T>? getAdded() => _positive;

  @override
  bool hasAddedItems() => _positive != null && _positive!.isNotEmpty;

  @override
  List<T>? getRemoved() => _negative;

  @override
  bool hasRemovedItems() => _negative != null && _negative!.isNotEmpty;
}
