//
// Copyright 2010 Connor Petty <cpmeister@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.system.CharacterManager

import 'package:flutter_pcgen/src/core/player_character.dart';
import 'package:flutter_pcgen/src/facade/core/character_facade.dart';
import 'package:flutter_pcgen/src/facade/core/data_set_facade.dart';
import 'package:flutter_pcgen/src/facade/core/source_selection_facade.dart';
import 'package:flutter_pcgen/src/facade/core/ui_delegate.dart';
import 'package:flutter_pcgen/src/facade/util/default_list_facade.dart';
import 'package:flutter_pcgen/src/gui2/facade/character_facade_impl.dart';

/// Manages currently-open characters in PCGen.
///
/// Provides the canonical list of open [CharacterFacade] objects and
/// factory methods for creating, opening, saving and closing characters.
///
/// This is a static-only utility class (singleton pattern from Java).
/// Translation of pcgen.system.CharacterManager.
final class CharacterManager {
  CharacterManager._(); // Not instantiable.

  // ---------------------------------------------------------------------------
  // Static state
  // ---------------------------------------------------------------------------

  static final DefaultListFacade<CharacterFacade> _characters =
      DefaultListFacade();

  /// The recent-character file list (paths to recently opened PCG files).
  static final List<String> recentCharacters = [];

  /// The recent-party file list (paths to recently opened PCP files).
  static final List<String> recentParties = [];

  // ---------------------------------------------------------------------------
  // Character list access
  // ---------------------------------------------------------------------------

  /// Returns the observable list of currently open characters.
  static DefaultListFacade<CharacterFacade> getCharacters() => _characters;

  // ---------------------------------------------------------------------------
  // Create / open
  // ---------------------------------------------------------------------------

  /// Creates a new blank character, adds it to the open character list and
  /// returns its facade. [dataset] may be null or any type — it is stored for
  /// future use but not required to construct the character model.
  static CharacterFacade? createNewCharacter(
      UIDelegate? delegate, dynamic dataset) {
    final facade = CharacterFacadeImpl({
      'name': 'New Character',
      'tabName': '',
      'fileName': null,
      'modified': false,
      'playerName': '',
      'gender': '',
      'age': 0,
      'xp': 0,
      'hp': 0,
      'funds': 0.0,
      'biography': '',
      'appearance': '',
      'notes': '',
      'raceKey': '',
      'alignmentKey': '',
      'deityKey': '',
      'statScores': {
        'STR': 10, 'DEX': 10, 'CON': 10,
        'INT': 10, 'WIS': 10, 'CHA': 10,
      },
      'classLevels': <dynamic>[],
      'skillRanks': <String, dynamic>{},
      'selectedAbilities': <String, dynamic>{},
      'selectedDomains': <String>[],
      'appliedTemplates': <String>[],
      'languageKeys': <String>[],
      'gear': <dynamic>[],
      'companions': <dynamic>[],
      'tempBonuses': <dynamic>[],
      'knownSpells': <dynamic>[],
      'preparedSpells': <dynamic>[],
    });
    _characters.addElement(facade);
    return facade;
  }

  /// Opens the character saved at [filePath] using [dataset].
  ///
  /// Returns the facade for the loaded character, or null on error.
  static CharacterFacade? openCharacter(
      String filePath, UIDelegate delegate, DataSetFacade dataset) {
    // TODO: use PCGIOHandler to read the file, construct CharacterFacadeImpl,
    //       add to _characters, update recentCharacters list, fire loaded msg.
    return null;
  }

  /// Opens a party file (.pcp) at [filePath], loading all referenced
  /// characters.  Returns a list of opened character facades.
  static List<CharacterFacade> openParty(
      String filePath, UIDelegate delegate, DataSetFacade dataset) {
    // TODO: parse party file for individual PCG file paths, delegate to
    //       openCharacter for each, update recentParties list.
    return const [];
  }

  // ---------------------------------------------------------------------------
  // Save
  // ---------------------------------------------------------------------------

  /// Saves [character] to its current file.
  ///
  /// If the character has no file assigned, [saveCharacterAs] should be used
  /// instead.
  static void saveCharacter(CharacterFacade character) {
    // TODO: use PCGIOHandler to write character to its file path.
  }

  /// Saves [character] to [filePath].
  static void saveCharacterAs(CharacterFacade character, String filePath) {
    // TODO: update character file reference and delegate to saveCharacter.
  }

  /// Saves all open characters that have unsaved changes.
  static void saveAllCharacters() {
    for (final character in _characters.getContents()) {
      if (character.isDirty()) {
        saveCharacter(character);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Close
  // ---------------------------------------------------------------------------

  /// Closes [character] and removes it from the open list.
  ///
  /// Does not prompt for unsaved changes — callers should do so first.
  static void closeCharacter(CharacterFacade character) {
    _characters.removeElement(character);
  }

  /// Closes all open characters.
  static void closeAllCharacters() {
    final snapshot = _characters.getContents();
    for (final character in snapshot) {
      closeCharacter(character);
    }
  }

  // ---------------------------------------------------------------------------
  // Convenience aliases used by PCGenFrame
  // ---------------------------------------------------------------------------

  /// Alias for [closeCharacter].
  static void removeCharacter(CharacterFacade character) =>
      closeCharacter(character);

  /// Opens a character from [filePath] without requiring a UIDelegate.
  static CharacterFacade? loadCharacterFromFile(String filePath) {
    // TODO: load using PCGIOHandler.
    return null;
  }

  /// Opens a party file from [filePath] without requiring a UIDelegate.
  static void loadPartyFromFile(String filePath) {
    // TODO: parse party file and load each character.
  }

  // ---------------------------------------------------------------------------
  // Source selection helpers
  // ---------------------------------------------------------------------------

  /// Returns the [SourceSelectionFacade] for [character], or null.
  static SourceSelectionFacade? getCharacterSourceSelection(
      CharacterFacade character) {
    // TODO: extract from CharacterFacade when facade is fully ported.
    return null;
  }
}
