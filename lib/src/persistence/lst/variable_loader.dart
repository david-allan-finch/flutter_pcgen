//
// Copyright 2014 (C) Tom Parker <thpr@users.sourceforge.net>
// Copyright 2008-10 (C) Tom Parker <thpr@users.sourceforge.net>
// Copyright 2003 (C) David Hibbs <sage_sam@users.sourceforge.net>
// Copyright 2001 (C) Bryan McRoberts <merton_monk@yahoo.com>
//
// This library is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This library is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.persistence.lst.VariableLoader

import 'package:flutter_pcgen/src/rules/context/load_context.dart';
import 'campaign_source_entry.dart';
import 'lst_file_loader.dart';
import 'lst_utils.dart';
import 'source_entry.dart';

/// Loads variable definitions from LST files into the rules context.
///
/// Each line defines one DatasetVariable via TOKEN:value format.
/// If the first token doesn't contain a colon it is prepended with "GLOBAL:".
class VariableLoader {
  /// Parses one line from a variable LST file.
  void parseLine(LoadContext context, String lstLine, SourceEntry source) {
    if (lstLine.isEmpty || lstLine.startsWith('#')) return;

    final cols = lstLine.split('\t');
    if (cols.isEmpty) return;

    var firstToken = cols[0].trim();
    if (!firstToken.contains(':')) {
      firstToken = 'GLOBAL:$firstToken';
    }

    // DatasetVariable is the target in Java; stub as dynamic for now
    // TODO: construct DatasetVariable via context.getReferenceContext()
    //       and dispatch tokens via LstUtils.processToken
  }

  /// Load a list of LST files.
  Future<void> loadLstFiles(
      LoadContext context, List<CampaignSourceEntry> fileList) async {
    final loaded = <CampaignSourceEntry>{};
    for (final sourceEntry in fileList) {
      if (!loaded.contains(sourceEntry)) {
        await _loadLstFile(context, sourceEntry);
        loaded.add(sourceEntry);
      }
    }
  }

  Future<void> _loadLstFile(
      LoadContext context, CampaignSourceEntry sourceEntry) async {
    final uri = sourceEntry.getURI();
    final content = await LstFileLoader.readFromURI(uri);
    if (content == null) return;
    context.setSourceURI(uri);
    for (final line in content.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
      parseLine(context, trimmed, sourceEntry);
    }
  }
}
