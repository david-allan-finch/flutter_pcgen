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
// Translation of pcgen.core.analysis.SubstitutionClassApplication
import 'package:flutter_pcgen/src/core/pc_class.dart';
import 'package:flutter_pcgen/src/core/player_character.dart';
import 'substitution_level_support.dart';

// Handles substitution-class selection UI and application during level-up.
final class SubstitutionClassApplication {
  SubstitutionClassApplication._();

  static void checkForSubstitutionClass(
      PCClass cl, int aLevel, PlayerCharacter aPC) {
    // Full implementation requires GUI chooser (CDOMChooserFacadeImpl,
    // ChooserFactory, LanguageBundle). Stubbed for Dart port.
    // Logic: build sorted choice list of qualifying SubstitutionClass entries,
    // show chooser, then call SubstitutionLevelSupport.applyLevelArrayModsToLevel.
  }

  static void _buildSubstitutionClassChoiceList(PCClass cl,
      List<PCClass> choiceList, int level, PlayerCharacter aPC) {
    // stub — would populate choiceList with qualifying SubstitutionClass entries
  }
}
