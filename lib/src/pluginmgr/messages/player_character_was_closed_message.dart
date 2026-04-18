// Translation of pcgen.pluginmgr.messages.PlayerCharacterWasClosedMessage

import '../../core/player_character.dart';
import '../p_c_gen_message.dart';

/// Advisory message that a character was closed in the UI.
class PlayerCharacterWasClosedMessage extends PCGenMessage {
  final PlayerCharacter pc;

  PlayerCharacterWasClosedMessage(Object source, this.pc) : super(source);

  PlayerCharacter getPc() => pc;
}
