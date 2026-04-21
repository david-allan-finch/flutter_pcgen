//
// Copyright 2008 (C) James Dempsey
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
// Translation of pcgen.rules.context.MapChanges
/// Tracks changes to a map so that the changes can be committed or rolled back
/// at a later stage. Items can be added to the map, removed from the map or the
/// map can be cleared.
class MapChanges<K, V> {
  final Map<K, V>? _positive;
  final Map<K, V>? _negative;
  final bool _clear;

  MapChanges(Map<K, V>? added, Map<K, V>? removed, bool globallyCleared)
      : _positive = added,
        _negative = removed,
        _clear = globallyCleared;

  bool includesGlobalClear() => _clear;

  bool isEmpty() => !_clear && !hasAddedItems() && !hasRemovedItems();

  Map<K, V>? getAdded() => _positive;

  bool hasAddedItems() => _positive != null && _positive!.isNotEmpty;

  Map<K, V>? getRemoved() => _negative;

  bool hasRemovedItems() => _negative != null && _negative!.isNotEmpty;
}
