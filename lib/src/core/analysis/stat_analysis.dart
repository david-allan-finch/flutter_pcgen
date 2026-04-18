import '../pc_stat.dart';
import '../player_character.dart';

abstract final class StatAnalysis {
  // Retrieve a correctly calculated attribute value where one or more types are excluded.
  static int getPartialStatFor(PlayerCharacter aPC, PCStat stat, bool useTemp, bool useEquip) {
    if (aPC.hasNonStatStat(stat)) return 10;
    if (!aPC.hasUnlockedStat(stat)) {
      final val = aPC.getLockedStat(stat);
      if (val != null) return val.toInt();
    }
    return aPC.getPartialStatFor(stat, useTemp, useEquip);
  }
}
