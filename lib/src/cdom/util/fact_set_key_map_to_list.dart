//
// Copyright 2005, 2007, 2014 (C) Tom Parker <thpr@sourceforge.net>
//
// This library is free software; you can redistribute it and/or modify it under the terms
// of the GNU Lesser General Public License as published by the Free Software Foundation;
// either version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along with
// this library; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
// Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.cdom.util.FactSetKeyMapToList
import 'package:flutter_pcgen/src/cdom/enumeration/fact_set_key.dart';

// A map of lists keyed by FactSetKey.
class FactSetKeyMapToList {
  final Map<FactSetKey<dynamic>, List<dynamic>> _map = {};

  bool containsListFor(FactSetKey<dynamic> key) => _map.containsKey(key);

  void addToListFor<T>(FactSetKey<T> key, dynamic element) {
    _map.putIfAbsent(key, () => []).add(element);
  }

  void addAllToListFor<T>(FactSetKey<T> key, Iterable<dynamic> elements) {
    _map.putIfAbsent(key, () => []).addAll(elements);
  }

  List<dynamic>? getListFor<T>(FactSetKey<T> key) {
    final list = _map[key];
    if (list == null) return null;
    return List.from(list);
  }

  int sizeOfListFor(FactSetKey<dynamic> key) {
    return _map[key]?.length ?? 0;
  }

  bool containsInList<T>(FactSetKey<T> key, dynamic element) {
    return _map[key]?.contains(element) ?? false;
  }

  bool containsAnyInList<T>(FactSetKey<T> key, Iterable<dynamic> elements) {
    final list = _map[key];
    if (list == null) return false;
    return elements.any((e) => list.contains(e));
  }

  List<dynamic>? removeListFor<T>(FactSetKey<T> key) {
    return _map.remove(key);
  }

  bool removeFromListFor<T>(FactSetKey<T> key, dynamic element) {
    final list = _map[key];
    if (list == null) return false;
    final removed = list.remove(element);
    if (list.isEmpty) _map.remove(key);
    return removed;
  }

  Set<FactSetKey<dynamic>> getKeySet() => Set.unmodifiable(_map.keys);

  bool get isEmpty => _map.isEmpty;
}
