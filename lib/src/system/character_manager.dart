// Translation of pcgen.system.CharacterManager

import '../core/player_character.dart';
import '../facade/core/character_facade.dart';
import '../facade/core/data_set_facade.dart';
import '../facade/core/source_selection_facade.dart';
import '../facade/core/ui_delegate.dart';
import '../facade/util/default_list_facade.dart';

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

  /// Creates a new blank character for the given [dataset], returning its
  /// facade.
  ///
  /// The new character is automatically added to [getCharacters()].
  /// Returns null if creation fails.
  static CharacterFacade? createNewCharacter(
      UIDelegate delegate, DataSetFacade dataset) {
    // TODO: construct a CharacterFacadeImpl, add to _characters, fire
    //       PlayerCharacterWasLoadedMessage via the plugin message bus.
    return null;
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
  // Source selection helpers
  // ---------------------------------------------------------------------------

  /// Returns the [SourceSelectionFacade] for [character], or null.
  static SourceSelectionFacade? getCharacterSourceSelection(
      CharacterFacade character) {
    // TODO: extract from CharacterFacade when facade is fully ported.
    return null;
  }
}
