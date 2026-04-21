//
// Copyright 2012 (C) Connor Petty <cpmeister@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.facade.util.DefaultMapFacade
import 'abstract_map_facade.dart';

class DefaultMapFacade<K, V> extends AbstractMapFacade<K, V> {
  final Map<K, V> _map;

  DefaultMapFacade() : _map = {};

  DefaultMapFacade.from(Map<K, V> map) : _map = Map.of(map);

  @override
  Set<K> getKeys() => Set.unmodifiable(_map.keys.toSet());

  @override
  V? getValue(K key) => _map[key];

  void putValue(K key, V value) {
    final hasKey = _map.containsKey(key);
    final oldValue = _map[key];
    _map[key] = value;
    if (hasKey) {
      fireValueChanged(this, key, oldValue as V, value);
    } else {
      fireKeyAdded(this, key, value);
    }
  }

  void removeKey(K key) {
    if (_map.containsKey(key)) {
      final value = _map.remove(key) as V;
      fireKeyRemoved(this, key, value);
    }
  }

  void setContents(Map<K, V> newMap) {
    _map.clear();
    _map.addAll(newMap);
    fireKeysChanged(this);
  }

  void clear() {
    _map.clear();
    fireKeysChanged(this);
  }

  @override
  String toString() => 'DefaultMapFacade($_map)';
}
