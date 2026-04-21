// Copyright (c) Thomas Parker, 2009.
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.

// Translation of pcgen.cdom.facet.FacetLibrary

/// FacetLibrary is a container for the Facets that process information about
/// PlayerCharacters.
///
/// Spring IoC wiring is replaced by a simple registry map. The getFacet method
/// attempts to look up an already-registered facet instance, or instantiates a
/// stub if none is available.
final class FacetLibrary {
  FacetLibrary._();

  static final Map<Type, dynamic> _facets = {};
  static final Map<String, dynamic> _namedFacets = {};

  /// Returns (and caches) the facet for the given runtime [type].
  static T getFacetByType<T>(Type type, T Function() factory) {
    return _facets.putIfAbsent(type, factory) as T;
  }

  /// Returns (and caches) the facet for the given string [name].
  static dynamic getFacetByName(String name) {
    return _namedFacets.putIfAbsent(name, () => _StubFacet(name));
  }

  /// Returns (and caches) the facet for type [T].
  static T getFacet<T>() {
    return _facets.putIfAbsent(T, () => _StubFacet(T.toString())) as T;
  }

  /// Registers a facet instance under both its [Type] key and [name] key.
  static void register<T>(Type type, String name, T instance) {
    _facets[type] = instance;
    _namedFacets[name] = instance;
  }
}

/// Stub facet object that accepts any method call without crashing.
/// Used for facets not yet translated.
class _StubFacet {
  final String _name;
  _StubFacet(this._name);

  @override
  String toString() => '_StubFacet($_name)';

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
