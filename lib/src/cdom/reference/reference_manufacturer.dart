//
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
//
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
//
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
//
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
// Translation of pcgen.cdom.reference.ReferenceManufacturer
import '../../base/util/format_manager.dart';
import '../base/cdom_reference.dart';
import '../base/loadable.dart';
import 'cdom_single_ref.dart';
import 'manufacturable_factory.dart';
import 'selection_creator.dart';
import 'unconstructed_listener.dart';
import 'unconstructed_validator.dart';

// A ReferenceManufacturer creates and manages CDOMReferences for a given type
// (class, or class+category for categorized objects).
abstract interface class ReferenceManufacturer<T extends Loadable>
    implements SelectionCreator<T>, FormatManager<T> {
  // Constructs a new object with the given key.
  T constructObject(String key);

  // Imports an externally constructed object under the given key.
  void addObject(T item, String key);

  // Returns true if an object with the given key has been constructed.
  bool containsObjectKeyed(String key);

  // Returns the object stored under the given key, or null if absent.
  T? getActiveObject(String key);

  // Returns the object stored under the given key, or null if absent.
  T? getObject(String key);

  // Returns all constructed objects, sorted by key name.
  List<T> getAllObjects();

  // Changes the stored key for the given object.
  void renameObject(String key, T item);

  // Removes the given object; returns true if it was present.
  bool forgetObject(T item);

  // Resolves all outstanding references using objects in this manufacturer.
  bool resolveReferences(UnconstructedValidator validator);

  // Schedules construction of an object with the given key if it has not been
  // constructed by the time buildDeferredObjects() is called.
  void constructIfNecessary(String key);

  // Builds any objects whose construction was deferred via constructIfNecessary.
  void buildDeferredObjects();

  // Returns true if this manufacturer is in a valid state.
  bool validate(UnconstructedValidator validator);

  // Immediately constructs and returns an object for the given key if one does
  // not already exist; otherwise returns the existing object.
  T constructNowIfNecessary(String key);

  // Registers a listener to be notified of unconstructed references.
  void addUnconstructedListener(UnconstructedListener listener);

  // Returns the currently registered unconstructed listeners.
  List<UnconstructedListener> getUnconstructedListeners();

  // Removes a previously registered unconstructed listener.
  void removeUnconstructedListener(UnconstructedListener listener);

  // Returns the number of objects constructed in or imported into this manufacturer.
  int getConstructedObjectCount();

  // Builds and returns a new object with the given name (for derivative objects).
  T buildObject(String name);

  // Fires an unconstructed event for the given reference.
  void fireUnconstructedEvent(CDOMReference<dynamic> reference);

  // Returns all CDOMSingleRefs that have been requested from this manufacturer.
  List<CDOMSingleRef<T>> getReferenced();

  // Returns the ManufacturableFactory backing this manufacturer.
  ManufacturableFactory<T> getFactory();

  // Returns all references (single and group) that have been requested.
  List<CDOMReference<T>> getAllReferences();

  // Copies constructed objects from this manufacturer into the given one.
  void injectConstructed(ReferenceManufacturer<T> rm);

  // Registers a derivative (unnamed sub-)object for post-load validation.
  void addDerivativeObject(T obj);

  // Returns all derivative objects registered with this manufacturer.
  List<T> getDerivativeObjects();

  // Returns the persistent format string for the ClassIdentity managed here.
  String getPersistentFormat();
}
