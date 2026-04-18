import '../../base/util/format_manager.dart';
import '../../base/util/indirect.dart';
import 'user_content.dart';

// DefaultVarValue is a shell object used during LST loading to carry the
// default value definition for a variable format. Values are not used at
// runtime; they are consumed by the token/loader system.
class DefaultVarValue extends UserContent {
  FormatManager<dynamic>? _formatManager;
  Indirect<dynamic>? _indirect;

  @override
  String getDisplayName() => getKeyName();

  void setFormatManager(FormatManager<dynamic> fmtManager) =>
      _formatManager = fmtManager;

  FormatManager<dynamic>? getFormatManager() => _formatManager;

  void setIndirect(Indirect<dynamic> indirect) => _indirect = indirect;

  Indirect<dynamic>? getIndirect() => _indirect;
}
