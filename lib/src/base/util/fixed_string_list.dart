// An unmodifiable fixed-size list of strings.
class FixedStringList {
  final List<String> _list;

  FixedStringList(List<String> list) : _list = List.unmodifiable(list);

  String operator [](int index) => _list[index];

  int get length => _list.length;

  bool get isEmpty => _list.isEmpty;

  List<String> toList() => List<String>.from(_list);

  @override
  String toString() => _list.toString();

  @override
  bool operator ==(Object other) =>
      other is FixedStringList && _listEquals(_list, other._list);

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(_list);
}
