import '../cdom/base/loadable.dart';
import '../cdom/base/sort_key_required.dart';

// Holds page-size and margin info for a paper type used in character output.
final class PaperInfo implements Loadable, SortKeyRequired {
  static const int name = 0;
  static const int height = 1;
  static const int width = 2;
  static const int topMargin = 3;
  static const int bottomMargin = 4;
  static const int leftMargin = 5;
  static const int rightMargin = 6;

  final List<String?> _paperInfo = List.filled(7, null);
  String? _infoName;
  String? _sortKey;
  String? _sourceUri;

  void setPaperInfo(int infoType, String info) {
    if (!_validIndex(infoType)) {
      throw RangeError('invalid index: $infoType');
    }
    _paperInfo[infoType] = info;
  }

  String? getPaperInfo(int infoType) =>
      _validIndex(infoType) ? _paperInfo[infoType] : null;

  static bool _validIndex(int index) => index >= 0 && index <= 6;

  @override
  String? getSourceURI() => _sourceUri;

  @override
  void setSourceURI(String source) => _sourceUri = source;

  @override
  void setName(String n) {
    _infoName = n;
    _paperInfo[0] = n;
  }

  @override
  String getDisplayName() => _infoName ?? '';

  @override
  String getKeyName() => _infoName ?? '';

  @override
  bool isInternal() => false;

  @override
  bool isType(String type) => false;

  void setSortKey(String value) => _sortKey = value;

  @override
  String getSortKey() => _sortKey ?? '';
}
