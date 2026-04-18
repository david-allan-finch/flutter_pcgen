// Copyright (c) Tom Parker, 2007.
//
// Translation of pcgen.cdom.reference.AbstractReferenceManufacturer

import '../base/cdom_reference.dart';
import '../base/cdom_single_ref.dart';
import '../base/loadable.dart';
import 'cdom_all_ref.dart';
import 'cdom_direct_single_ref.dart';
import 'cdom_group_ref.dart';
import 'cdom_simple_single_ref.dart';
import 'cdom_type_ref.dart';

/// Abstract base for ReferenceManufacturer implementations.
/// Manages construction, storage, and resolution of CDOMReferences.
abstract class AbstractReferenceManufacturer<T extends Loadable> {
  final dynamic factory;

  bool _isResolved = false;
  CDOMGroupRef<T>? _allRef;

  /// Type references: sorted type list string → CDOMTypeRef
  final Map<String, CDOMGroupRef<T>> _typeReferences = {};

  /// Single references: key (case-insensitive) → CDOMSingleRef
  final Map<String, CDOMSingleRef<T>> _referenced = {};

  /// Active objects: key (case-insensitive) → object
  final Map<String, T> _active = {};

  /// Duplicate objects: key (case-insensitive) → list
  final Map<String, List<T>> _duplicates = {};

  /// Objects whose construction was deferred.
  final List<String> _deferred = [];

  final List<UnconstructedListener> _listeners = [];

  AbstractReferenceManufacturer(this.factory) {
    if (factory == null) throw ArgumentError('Factory cannot be null');
  }

  // ---- Reference accessors ----

  CDOMGroupRef<T> getTypeReference(List<String> types) {
    for (final type in types) {
      if (type.isEmpty) throw ArgumentError('Empty type not allowed');
      if (type.contains('.') || type.contains('=') ||
          type.contains(',') || type.contains('|')) {
        throw ArgumentError('Invalid character in type: $type');
      }
    }
    final sortedTypes = [...types]..sort();
    final key = sortedTypes.join('.');
    return _typeReferences.putIfAbsent(
        key, () => factory.getTypeReference(sortedTypes) as CDOMGroupRef<T>);
  }

  CDOMGroupRef<T> getAllReference() {
    _allRef ??= factory.getAllReference() as CDOMGroupRef<T>;
    return _allRef!;
  }

  Type get referenceClass => factory.getReferenceClass() as Type;

  CDOMSingleRef<T> getReference(String key) {
    if (key.isEmpty) throw ArgumentError('Cannot request empty identifier');
    final upper = key.toUpperCase();
    if (upper == 'ANY') throw ArgumentError('ANY is not a valid single item');
    if (upper == 'ALL') throw ArgumentError('ALL is not a valid single item');
    if (key.contains('=')) throw ArgumentError('= not allowed in single item key');
    if (key.contains(':')) throw ArgumentError(': not allowed in single item key');
    if (key == '%LIST') throw ArgumentError('%LIST not valid here');
    if (int.tryParse(key) != null) throw ArgumentError('Number not a valid key: $key');

    final lKey = key.toLowerCase();
    final existing = _referenced[lKey];
    if (existing != null) return existing;

    CDOMSingleRef<T> ref;
    if (_isResolved) {
      final current = _active[lKey];
      if (current == null) {
        throw ArgumentError('$key is not valid post-resolution');
      }
      ref = CDOMDirectSingleRef.getRef(current) as CDOMSingleRef<T>;
    } else {
      ref = CDOMSimpleSingleRef<T>(factory.getReferenceClass() as Type, key);
    }
    _referenced[lKey] = ref;
    return ref;
  }

  // ---- Object management ----

  void addObject(T item, String key) {
    if (!factory.isMember(item)) {
      throw ArgumentError('Object type mismatch: ${item.runtimeType}');
    }
    final lKey = key.toLowerCase();
    if (!_active.containsKey(lKey)) {
      _active[lKey] = item;
    } else {
      _duplicates.putIfAbsent(lKey, () => []).add(item);
    }
  }

  T? getActiveObject(String key) => _active[key.toLowerCase()];

  T? getObject(String key) {
    final lKey = key.toLowerCase();
    final obj = _active[lKey];
    if (obj != null) {
      final dups = _duplicates[lKey];
      if (dups != null && dups.isNotEmpty) {
        // Log ambiguous reference warning
      }
    }
    return obj;
  }

  T constructObject(String key) {
    final obj = buildObject(key);
    addObject(obj, key);
    return obj;
  }

  T buildObject(String key) {
    if (key.isEmpty) throw ArgumentError('Cannot build empty name');
    final obj = factory.newInstance() as T;
    obj.setName(key);
    return obj;
  }

  void renameObject(String key, T item) {
    forgetObject(item);
    addObject(item, key);
  }

  bool forgetObject(T item) {
    final lKey = item.getKeyName().toLowerCase();
    final dups = _duplicates[lKey];
    if (_active[lKey] == item) {
      if (dups == null || dups.isEmpty) {
        _active.remove(lKey);
      } else {
        _active[lKey] = dups.removeAt(0);
        if (dups.isEmpty) _duplicates.remove(lKey);
      }
    } else {
      dups?.remove(item);
    }
    return true;
  }

  bool containsObjectKeyed(String key) => _active.containsKey(key.toLowerCase());

  List<T> getAllObjects() => List.unmodifiable(_active.values);

  T? constructNowIfNecessary(String key) {
    if (!containsObjectKeyed(key)) {
      return constructObject(key);
    }
    return getActiveObject(key);
  }

  void constructIfNecessary(String key) => _deferred.add(key);

  void buildDeferredObjects() {
    for (final key in _deferred) {
      if (!containsObjectKeyed(key)) constructObject(key);
    }
    _deferred.clear();
  }

  // ---- Reference resolution ----

  bool resolveReferences(dynamic validator) {
    bool ok = _resolvePrimitiveReferences(validator);
    ok &= _resolveGroupReferences();
    _isResolved = true;
    return ok;
  }

  bool _resolvePrimitiveReferences(dynamic validator) {
    bool ok = true;
    for (final entry in _referenced.entries) {
      ok &= factory.resolve(this, entry.key, entry.value, validator) as bool;
    }
    return ok;
  }

  bool _resolveGroupReferences() {
    for (final obj in getAllObjects()) {
      _allRef?.addResolution(obj);
      for (final entry in _typeReferences.entries) {
        final types = entry.key.split('.');
        if (types.every((t) => obj.isType(t))) {
          entry.value.addResolution(obj);
        }
      }
    }
    return true;
  }

  bool validate(dynamic validator) => true; // TODO: full validation

  // ---- Listener support ----

  void addUnconstructedListener(UnconstructedListener listener) {
    _listeners.add(listener);
  }

  void removeUnconstructedListener(UnconstructedListener listener) {
    _listeners.remove(listener);
  }

  void fireUnconstuctedEvent(CDOMReference ref) {
    for (final l in _listeners) {
      l.unconstructedReferenceFound(ref);
    }
  }

  int get constructedObjectCount => _active.length;

  dynamic get factory_ => factory;

  String getReferenceDescription() => factory.getReferenceDescription() as String;

  List<CDOMReference<T>> getAllReferences() {
    final result = <CDOMReference<T>>[];
    if (_allRef != null) result.add(_allRef!);
    result.addAll(_typeReferences.values);
    result.addAll(_referenced.values);
    return result;
  }

  void injectConstructed(AbstractReferenceManufacturer<T> arm) {
    for (final entry in arm._active.entries) {
      addObject(entry.value, entry.key);
    }
  }

  void addDerivativeObject(T obj) {}

  // ---- FormatManager interface ----

  T convert(String key) {
    final obj = getObject(key);
    if (obj == null) throw ArgumentError('No object with key: $key');
    return obj;
  }

  dynamic convertIndirect(String key) => getReference(key);

  String get identifierType => factory.getReferenceDescription() as String;

  Type get managedClass => factory.getReferenceClass() as Type;

  String unconvert(T obj) => obj.getKeyName();
}

/// Listener notified when a reference to an unconstructed object is found.
abstract interface class UnconstructedListener {
  void unconstructedReferenceFound(CDOMReference ref);
}
