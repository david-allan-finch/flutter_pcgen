//
// Copyright 2012 Connor Petty <cpmeister@users.sourceforge.net>
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
// Translation of pcgen.facade.util.MapFacade
import 'package:flutter_pcgen/src/facade/util/event/map_event.dart';

abstract interface class MapFacade<K, V> {
  void addMapListener(MapListener<K, V> listener);
  void removeMapListener(MapListener<K, V> listener);

  /// Returns the set of keys in this map.
  Set<K> getKeys();

  V? getValue(K key);

  int getSize();

  bool containsKey(K key);

  bool isEmpty();
}
