// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.CategorizedAbilityFacet

import 'package:flutter_pcgen/src/cdom/base/category.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/nature.dart';
import 'package:flutter_pcgen/src/core/ability.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_data_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_event.dart';

/// Tracks [Ability] objects for a Player Character organized by [Category] and
/// [Nature]. Uses identity semantics for the inner set (to handle cloned
/// Ability objects correctly).
class CategorizedAbilityFacet extends AbstractDataFacet<CharID, Ability> {
  void add(CharID id, Category<Ability> cat, Nature nat, Ability obj) {
    final isNew = _ensureCachedSet(id, cat, nat);
    if (_getCachedSet(id, cat, nat)!.add(obj) || isNew) {
      fireDataFacetChangeEvent(id, obj, DataFacetChangeEvent.dataAdded);
    }
  }

  void addAll(CharID id, Category<Ability> cat, Nature nature,
      Iterable<Ability> abilities) {
    for (final a in abilities) {
      add(id, cat, nature, a);
    }
  }

  void remove(CharID id, Category<Ability> cat, Nature nat, Ability obj) {
    final cached = _getCachedSet(id, cat, nat);
    if (cached != null && cached.remove(obj)) {
      fireDataFacetChangeEvent(id, obj, DataFacetChangeEvent.dataRemoved);
    }
  }

  Set<Ability> get(CharID id, Category<Ability> cat, Nature nat) {
    final set = _getCachedSet(id, cat, nat);
    if (set == null) return const {};
    return Set.unmodifiable(set);
  }

  bool contains(CharID id, Category<Ability> cat, Nature nat, Ability a) {
    final set = _getCachedSet(id, cat, nat);
    if (set == null) return false;
    if (set.contains(a)) return true;
    // Fallback for cloned abilities with same key
    return set.any((ab) => ab == a);
  }

  void removeAll(CharID id, [Category<Ability>? cat, Nature? nature]) {
    if (cat == null && nature == null) {
      _removeAllEntries(id);
    } else if (cat != null && nature == null) {
      _removeByCat(id, cat);
    } else if (cat != null && nature != null) {
      _removeByCatAndNature(id, cat, nature);
    } else {
      _removeByNature(id, nature!);
    }
  }

  void _removeAllEntries(CharID id) {
    final catMap =
        removeCache(id) as Map<Category<Ability>, Map<Nature, Set<Ability>>>?;
    if (catMap == null) return;
    for (final natMap in catMap.values) {
      _processRemoveNatureMap(id, natMap);
    }
  }

  void _removeByCat(CharID id, Category<Ability> cat) {
    final catMap = _getCachedMap(id);
    if (catMap == null) return;
    final natMap = catMap.remove(cat);
    if (natMap != null) _processRemoveNatureMap(id, natMap);
  }

  void _removeByCatAndNature(CharID id, Category<Ability> cat, Nature nature) {
    final catMap = _getCachedMap(id);
    if (catMap == null) return;
    final natMap = catMap.remove(cat);
    if (natMap != null) {
      final abilitySet = natMap[nature];
      if (abilitySet != null) _processRemoveAbilitySet(id, abilitySet);
    }
  }

  void _removeByNature(CharID id, Nature nature) {
    final catMap = _getCachedMap(id);
    if (catMap == null) return;
    for (final natMap in catMap.values) {
      final abilitySet = natMap.remove(nature);
      if (abilitySet != null) _processRemoveAbilitySet(id, abilitySet);
    }
  }

  void _processRemoveNatureMap(
      CharID id, Map<Nature, Set<Ability>> natMap) {
    for (final abilitySet in natMap.values) {
      _processRemoveAbilitySet(id, abilitySet);
    }
  }

  void _processRemoveAbilitySet(CharID id, Set<Ability> abilitySet) {
    for (final a in abilitySet) {
      fireDataFacetChangeEvent(id, a, DataFacetChangeEvent.dataRemoved);
    }
  }

  Set<Category<Ability>> getCategories(CharID id) {
    final map = _getCachedMap(id);
    if (map == null) return const {};
    return Set.unmodifiable(map.keys.toSet());
  }

  @override
  void copyContents(CharID source, CharID copy) {
    final map = _getCachedMap(source);
    if (map == null) return;
    for (final catEntry in map.entries) {
      for (final natEntry in catEntry.value.entries) {
        _ensureCachedSet(copy, catEntry.key, natEntry.key);
        _getCachedSet(copy, catEntry.key, natEntry.key)!
            .addAll(natEntry.value);
      }
    }
  }

  bool _ensureCachedSet(CharID id, Category<Ability> cat, Nature nat) {
    bool isNew = false;
    var catMap = _getCachedMap(id);
    if (catMap == null) {
      isNew = true;
      catMap = <Category<Ability>, Map<Nature, Set<Ability>>>{};
      setCache(id, catMap);
    }
    var natMap = catMap[cat];
    if (natMap == null) {
      isNew = true;
      natMap = <Nature, Set<Ability>>{};
      catMap[cat] = natMap;
    }
    if (!natMap.containsKey(nat)) {
      isNew = true;
      natMap[nat] = _IdentitySet<Ability>();
    }
    return isNew;
  }

  Set<Ability>? _getCachedSet(CharID id, Category<Ability> cat, Nature nat) =>
      _getCachedMap(id)?[cat]?[nat];

  Map<Category<Ability>, Map<Nature, Set<Ability>>>? _getCachedMap(CharID id) =>
      getCache(id) as Map<Category<Ability>, Map<Nature, Set<Ability>>>?;
}

/// Identity-based Set that uses [identical] for membership tests.
class _IdentitySet<T> extends _SetBase<T> {
  final List<T> _list = [];

  @override
  bool add(T value) {
    if (_list.any((e) => identical(e, value))) return false;
    _list.add(value);
    return true;
  }

  @override
  bool contains(Object? element) => _list.any((e) => identical(e, element));

  @override
  bool remove(Object? value) {
    final idx = _list.indexWhere((e) => identical(e, value));
    if (idx < 0) return false;
    _list.removeAt(idx);
    return true;
  }

  @override
  Iterator<T> get iterator => _list.iterator;

  @override
  int get length => _list.length;
}

abstract class _SetBase<T> implements Set<T> {
  @override
  bool get isEmpty => length == 0;
  @override
  bool get isNotEmpty => length != 0;
  @override
  Set<T> toSet() => Set<T>.from(this);
  @override
  T get first => iterator.moveNext() ? (iterator as dynamic).current : throw StateError('empty');
  @override
  T get last {
    T? last;
    for (final e in this) last = e;
    if (last == null) throw StateError('empty');
    return last;
  }
  @override
  T get single {
    final it = iterator;
    if (!it.moveNext()) throw StateError('empty');
    final v = (it as dynamic).current as T;
    if (it.moveNext()) throw StateError('too many');
    return v;
  }
  @override
  T elementAt(int index) => toList()[index];
  @override
  bool every(bool Function(T) test) => !any((e) => !test(e));
  @override
  bool any(bool Function(T) test) { for (final e in this) if (test(e)) return true; return false; }
  @override
  Iterable<T> where(bool Function(T) test) => toList().where(test);
  @override
  void forEach(void Function(T) action) { for (final e in this) action(e); }
  @override
  List<T> toList({bool growable = true}) {
    final list = <T>[];
    for (final e in this) list.add(e);
    return growable ? list : List.unmodifiable(list);
  }
  @override
  T firstWhere(bool Function(T) test, {T Function()? orElse}) {
    for (final e in this) if (test(e)) return e;
    if (orElse != null) return orElse();
    throw StateError('no element');
  }
  @override
  T lastWhere(bool Function(T) test, {T Function()? orElse}) {
    T? last; bool found = false;
    for (final e in this) if (test(e)) { last = e; found = true; }
    if (found) return last!;
    if (orElse != null) return orElse();
    throw StateError('no element');
  }
  @override
  T singleWhere(bool Function(T) test, {T Function()? orElse}) {
    T? found; bool hit = false;
    for (final e in this) { if (test(e)) { if (hit) throw StateError('too many'); found = e; hit = true; } }
    if (hit) return found!;
    if (orElse != null) return orElse();
    throw StateError('no element');
  }
  @override
  T reduce(T Function(T, T) combine) {
    final it = iterator; if (!it.moveNext()) throw StateError('empty');
    T value = (it as dynamic).current;
    while (it.moveNext()) value = combine(value, (it as dynamic).current);
    return value;
  }
  @override
  E fold<E>(E init, E Function(E, T) combine) { E v = init; for (final e in this) v = combine(v, e); return v; }
  @override
  Iterable<E> map<E>(E Function(T) f) => toList().map(f);
  @override
  Iterable<E> expand<E>(Iterable<E> Function(T) f) => toList().expand(f);
  @override
  Iterable<T> take(int n) => toList().take(n);
  @override
  Iterable<T> takeWhile(bool Function(T) test) => toList().takeWhile(test);
  @override
  Iterable<T> skip(int n) => toList().skip(n);
  @override
  Iterable<T> skipWhile(bool Function(T) test) => toList().skipWhile(test);
  @override
  String join([String sep = '']) => toList().join(sep);
  @override
  bool containsAll(Iterable<Object?> other) => other.every(contains);
  @override
  Set<T> intersection(Set<Object?> other) => where((e) => other.contains(e)).toSet();
  @override
  Set<T> difference(Set<Object?> other) => where((e) => !other.contains(e)).toSet();
  @override
  Set<T> union(Set<T> other) => {...toSet(), ...other};
  @override
  void addAll(Iterable<T> elements) { for (final e in elements) add(e); }
  @override
  void removeAll(Iterable<Object?> elements) { for (final e in elements) remove(e); }
  @override
  void retainAll(Iterable<Object?> elements) { toList().where((e) => !elements.contains(e)).forEach(remove); }
  @override
  void removeWhere(bool Function(T) test) { toList().where(test).forEach(remove); }
  @override
  void retainWhere(bool Function(T) test) { toList().where((e) => !test(e)).forEach(remove); }
  @override
  T? lookup(Object? object) { for (final e in this) if (e == object) return e; return null; }
  @override
  void clear() { toList().forEach(remove); }
  @override
  Set<R> cast<R>() => toSet().cast<R>();
  @override
  Iterable<T> followedBy(Iterable<T> other) => toList().followedBy(other);
  @override
  Iterable<T2> whereType<T2>() => toList().whereType<T2>();
}
