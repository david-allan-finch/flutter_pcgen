//
// Copyright 2010 (C) Tom Parker <thpr@users.sourceforge.net>
// Copyright 2001 (C) Bryan McRoberts <merton_monk@yahoo.com>
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
// Translation of pcgen.persistence.lst.LoadInfoLoader

import 'package:flutter_pcgen/src/persistence/lst/lst_line_file_loader.dart';

/// Loads encumbrance and load info from load.lst game mode files.
///
/// Defines load categories (Light, Medium, Heavy, Overloaded) and the
/// formulas used to calculate carry capacity by strength score.
class LoadInfoLoader extends LstLineFileLoader {
  // load category name → formula string
  final Map<String, String> _loadMap = {};

  Map<String, String> get loadMap => Map.unmodifiable(_loadMap);

  @override
  void parseLine(dynamic context, String lstLine, Uri sourceUri) {
    if (lstLine.isEmpty || lstLine.startsWith('#')) return;

    final cols = lstLine.split('\t');
    if (cols.isEmpty) return;

    // Each token is KEY:value
    for (final col in cols) {
      final tok = col.trim();
      final colonIdx = tok.indexOf(':');
      if (colonIdx <= 0) continue;
      final key = tok.substring(0, colonIdx).trim();
      final value = tok.substring(colonIdx + 1).trim();

      switch (key) {
        case 'LOADSCOREVALUE':
        case 'LOADMULTIPLIER':
        case 'SIZEMULT':
          _loadMap[key] = value;
        default:
          // Unknown token — ignored
          break;
      }
    }
  }
}
