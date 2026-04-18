// A list that can be written to until it is "locked", after which it becomes read-only.
class WriteOnceReadManyList<T> implements List<T> {
  final List<T> _list;
  bool _locked = false;

  WriteOnceReadManyList(List<T> initial) : _list = initial;

  void lock() => _locked = true;

  void _checkWrite() {
    if (_locked) throw StateError('List is locked for writing');
  }

  @override
  void add(T value) { _checkWrite(); _list.add(value); }

  @override
  void addAll(Iterable<T> iterable) { _checkWrite(); _list.addAll(iterable); }

  @override
  bool remove(Object? value) { _checkWrite(); return _list.remove(value); }

  @override
  void clear() { _checkWrite(); _list.clear(); }

  @override
  int get length => _list.length;

  @override
  set length(int newLength) { _checkWrite(); _list.length = newLength; }

  @override
  T operator [](int index) => _list[index];

  @override
  void operator []=(int index, T value) { _checkWrite(); _list[index] = value; }

  @override
  bool get isEmpty => _list.isEmpty;

  @override
  bool get isNotEmpty => _list.isNotEmpty;

  @override
  Iterator<T> get iterator => _list.iterator;

  // Delegate all other List methods to _list
  @override
  T get first => _list.first;

  @override
  set first(T value) { _checkWrite(); _list.first = value; }

  @override
  T get last => _list.last;

  @override
  set last(T value) { _checkWrite(); _list.last = value; }

  @override
  T get single => _list.single;

  @override
  bool contains(Object? element) => _list.contains(element);

  @override
  int indexOf(Object? element, [int start = 0]) => _list.indexOf(element as T, start);

  @override
  int lastIndexOf(Object? element, [int? start]) => _list.lastIndexOf(element as T, start);

  @override
  List<T> sublist(int start, [int? end]) => _list.sublist(start, end);

  @override
  List<T> toList({bool growable = true}) => List<T>.from(_list, growable: growable);

  @override
  Set<T> toSet() => Set<T>.from(_list);

  @override
  void insert(int index, T element) { _checkWrite(); _list.insert(index, element); }

  @override
  void insertAll(int index, Iterable<T> iterable) { _checkWrite(); _list.insertAll(index, iterable); }

  @override
  void removeAt(int index) { _checkWrite(); _list.removeAt(index); }

  @override
  T removeLast() { _checkWrite(); return _list.removeLast(); }

  @override
  void removeRange(int start, int end) { _checkWrite(); _list.removeRange(start, end); }

  @override
  void removeWhere(bool Function(T element) test) { _checkWrite(); _list.removeWhere(test); }

  @override
  void retainWhere(bool Function(T element) test) { _checkWrite(); _list.retainWhere(test); }

  @override
  void sort([Comparator<T>? compare]) { _checkWrite(); _list.sort(compare); }

  @override
  void shuffle([dynamic random]) { _checkWrite(); _list.shuffle(random); }

  @override
  void setAll(int index, Iterable<T> iterable) { _checkWrite(); _list.setAll(index, iterable); }

  @override
  void setRange(int start, int end, Iterable<T> iterable, [int skipCount = 0]) {
    _checkWrite(); _list.setRange(start, end, iterable, skipCount);
  }

  @override
  void fillRange(int start, int end, [T? fill]) { _checkWrite(); _list.fillRange(start, end, fill); }

  @override
  void replaceRange(int start, int end, Iterable<T> newContents) {
    _checkWrite(); _list.replaceRange(start, end, newContents);
  }

  @override
  Iterable<T> getRange(int start, int end) => _list.getRange(start, end);

  @override
  int indexWhere(bool Function(T element) test, [int start = 0]) => _list.indexWhere(test, start);

  @override
  int lastIndexWhere(bool Function(T element) test, [int? start]) => _list.lastIndexWhere(test, start);

  @override
  Map<int, T> asMap() => _list.asMap();

  @override
  List<T> operator +(List<T> other) => _list + other;

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

  @override
  List<E> cast<E>() => _list.cast<E>();

  @override
  String toString() => _list.toString();
}
