import '../cdom/content/cn_ability.dart';
import '../cdom/enumeration/list_key.dart';
import 'description.dart';
import 'player_character.dart';
import 'pcobject.dart';

final class BenefitFormatting {
  BenefitFormatting._();

  static String getBenefits(PlayerCharacter aPC, List<Object> objList) {
    if (objList.isEmpty) return '';
    final b = objList.first;
    final PObject sampleObject;
    if (b is PObject) {
      sampleObject = b;
    } else if (b is CNAbility) {
      sampleObject = b.getAbility();
    } else {
      return '';
    }
    final theBenefits =
        sampleObject.getListFor(ListKey.benefit) as List<Description>?;
    if (theBenefits == null) return '';
    final buf = StringBuffer();
    bool needSpace = false;
    for (final desc in theBenefits) {
      final str = desc.getDescription(aPC, objList);
      if (str.isNotEmpty) {
        if (needSpace) buf.write(' ');
        buf.write(str);
        needSpace = true;
      }
    }
    return buf.toString();
  }
}
