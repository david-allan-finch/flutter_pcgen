// Translation of pcgen.pluginmgr.messages.PlayerCharacterWasLoadedMessage

import '../../core/player_character.dart';
import '../p_c_gen_message.dart';

/// Message that a character was opened in PCGen.
class PlayerCharacterWasLoadedMessage extends PCGenMessage {
  final PlayerCharacter pc;

  PlayerCharacterWasLoadedMessage(Object source, this.pc) : super(source);

  PlayerCharacter getPc() => pc;
}
