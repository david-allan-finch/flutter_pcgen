// Translation of pcgen.io.PCGVer2Parser

import '../core/player_character.dart';
import 'p_c_g_parser.dart';

/// Parses PCG version 2 character files.
class PCGVer2Parser extends PCGParser {
  PCGVer2Parser(PlayerCharacter pc) : super(pc);

  @override
  void parsePCG(List<String> lines) {
    // TODO: full implementation
    for (final line in lines) {
      _parseLine(line);
    }
  }

  void _parseLine(String line) {
    // TODO: dispatch to appropriate parse methods
  }
}
