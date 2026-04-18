// Translation of pcgen.system.CharacterManager

import '../core/player_character.dart';
import '../facade/core/character_facade.dart';
import '../facade/core/data_set_facade.dart';
import '../facade/core/source_selection_facade.dart';
import '../facade/core/ui_delegate.dart';
import '../facade/util/default_list_facade.dart';

/// Manages currently-open characters in PCGen.
final class CharacterManager {
  static final CharacterManager _instance = CharacterManager._();

  final DefaultListFacade<CharacterFacade> _characters = DefaultListFacade();

  CharacterManager._();

  static CharacterManager getInstance() => _instance;

  DefaultListFacade<CharacterFacade> getCharacters() => _characters;

  CharacterFacade? createNewCharacter(
      UIDelegate delegate, DataSetFacade dataset) {
    // TODO: full implementation
    return null;
  }

  CharacterFacade? openCharacter(
      String filePath, UIDelegate delegate, DataSetFacade dataset) {
    // TODO: full implementation
    return null;
  }

  void saveCharacter(CharacterFacade character) {
    // TODO: full implementation
  }

  void closeCharacter(CharacterFacade character) {
    _characters.removeElement(character);
  }
}
