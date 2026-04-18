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
