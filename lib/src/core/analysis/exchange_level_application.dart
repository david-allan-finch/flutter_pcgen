//
// Copyright 2009 (C) Tom Parker <thpr@users.sourceforge.net>
// Copyright 2001 (C) Bryan McRoberts <merton_monk@yahoo.com>
//
// This library is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This library is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.core.analysis.ExchangeLevelApplication
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
