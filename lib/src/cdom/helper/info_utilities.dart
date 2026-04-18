import '../base/cdom_object.dart';
import '../enumeration/map_key.dart';

// Utilities for INFOVARS token evaluation.
final class InfoUtilities {
  InfoUtilities._();

  static List<Object?> getInfoVars(dynamic id, CDOMObject cdo, String cis) {
    final vars = cdo.get(MapKey.infoVars, cis) as List<String>?;
    final varCount = vars?.length ?? 0;
    if (varCount == 0) return [];
    // resultFacet.getLocalVariable stub
    return List.filled(varCount, null);
  }
}
