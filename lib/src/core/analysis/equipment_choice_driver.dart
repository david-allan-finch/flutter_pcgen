//
// Copyright 2008 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.core.analysis.EquipmentChoiceDriver
import '../../../cdom/enumeration/string_key.dart';
import '../../player_character.dart';

// Drives the equipment-modifier choice UI for adding/removing EquipmentModifiers.
final class EquipmentChoiceDriver {
  EquipmentChoiceDriver._();

  /// Shows a choice dialog for [eqMod] on [parent].
  /// Returns true if a valid choice was made (or none was needed).
  static bool getChoice(int pool, dynamic parent, dynamic eqMod, bool bAdd,
      PlayerCharacter pc) {
    final choiceString = eqMod.getSafe(StringKey.choiceString) as String;
    if (choiceString.isEmpty) return true;

    final forEqBuilder = choiceString.startsWith('EQBUILDER.');
    if (bAdd && forEqBuilder) return true;

    // Full implementation requires EquipmentChoice, CDOMChooserFacadeImpl,
    // ChooserFactory, LanguageBundle, and SignedInteger. Stubbed for Dart port.
    return true;
  }
}
