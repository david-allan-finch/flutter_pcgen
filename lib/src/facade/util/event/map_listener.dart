// Copyright 2012 Connor Petty <cpmeister@users.sourceforge.net>
//
// Translation of pcgen.facade.util.event.MapListener

import 'map_event.dart';

/// Listener for changes to a MapFacade.
abstract interface class MapListener<K, V> {
  /// Called when a key is added for the first time along with some value.
  void keyAdded(MapEvent<K, V> e);

  /// Called when a key is removed from the map along with its value.
  void keyRemoved(MapEvent<K, V> e);

  /// Called when a key's state has somehow changed (e.g. a ReferenceFacade key changed).
  void keyModified(MapEvent<K, V> e);

  /// Called when the value for a given key has been replaced.
  void valueChanged(MapEvent<K, V> e);

  /// Called when the value for a specific key changed internally (not replaced).
  void valueModified(MapEvent<K, V> e);

  /// Called when the underlying map has undergone bulk changes.
  void keysChanged(MapEvent<K, V> e);
}
