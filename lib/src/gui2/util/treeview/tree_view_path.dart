//
// Copyright 2008 (C) Connor Petty <mistercpp2000@gmail.com>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
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
