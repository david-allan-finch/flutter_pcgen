//
// Copyright 2005, 2007 (C) Tom Parker <thpr@sourceforge.net>
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
// Translation of pcgen.cdom.util.ListKeyMapToList
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';

// A map of lists keyed by ListKey.
class ListKeyMapToList {
  final Map<ListKey<dynamic>, List<dynamic>> _map = {};

  bool containsListFor(ListKey<dynamic> key) => _map.containsKey(key);

  void addToListFor<T>(ListKey<T> key, T element) {
    _map.putIfAbsent(key, () => []).add(element);
  }

  void addAllToListFor<T>(ListKey<T> key, Iterable<T> elements) {
    _map.putIfAbsent(key, () => []).addAll(elements);
  }

  List<T>? getListFor<T>(ListKey<T> key) {
    final list = _map[key];
    if (list == null) return null;
    return List<T>.from(list);
  }

  int sizeOfListFor(ListKey<dynamic> key) {
    return _map[key]?.length ?? 0;
  }

  bool containsInList<T>(ListKey<T> key, T element) {
    return _map[key]?.contains(element) ?? false;
  }

  bool containsAnyInList<T>(ListKey<T> key, Iterable<T> elements) {
    final list = _map[key];
    if (list == null) return false;
    return elements.any((e) => list.contains(e));
  }

  T? getElementInList<T>(ListKey<T> key, int index) {
    final list = _map[key];
    if (list == null || index >= list.length) return null;
    return list[index] as T;
  }

  List<T>? removeListFor<T>(ListKey<T> key) {
    final list = _map.remove(key);
    if (list == null) return null;
    return List<T>.from(list);
  }

  bool removeFromListFor<T>(ListKey<T> key, T element) {
    final list = _map[key];
    if (list == null) return false;
    final removed = list.remove(element);
    if (list.isEmpty) _map.remove(key);
    return removed;
  }

  Set<ListKey<dynamic>> getKeySet() => Set.unmodifiable(_map.keys);

  bool get isEmpty => _map.isEmpty;
}
