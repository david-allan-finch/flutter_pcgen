// Translation of pcgen.io.PCGVer2Creator

import '../core/player_character.dart';

/// Writes a PlayerCharacter to PCG version 2 format.
class PCGVer2Creator {
  final PlayerCharacter pc;

  PCGVer2Creator(this.pc);

  /// Returns the PCG file content as a string.
  String createPCGString() {
    // TODO: full implementation
    final buf = StringBuffer();
    buf.write('VERSION:6.0.1\n');
    buf.write('NAME:${pc.getName()}\n');
    return buf.toString();
  }
}
