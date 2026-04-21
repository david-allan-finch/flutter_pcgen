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
// Translation of pcgen.core.analysis.AddObjectActions
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
