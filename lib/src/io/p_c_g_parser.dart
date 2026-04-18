// Translation of pcgen.io.PCGParser

import '../core/player_character.dart';
import 'p_c_g_parse_exception.dart';

/// Abstract base for PCG file parsers.
abstract class PCGParser {
  final PlayerCharacter pc;

  PCGParser(this.pc);

  /// Parse lines from a PCG file into [pc].
  void parsePCG(List<String> lines);
}
