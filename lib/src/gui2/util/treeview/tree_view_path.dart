// Translation of pcgen.gui2.util.treeview.TreeViewPath

/// A path in a tree view, consisting of a sequence of path components.
class TreeViewPath<T> {
  final List<dynamic> _path;
  final T? _last;

  TreeViewPath(List<dynamic> path)
      : _path = List.unmodifiable(path),
        _last = path.isNotEmpty ? path.last as T? : null;

  TreeViewPath.of(dynamic element)
      : _path = [element],
        _last = element as T?;

  TreeViewPath<T> extend(dynamic element) {
    return TreeViewPath<T>([..._path, element]);
  }

  dynamic getPathComponent(int index) => _path[index];

  int get pathCount => _path.length;

  T? get last => _last;

  List<dynamic> get pathComponents => _path;

  @override
  bool operator ==(Object other) =>
      other is TreeViewPath && _listEquals(_path, other._path);

  @override
  int get hashCode => Object.hashAll(_path);

  bool _listEquals(List a, List b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
