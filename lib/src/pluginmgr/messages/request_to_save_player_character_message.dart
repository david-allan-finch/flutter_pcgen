// Translation of pcgen.pluginmgr.messages.RequestToSavePlayerCharacterMessage

import '../../core/player_character.dart';
import '../p_c_gen_message.dart';

/// Requests that PCGen save the specified character.
class RequestToSavePlayerCharacterMessage extends PCGenMessage {
  final PlayerCharacter pc;

  RequestToSavePlayerCharacterMessage(Object source, this.pc) : super(source);

  PlayerCharacter getPc() => pc;
}
