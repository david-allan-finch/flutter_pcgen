import 'dart:collection' show SetBase;

// A Set backed by a List, maintaining insertion order and using equals for comparison.
class ListSet<T> extends SetBase<T> {
  final List<T> _list = [];

  @override
  bool add(T value) {
    if (_list.contains(value)) return false;
    _list.add(value);
    return true;
  }

  @override
  bool contains(Object? element) => _list.contains(element);

  @override
  bool remove(Object? value) => _list.remove(value);

  @override
  int get length => _list.length;

  @override
  bool get isEmpty => _list.isEmpty;

  @override
  bool get isNotEmpty => _list.isNotEmpty;

  @override
  Iterator<T> get iterator => _list.iterator;

  @override
  Set<T> toSet() => Set<T>.from(_list);

  @override
  void clear() => _list.clear();

  @override
  void addAll(Iterable<T> elements) => elements.forEach(add);

  @override
  void removeAll(Iterable<Object?> elements) => elements.forEach(remove);

  @override
  bool containsAll(Iterable<Object?> other) => other.every(contains);

  @override
  Set<T> intersection(Set<Object?> other) =>
      ListSet<T>()..addAll(_list.where((e) => other.contains(e)));

  @override
  Set<T> union(Set<T> other) => ListSet<T>()..addAll(_list)..addAll(other);

  @override
  Set<T> difference(Set<Object?> other) =>
      ListSet<T>()..addAll(_list.where((e) => !other.contains(e)));

  @override
  void retainAll(Iterable<Object?> elements) {
    _list.retainWhere((e) => elements.contains(e));
  }

  @override
  void retainWhere(bool Function(T element) test) => _list.retainWhere(test);

  @override
  void removeWhere(bool Function(T element) test) => _list.removeWhere(test);

  @override
  T get first => _list.first;

  @override
  T get last => _list.last;

  @override
  T get single => _list.single;

  @override
  T elementAt(int index) => _list[index];

  @override
  T? lookup(Object? object) => _list.cast<T?>().firstWhere(
      (e) => e == object, orElse: () => null);

  @override
  List<T> toList({bool growable = true}) => List<T>.from(_list, growable: growable);

  @override
  Iterable<T> where(bool Function(T element) test) => _list.where(test);

  @override
  Iterable<E> map<E>(E Function(T e) f) => _list.map(f);

  @override
  Iterable<E> expand<E>(Iterable<E> Function(T element) f) => _list.expand(f);

  @override
  bool every(bool Function(T element) test) => _list.every(test);

  @override
  bool any(bool Function(T element) test) => _list.any(test);

  @override
  void forEach(void Function(T element) f) => _list.forEach(f);

  @override
  T reduce(T Function(T value, T element) combine) => _list.reduce(combine);

  @override
  E fold<E>(E initialValue, E Function(E previousValue, T element) combine) =>
      _list.fold(initialValue, combine);

  @override
  String join([String separator = '']) => _list.join(separator);

  @override
  T firstWhere(bool Function(T element) test, {T Function()? orElse}) =>
      _list.firstWhere(test, orElse: orElse!);

  @override
  T lastWhere(bool Function(T element) test, {T Function()? orElse}) =>
      _list.lastWhere(test, orElse: orElse!);

  @override
  T singleWhere(bool Function(T element) test, {T Function()? orElse}) =>
      _list.singleWhere(test, orElse: orElse!);

  @override
  Iterable<T> skip(int count) => _list.skip(count);

  @override
  Iterable<T> skipWhile(bool Function(T value) test) => _list.skipWhile(test);

  @override
  Iterable<T> take(int count) => _list.take(count);

  @override
  Iterable<T> takeWhile(bool Function(T value) test) => _list.takeWhile(test);

  @override
  Iterable<T> followedBy(Iterable<T> other) => _list.followedBy(other);
}
