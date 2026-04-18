import '../../base/util/format_manager.dart';
import 'user_content.dart';

// A DatasetVariable is a variable in the formula system defined by data.
// Legal names must start with a letter followed by word characters only.
class DatasetVariable extends UserContent {
  static final _legalPattern = RegExp(r'^[A-Za-z]\w*$');

  FormatManager<dynamic>? _format;
  dynamic _scope; // PCGenScope — typed loosely to avoid circular imports

  @override
  String getDisplayName() => getKeyName();

  void setScope(dynamic scope) {
    if (scope == null) return;
    _scope = scope;
  }

  dynamic getScope() => _scope;

  static bool isLegalName(String proposedName) =>
      _legalPattern.hasMatch(proposedName);

  FormatManager<dynamic>? getFormat() => _format;

  void setFormat(FormatManager<dynamic> format) => _format = format;
}
