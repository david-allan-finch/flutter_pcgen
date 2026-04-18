// Copyright (c) Thomas Parker, 2010.
//
// Translation of pcgen.cdom.facet.ConditionallyGrantedAbilityFacet

import '../enumeration/char_id.dart';
import '../helper/cn_ability_selection.dart';
import 'base/abstract_list_facet.dart';
import 'conditional_ability_facet.dart';

/// Tracks the [CNAbilitySelection] objects that the PC currently qualifies for
/// (the "active" subset of [ConditionalAbilityFacet]). Uses identity equality
/// to avoid issues with Ability.equals behavior.
class ConditionallyGrantedAbilityFacet
    extends AbstractListFacet<CharID, CNAbilitySelection> {
  late ConditionalAbilityFacet conditionalAbilityFacet;

  // Reentrancy guard for update().
  bool _entered = false;
  bool _redo = false;

  /// Performs a global update of conditionally granted abilities for [id].
  void update(CharID id) {
    if (_entered) {
      _redo = true;
      return;
    }
    _entered = true;

    final current = getSet(id).toList();
    final qualified = conditionalAbilityFacet.getQualifiedSet(id);

    final toRemove = current.where((c) => !qualified.contains(c)).toList();
    final toAdd = qualified.where((q) => !current.contains(q)).toList();

    for (final cas in toRemove) {
      if (!conditionalAbilityFacet.isQualified(id, cas) && contains(id, cas)) {
        remove(id, cas);
      }
    }
    for (final cas in toAdd) {
      if (conditionalAbilityFacet.isQualified(id, cas) && !contains(id, cas)) {
        add(id, cas);
      }
    }

    _entered = false;
    if (_redo) {
      _redo = false;
      update(id);
    }
  }

  @override
  Set<CNAbilitySelection> getComponentSet() => _IdentitySet();
}

/// A Set that uses identity (identical()) rather than equality for membership.
class _IdentitySet<T> implements Set<T> {
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

  @override
  bool get isEmpty => _list.isEmpty;

  @override
  bool get isNotEmpty => _list.isNotEmpty;

  @override
  Set<T> toSet() => _IdentitySet<T>().._list.addAll(_list);

  // Delegate remaining Set methods to a temporary LinkedHashSet for simplicity.
  Set<T> _delegate() => Set.identity()..addAll(_list);

  @override
  T get first => _list.first;
  @override
  T get last => _list.last;
  @override
  T get single => _list.single;
  @override
  T elementAt(int index) => _list[index];
  @override
  bool every(bool Function(T) test) => _list.every(test);
  @override
  bool any(bool Function(T) test) => _list.any(test);
  @override
  Iterable<T> where(bool Function(T) test) => _list.where(test);
  @override
  void forEach(void Function(T) action) => _list.forEach(action);
  @override
  List<T> toList({bool growable = true}) => _list.toList(growable: growable);
  @override
  T firstWhere(bool Function(T) test, {T Function()? orElse}) =>
      _list.firstWhere(test, orElse: orElse);
  @override
  T lastWhere(bool Function(T) test, {T Function()? orElse}) =>
      _list.lastWhere(test, orElse: orElse);
  @override
  T singleWhere(bool Function(T) test, {T Function()? orElse}) =>
      _list.singleWhere(test, orElse: orElse);
  @override
  T reduce(T Function(T, T) combine) => _list.reduce(combine);
  @override
  E fold<E>(E init, E Function(E, T) combine) => _list.fold(init, combine);
  @override
  Iterable<E> map<E>(E Function(T) f) => _list.map(f);
  @override
  Iterable<E> expand<E>(Iterable<E> Function(T) f) => _list.expand(f);
  @override
  Iterable<T> take(int n) => _list.take(n);
  @override
  Iterable<T> takeWhile(bool Function(T) test) => _list.takeWhile(test);
  @override
  Iterable<T> skip(int n) => _list.skip(n);
  @override
  Iterable<T> skipWhile(bool Function(T) test) => _list.skipWhile(test);
  @override
  String join([String sep = '']) => _list.join(sep);
  @override
  bool containsAll(Iterable<Object?> other) =>
      other.every((e) => _list.any((x) => identical(x, e)));
  @override
  Set<T> intersection(Set<Object?> other) =>
      _IdentitySet<T>().._list.addAll(_list.where((e) => other.contains(e)));
  @override
  Set<T> difference(Set<Object?> other) =>
      _IdentitySet<T>().._list.addAll(_list.where((e) => !other.contains(e)));
  @override
  Set<T> union(Set<T> other) =>
      _IdentitySet<T>().._list.addAll([..._list, ...other]);
  @override
  void addAll(Iterable<T> elements) => elements.forEach(add);
  @override
  void removeAll(Iterable<Object?> elements) =>
      elements.forEach(remove);
  @override
  void retainAll(Iterable<Object?> elements) =>
      _list.retainWhere((e) => elements.any((x) => identical(x, e)));
  @override
  void removeWhere(bool Function(T) test) => _list.removeWhere(test);
  @override
  void retainWhere(bool Function(T) test) => _list.retainWhere(test);
  @override
  T? lookup(Object? object) =>
      _list.cast<T?>().firstWhere((e) => identical(e, object), orElse: () => null);
  @override
  void clear() => _list.clear();
  @override
  Set<R> cast<R>() => _delegate().cast<R>();
  @override
  Iterable<T> followedBy(Iterable<T> other) => _list.followedBy(other);
  @override
  Iterable<T> whereType<T2>() => _list.whereType<T2>() as Iterable<T>;
}
