import 'list_facade.dart';

/// Utility factory for [ListFacade] instances.
final class ListFacades {
  ListFacades._();

  static final ListFacade<Never> _emptyList = _EmptyListFacade();

  static ListFacade<T> emptyList<T>() => _emptyList as ListFacade<T>;

  /// Wraps a [ListFacade] as a standard Dart [List] (read-only view).
  static List<T> wrap<T>(ListFacade<T> list) => _ListFacadeWrapper(list);
}

class _EmptyListFacade implements ListFacade<Never> {
  @override
  void addListListener(void Function(ListChangeEvent<Never>) listener) {}
  @override
  void removeListListener(void Function(ListChangeEvent<Never>) listener) {}
  @override
  Never getElementAt(int index) => throw RangeError.index(index, this);
  @override
  int getSize() => 0;
  @override
  bool isEmpty() => true;
  @override
  bool containsElement(Never element) => false;
  @override
  Iterator<Never> get iterator => const _EmptyIterator();
}

class _EmptyIterator<E> implements Iterator<E> {
  const _EmptyIterator();
  @override
  E get current => throw StateError('No element');
  @override
  bool moveNext() => false;
}

class _ListFacadeWrapper<T> extends Iterable<T> implements List<T> {
  final ListFacade<T> _facade;
  _ListFacadeWrapper(this._facade);

  @override
  T operator [](int index) => _facade.getElementAt(index);

  @override
  int get length => _facade.getSize();

  @override
  Iterator<T> get iterator => _FacadeIterator(_facade);

  // Mutation methods are not supported on this read-only view.
  @override
  void operator []=(int index, T value) =>
      throw UnsupportedError('read-only view');
  @override
  void add(T value) => throw UnsupportedError('read-only view');
  @override
  void addAll(Iterable<T> iterable) => throw UnsupportedError('read-only view');
  @override
  set length(int newLength) => throw UnsupportedError('read-only view');
  @override
  void insert(int index, T element) =>
      throw UnsupportedError('read-only view');
  @override
  void insertAll(int index, Iterable<T> iterable) =>
      throw UnsupportedError('read-only view');
  @override
  bool remove(Object? value) => throw UnsupportedError('read-only view');
  @override
  T removeAt(int index) => throw UnsupportedError('read-only view');
  @override
  T removeLast() => throw UnsupportedError('read-only view');
  @override
  void removeRange(int start, int end) =>
      throw UnsupportedError('read-only view');
  @override
  void removeWhere(bool Function(T element) test) =>
      throw UnsupportedError('read-only view');
  @override
  void retainWhere(bool Function(T element) test) =>
      throw UnsupportedError('read-only view');
  @override
  void clear() => throw UnsupportedError('read-only view');
  @override
  void fillRange(int start, int end, [T? fillValue]) =>
      throw UnsupportedError('read-only view');
  @override
  void replaceRange(int start, int end, Iterable<T> replacements) =>
      throw UnsupportedError('read-only view');
  @override
  void setAll(int index, Iterable<T> iterable) =>
      throw UnsupportedError('read-only view');
  @override
  void setRange(int start, int end, Iterable<T> iterable,
          [int skipCount = 0]) =>
      throw UnsupportedError('read-only view');
  @override
  void sort([Comparator<T>? compare]) =>
      throw UnsupportedError('read-only view');
  @override
  void shuffle([dynamic random]) => throw UnsupportedError('read-only view');

  // Forwarded read methods from List.
  @override
  List<T> operator +(List<T> other) =>
      [...List.generate(length, (i) => this[i]), ...other];
  @override
  Map<int, T> asMap() => {for (int i = 0; i < length; i++) i: this[i]};
  @override
  List<T> sublist(int start, [int? end]) =>
      List.generate((end ?? length) - start, (i) => this[start + i]);
  @override
  Iterable<T> getRange(int start, int end) => sublist(start, end);
  @override
  int indexOf(Object? element, [int start = 0]) {
    for (int i = start; i < length; i++) {
      if (this[i] == element) return i;
    }
    return -1;
  }
  @override
  int indexWhere(bool Function(T element) test, [int start = 0]) {
    for (int i = start; i < length; i++) {
      if (test(this[i])) return i;
    }
    return -1;
  }
  @override
  int lastIndexOf(Object? element, [int? start]) {
    final end = start ?? length - 1;
    for (int i = end; i >= 0; i--) {
      if (this[i] == element) return i;
    }
    return -1;
  }
  @override
  int lastIndexWhere(bool Function(T element) test, [int? start]) {
    final end = start ?? length - 1;
    for (int i = end; i >= 0; i--) {
      if (test(this[i])) return i;
    }
    return -1;
  }
  @override
  T get first => this[0];
  @override
  T get last => this[length - 1];
  @override
  T get single {
    if (length != 1) throw StateError('Not exactly one element');
    return this[0];
  }
  @override
  List<T> toList({bool growable = true}) =>
      List.generate(length, (i) => this[i], growable: growable);
  @override
  Set<T> toSet() => {for (int i = 0; i < length; i++) this[i]};
  @override
  bool get isEmpty => length == 0;
  @override
  bool get isNotEmpty => length > 0;
  @override
  Iterable<T> get reversed => List.generate(length, (i) => this[length - 1 - i]);
  @override
  bool contains(Object? element) {
    for (int i = 0; i < length; i++) {
      if (this[i] == element) return true;
    }
    return false;
  }
}

class _FacadeIterator<T> implements Iterator<T> {
  final ListFacade<T> _facade;
  int _index = -1;

  _FacadeIterator(this._facade);

  @override
  T get current => _facade.getElementAt(_index);

  @override
  bool moveNext() {
    _index++;
    return _index < _facade.getSize();
  }
}
