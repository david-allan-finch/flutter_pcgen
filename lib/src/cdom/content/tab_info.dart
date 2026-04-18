import '../base/loadable.dart';

// Defines display settings for a UI tab in the character sheet.
class TabInfo implements Loadable {
  String? _sourceURI;
  String _tabID = '';
  String _tabName = '';
  bool _isVisible = true;
  String? _helpFilePath;
  String? _helpContext;
  Set<int>? _hiddenColumns;

  @override
  String? getSourceURI() => _sourceURI;

  @override
  void setSourceURI(String? source) { _sourceURI = source; }

  @override
  void setName(String name) { _tabID = name; }

  void setTab(String tab) { _tabID = tab; }
  String getTab() => _tabID;

  @override
  String? getDisplayName() => _tabID.isNotEmpty ? _tabID : null;

  @override
  String? getKeyName() => getDisplayName();

  @override
  bool isInternal() => false;

  @override
  bool isType(String type) => false;

  void setTabName(String name) { _tabName = name; }
  String getTabName() => _tabName;
  String getResolvedName() => _tabName; // i18n lookup omitted

  void setVisible(bool visible) { _isVisible = visible; }
  bool isVisible() => _isVisible;

  void clearHiddenColumns() { _hiddenColumns?.clear(); }

  void hideColumn(int column) {
    _hiddenColumns ??= {};
    _hiddenColumns!.add(column);
  }

  bool isColumnVisible(int column) =>
      _hiddenColumns == null || !_hiddenColumns!.contains(column);

  Set<int> getHiddenColumns() =>
      _hiddenColumns == null ? const {} : Set.unmodifiable(_hiddenColumns!);

  void setHelpContext(String? path) { _helpFilePath = path; }
  String? getHelpContext() => _helpFilePath;

  void setRawHelpContext(String? value) { _helpContext = value; }
  String? getRawHelpContext() => _helpContext;
}
