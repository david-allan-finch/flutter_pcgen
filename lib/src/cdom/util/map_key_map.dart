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
// Translation of pcgen.cdom.util.MapKeyMap
import 'package:flutter_pcgen/src/cdom/enumeration/map_key.dart';

// A map of maps keyed by MapKey.
class MapKeyMap {
  final Map<MapKey<dynamic, dynamic>, Map<dynamic, dynamic>> _map = {};

  dynamic addToMapFor<K, V>(MapKey<K, V> mapKey, K key, V value) {
    final inner = _map.putIfAbsent(mapKey, () => <K, V>{}) as Map<K, V>;
    return inner[key] = value;
  }

  bool removeFromMapFor<K, V>(MapKey<K, V> mapKey, K key) {
    final inner = _map[mapKey] as Map<K, V>?;
    if (inner == null) return false;
    final had = inner.containsKey(key);
    inner.remove(key);
    if (inner.isEmpty) _map.remove(mapKey);
    return had;
  }

  Map<K, V>? removeMapFor<K, V>(MapKey<K, V> mapKey) {
    return _map.remove(mapKey) as Map<K, V>?;
  }

  Map<K, V> getMapFor<K, V>(MapKey<K, V> mapKey) {
    return (_map[mapKey] as Map<K, V>?) ?? {};
  }

  Set<K> getKeysFor<K, V>(MapKey<K, V> mapKey) {
    final inner = _map[mapKey] as Map<K, V>?;
    if (inner == null) return {};
    return Set.unmodifiable(inner.keys);
  }

  V? get<K, V>(MapKey<K, V> mapKey, K key2) {
    return (_map[mapKey] as Map<K, V>?)?[key2];
  }

  bool containsMapFor<K, V>(MapKey<K, V> mapKey) => _map.containsKey(mapKey);

  Set<MapKey<dynamic, dynamic>> getKeySet() => Set.unmodifiable(_map.keys);

  bool get isEmpty => _map.isEmpty;
}
