// Translation of pcgen.system.RecentFileList

import '../facade/util/abstract_list_facade.dart';

/// Maintains a bounded list of recently-opened character files.
class RecentFileList extends AbstractListFacade<String> {
  final int maxSize;
  final List<String> _files = [];

  RecentFileList({this.maxSize = 10});

  void addRecentFile(String path) {
    _files.remove(path);
    _files.insert(0, path);
    if (_files.length > maxSize) _files.removeLast();
    fireListChangedEvent();
  }

  void removeRecentFile(String path) {
    _files.remove(path);
    fireListChangedEvent();
  }

  @override
  String getElementAt(int index) => _files[index];

  @override
  int getSize() => _files.length;
}
