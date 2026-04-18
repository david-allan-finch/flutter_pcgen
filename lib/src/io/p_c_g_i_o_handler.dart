// Translation of pcgen.io.PCGIOHandler

import '../core/player_character.dart';
import 'io_handler.dart';
import 'p_c_g_ver2_creator.dart';
import 'p_c_g_ver2_parser.dart';

/// Reads and writes PCG character files.
class PCGIOHandler implements IOHandler {
  @override
  void read(PlayerCharacter pc, String filePath) {
    // TODO: read file and parse
    final lines = <String>[];
    PCGVer2Parser(pc).parsePCG(lines);
  }

  @override
  void write(PlayerCharacter pc, String filePath) {
    // TODO: write to file
    final _ = PCGVer2Creator(pc).createPCGString();
  }
}
