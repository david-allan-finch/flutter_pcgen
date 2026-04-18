// Translation of pcgen.io.exporttoken.AbstractExportToken

import '../../core/player_character.dart';
import 'token.dart';

/// Abstract base class for export tokens.
abstract class AbstractExportToken implements Token {
  @override
  String getToken(String tokenString, PlayerCharacter pc, dynamic eh) {
    // TODO: implement token resolution
    return '';
  }
}
