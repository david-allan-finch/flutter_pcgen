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
// Translation of pcgen.core.analysis.SubClassApplication
import '../../pc_class.dart';
import '../../player_character.dart';

// Handles subclass selection UI and application during class level-up.
final class SubClassApplication {
  SubClassApplication._();

  /// Prompts the user to select a subclass for [cl] on [aPC], if applicable.
  static void checkForSubClass(PlayerCharacter aPC, PCClass cl) {
    // Full implementation requires GUI chooser (CDOMChooserFacadeImpl,
    // ChooserFactory, LanguageBundle). Stubbed for Dart port.
    // Logic: build list of qualifying SubClass entries, show chooser,
    // call setSubClassKey with the selection, then apply prohibited schools.
  }

  static void setSubClassKey(
      PlayerCharacter pc, PCClass cl, String aKey) {
    if (cl == null) return;
    pc.setSubClassName(cl, aKey);
    if (aKey != cl.getKeyName()) {
      final a = cl.getSubClassKeyed(aKey);
      if (a != null) {
        cl.inheritAttributesFrom(a);
        pc.reInheritClassLevels(cl);
      }
    }
  }
}
