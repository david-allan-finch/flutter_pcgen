import '../cdom/enumeration/list_key.dart';
import 'pcobject.dart';

// Represents a character race.
final class Race extends PObject {
  bool isAdvancementUnlimited() {
    final hda = getListFor<int>(ListKey.getConstant<int>('HITDICE_ADVANCEMENT'));
    return hda == null || hda.last == 0x7fffffff; // Integer.MAX_VALUE
  }

  @override
  int get hashCode => getKeyName().hashCode;

  int maxHitDiceAdvancement() {
    final hda = getListFor<int>(ListKey.getConstant<int>('HITDICE_ADVANCEMENT'));
    if (hda == null || hda.isEmpty) return 0;
    return hda.reduce((a, b) => a > b ? a : b);
  }
}
