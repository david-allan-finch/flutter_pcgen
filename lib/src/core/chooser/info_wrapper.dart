// Copyright (c) James Dempsey, 2013.
//
// Translation of pcgen.core.chooser.InfoWrapper

/// General-purpose container that wraps any object as an InfoFacade-like value
/// for use in chooser lists.
class InfoWrapper {
  static const String _sortableWidth = '0000000000.00000';

  final Object obj;

  InfoWrapper(this.obj);

  @override
  String toString() => obj.toString();

  String getSource() => '';
  String getSourceForNodeDisplay() => '';
  String getKeyName() => obj.toString();
  bool isNamePI() => false;
  Object getObj() => obj;

  String getType() {
    // If obj is a CDOMObject, join its TYPE list with ".".
    try {
      final types = (obj as dynamic).getSafeListFor('TYPE') as List?;
      return types?.join('.') ?? '';
    } catch (_) {
      return '';
    }
  }

  String getSortKey() {
    if (obj is num) {
      final d = (obj as num).toDouble() + 100000.0;
      return d.toStringAsFixed(5).padLeft(_sortableWidth.length, '0');
    }
    return toString();
  }
}
