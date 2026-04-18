// A list that uses identity (reference) equality for contains/remove checks.
class IdentityList<T> {
  final List<T> _list = [];

  void add(T item) => _list.add(item);

  bool contains(T item) => _list.any((e) => identical(e, item));

  bool remove(T item) {
    for (int i = 0; i < _list.length; i++) {
      if (identical(_list[i], item)) {
        _list.removeAt(i);
        return true;
      }
    }
    return false;
  }

  int get length => _list.length;
  bool get isEmpty => _list.isEmpty;
  T operator [](int index) => _list[index];
  List<T> toList() => List<T>.from(_list);
  Iterable<T> get iterable => _list;
}
