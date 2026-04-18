import '../base/cdom_object.dart';
import '../enumeration/list_key.dart';
import '../enumeration/map_key.dart';
import '../../core/player_character.dart';
import 'info_boolean.dart';
import 'info_utilities.dart';

// Utilities for the ALLOW token — builds HTML text for allowed conditions.
final class AllowUtilities {
  AllowUtilities._();

  static String getAllowInfo(PlayerCharacter pc, CDOMObject cdo) {
    final allowItems = cdo.getListFor(ListKey.allow) as List<InfoBoolean>?;
    if (allowItems == null || allowItems.isEmpty) return '';

    final sb = StringBuffer();
    bool needSeparator = false;

    for (final infoBoolean in allowItems) {
      final info = cdo.get(MapKey.info, infoBoolean.getInfoName());
      if (info != null) {
        if (needSeparator) sb.write(' and ');
        needSeparator = true;
        final passes = pc.solve(infoBoolean.getFormula());
        if (!passes) sb.write('<i>');
        final infoVars =
            InfoUtilities.getInfoVars(pc.getCharID(), cdo, infoBoolean.getInfoName());
        sb.write(_htmlEscape(info.format(infoVars)));
        if (!passes) sb.write('</i>');
      }
    }
    return sb.toString();
  }

  static String _htmlEscape(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');
}
