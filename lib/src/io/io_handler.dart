// Translation of pcgen.io.IOHandler

import '../core/player_character.dart';

/// Base interface for character file I/O handlers.
abstract interface class IOHandler {
  void read(PlayerCharacter pc, String filePath);
  void write(PlayerCharacter pc, String filePath);
}
