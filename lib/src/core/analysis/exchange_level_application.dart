import '../../../cdom/enumeration/integer_key.dart';
import '../../../cdom/enumeration/object_key.dart';
import '../../pc_class.dart';
import '../../player_character.dart';

// Handles the exchange of levels between classes via the EXCHANGELEVEL token.
final class ExchangeLevelApplication {
  ExchangeLevelApplication._();

  static void exchangeLevels(PlayerCharacter aPC, PCClass newcl) {
    final le = newcl.get(ObjectKey.exchangeLevel);
    if (le == null) return;

    try {
      final cl = le.getExchangeClass().get() as PCClass;
      final iMinLevel = le.getMinDonatingLevel() as int;
      int iMaxDonation = le.getMaxDonatedLevels() as int;
      final iLowest = le.getDonatingLowerLevelBound() as int;
      final aClass = aPC.getClassKeyed(cl.getKeyName());

      if (aClass != null) {
        final iNumOrigClassLevel = aPC.getLevel(aClass);
        if (iNumOrigClassLevel >= iMinLevel) {
          iMaxDonation =
              [iMaxDonation, iNumOrigClassLevel - iLowest + 1].reduce((a, b) => a < b ? a : b);
          if (newcl.hasMaxLevel()) {
            final limit = newcl.getSafe(IntegerKey.levelLimit) -
                aPC.getLevel(newcl);
            iMaxDonation = [iMaxDonation, limit].reduce((a, b) => a < b ? a : b);
          }

          if (iMaxDonation > 0) {
            // GUI chooser stub — in real impl shows a chooser for 0..iMaxDonation
            // then calls aPC.giveClassesAway(newcl, aClass, iLevels)
          }
        }
      }
    } catch (e) {
      print('levelExchange: $e');
    }
  }
}
