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
// Translation of pcgen.core.analysis.StatApplication
import '../../player_character.dart';

// Handles stat-increase selection UI during level-up.
final class StatApplication {
  StatApplication._();

  // Asks the user to choose stats to increment at level-up.
  // Returns the number of stat choices still unassigned.
  static int askForStatIncrease(
      PlayerCharacter aPC, int statsToChoose, bool isPre) {
    // Stub: GUI chooser not yet implemented in Dart port.
    // Full implementation requires CDOMChooserFacadeImpl, ChooserFactory,
    // SettingsHandler, and LanguageBundle integrations.
    return statsToChoose;
  }
}
