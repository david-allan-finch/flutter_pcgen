// Translation of pcgen.io.exporttoken.Token

import '../../core/player_character.dart';

/// Base interface for export template tokens.
abstract interface class Token {
  String getTokenName();
  String getToken(String tokenString, PlayerCharacter pc, dynamic eh);
}
