// Translation of pcgen.pluginmgr.messages.RequestOpenPlayerCharacterMessage

import '../../core/player_character.dart';
import '../p_c_gen_message.dart';

/// Requests that a specific character file be loaded.
class RequestOpenPlayerCharacterMessage extends PCGenMessage {
  final String filePath;
  final bool blockLoadedMessage;
  PlayerCharacter? playerCharacter;

  RequestOpenPlayerCharacterMessage(
      Object source, this.filePath, this.blockLoadedMessage)
      : super(source);

  String getFilePath() => filePath;
  bool isBlockLoadedMessage() => blockLoadedMessage;
  PlayerCharacter? getPlayerCharacter() => playerCharacter;
  void setPlayerCharacter(PlayerCharacter pc) => playerCharacter = pc;
}
