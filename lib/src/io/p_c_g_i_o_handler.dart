//
// Copyright 2002 (C) Thomas Behr <ravenlock@gmx.de>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
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
