//
// Copyright 2010 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.persistence.lst.StatsAndChecksLoader

import '../../core/pc_alignment.dart';
import '../../core/pc_check.dart';
import '../../core/pc_stat.dart';
import '../../cdom/content/bonus_spell_info.dart';
import '../../rules/context/load_context.dart';

/// Loads statsandchecks.lst files from a game mode directory.
///
/// This loader extends SimpleLoader<Loadable> in Java. It recognises four
/// first-column tokens that identify the type of object being defined:
///   STATNAME    → PCStat (deprecated; prefer STAT: in .pcc files)
///   CHECKNAME   → PCCheck (deprecated; prefer SAVE: in .pcc files)
///   ALIGNMENTNAME → PCAlignment (deprecated; prefer ALIGNMENT: in .pcc files)
///   BONUSSPELLLEVEL → BonusSpellInfo
class StatsAndChecksLoader {
  final LoadContext _context;

  StatsAndChecksLoader(this._context);

  /// Parse a single line from a statsandchecks.lst file.
  ///
  /// Each line is a tab-delimited series of tokens. The first token determines
  /// the object type and name; subsequent tokens are TOKEN:value pairs applied
  /// to that object via the rules context.
  void parseLine(String line, Uri sourceUri) {
    if (line.isEmpty || line.startsWith('#')) return;

    final cols = line.split('\t');
    if (cols.isEmpty) return;

    final firstToken = cols[0].trim();
    final colonIdx = firstToken.indexOf(':');
    if (colonIdx <= 0 || colonIdx == firstToken.length - 1) return;

    final key = firstToken.substring(0, colonIdx);
    final name = firstToken.substring(colonIdx + 1).trim();
    if (name.isEmpty) return;

    dynamic loadable;
    switch (key) {
      case 'STATNAME':
        final stat = PCStat();
        stat.setName(name);
        stat.setSourceURI(sourceUri.toString());
        _context.getReferenceContext().register(stat);
        loadable = stat;
      case 'CHECKNAME':
        final check = PCCheck();
        check.setName(name);
        check.setSourceURI(sourceUri.toString());
        _context.getReferenceContext().register(check);
        loadable = check;
      case 'ALIGNMENTNAME':
        final align = PCAlignment();
        align.setName(name);
        align.setSourceURI(sourceUri.toString());
        _context.getReferenceContext().register(align);
        loadable = align;
      case 'BONUSSPELLLEVEL':
        final bsi = BonusSpellInfo();
        bsi.setName(name);
        bsi.setSourceURI(sourceUri.toString());
        _context.getReferenceContext().register(bsi);
        loadable = bsi;
      default:
        // Unknown key — ignored
        return;
    }

    // Apply remaining tab-delimited tokens to the loaded object
    for (int i = 1; i < cols.length; i++) {
      final tok = cols[i].trim();
      if (tok.isEmpty) continue;
      // TODO: dispatch token via TokenStore / LstUtils.processToken
    }
  }
}
