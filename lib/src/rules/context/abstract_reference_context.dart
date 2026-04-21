//
// Copyright 2007 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.rules.context.AbstractReferenceContext
import '../../cdom/base/cdom_object.dart';
import '../../cdom/base/loadable.dart';
import '../../cdom/reference/cdom_direct_single_ref.dart';
import '../../cdom/reference/cdom_single_ref.dart';

// Abstract context for managing references to game objects.
abstract class AbstractReferenceContext {
  // Registry of all loaded objects by type
  final Map<Type, Map<String, dynamic>> _registry = {};

  // Construct a new object of the given type with the given key
  T constructNowIfNecessary<T extends Loadable>(Type type, String key) {
    final byKey = _registry.putIfAbsent(type, () => {});
    if (byKey.containsKey(key)) return byKey[key] as T;
    throw StateError('Object not found: $type/$key');
  }

  // Register an object
  void register<T extends Loadable>(T obj) {
    final byKey = _registry.putIfAbsent(obj.runtimeType, () => {});
    byKey[obj.getKeyName()] = obj;
  }

  // Get a reference to a single object by key
  CDOMSingleRef<T> getCDOMReference<T extends Loadable>(Type type, String key) {
    final byKey = _registry[type];
    if (byKey != null && byKey.containsKey(key)) {
      return CDOMDirectSingleRef<T>(byKey[key] as T);
    }
    // Return deferred reference
    return _DeferredSingleRef<T>(key);
  }

  // Get all objects of a type
  List<T> getAllConstructed<T extends Loadable>(Type type) {
    final byKey = _registry[type];
    if (byKey == null) return [];
    return byKey.values.cast<T>().toList();
  }

  void resolveReferences();
}

// A deferred reference that resolves later
class _DeferredSingleRef<T> implements CDOMSingleRef<T> {
  final String _key;
  T? _resolved;

  _DeferredSingleRef(this._key);

  void resolve(T obj) { _resolved = obj; }

  @override
  T get() {
    if (_resolved == null) throw StateError('Reference not resolved: $_key');
    return _resolved!;
  }

  @override
  bool hasBeenResolved() => _resolved != null;

  @override
  bool contains(T obj) => _resolved == obj;

  @override
  List<T> getContainedObjects() => _resolved == null ? [] : [_resolved!];

  @override
  String getLSTformat([String? joinWith]) => _key;

  @override
  int getReferenceCount() => _resolved == null ? 0 : 1;

  @override
  String? getReferenceClass() => T.toString();

  @override
  String getPersistentFormat() => _key;
}
