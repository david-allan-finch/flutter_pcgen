import '../../../cdom/base/cdom_object.dart';
import '../../../cdom/enumeration/list_key.dart';
import '../../player_character.dart';

// Utility methods for applying CDOMObject additions/kit choices to a PC.
final class AddObjectActions {
  AddObjectActions._();

  static void doBaseChecks(CDOMObject po, PlayerCharacter aPC) {
    aPC.setDirty(true);
    for (final kit in po.getSafeListFor(ListKey.kitChoice)) {
      kit.act(kit.driveChoice(aPC), po, aPC);
    }
  }

  static void globalChecks(CDOMObject po, PlayerCharacter aPC) {
    doBaseChecks(po, aPC);
    // CDOMObjectUtilities.addAdds(po, aPC);
    // CDOMObjectUtilities.checkRemovals(po, aPC);
    po.activateBonuses(aPC);
  }
}
