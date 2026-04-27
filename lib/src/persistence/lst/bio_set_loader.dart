//
// Copyright 2002 (C) Bryan McRoberts <merton_monk@yahoo.com>
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
// Translation of pcgen.persistence.lst.BioSetLoader

import 'package:flutter_pcgen/src/core/age_set.dart';
import 'package:flutter_pcgen/src/core/bio_set.dart';
import 'package:flutter_pcgen/src/persistence/lst/lst_file_loader.dart';

/// Loads biosettings .lst files into a [BioSet].
///
/// The file format has three types of leading keywords:
///  - REGION:<name>   — sets the current region context
///  - AGESET:<n>|<name>[<tab-delimited tokens...>] — defines an age bracket
///  - RACENAME:<name>[<tab-delimited tag:value tokens>] — race bio overrides
class BioSetLoader {
  int _currentAgeSetIndex = 0;
  String? _region; // null = no region (Optional.empty() in Java)

  final BioSet bioSet;

  BioSetLoader(this.bioSet);

  /// Reads [source] and calls [parseLine] for each non-blank, non-comment line.
  Future<void> loadLstFile(dynamic context, Uri source) async {
    final content = await LstFileLoader.readFromURI(source.toString());
    if (content == null) return;
    final lines = content.split(RegExp(LstFileLoader.lineSeparatorRegexp));
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.codeUnitAt(0) == LstFileLoader.lineCommentChar) continue;
      parseLine(trimmed, source);
    }
  }

  /// Parses one line from a biosettings .lst file.
  void parseLine(String lstLine, Uri sourceUri) {
    if (lstLine.isEmpty || lstLine.startsWith('#')) return;

    if (lstLine.startsWith('AGESET:')) {
      _parseAgeSet(lstLine.substring(7), sourceUri);
    } else if (lstLine.startsWith('REGION:')) {
      final regionName = lstLine.substring(7).trim();
      _region = regionName.toUpperCase() == 'NONE' ? null : regionName;
    } else if (lstLine.startsWith('RACENAME:')) {
      _parseRaceName(lstLine.substring(9), sourceUri);
    }
    // Lines not matching any keyword are silently ignored (comments, blank lines, etc.)
  }

  void _parseAgeSet(String body, Uri sourceUri) {
    final pipeIdx = body.indexOf('|');
    if (pipeIdx < 0) return; // invalid line

    final ageIndexStr = body.substring(0, pipeIdx).trim();
    final ageIndex = int.tryParse(ageIndexStr);
    if (ageIndex == null) return; // non-integer index

    _currentAgeSetIndex = ageIndex;
    final rest = body.substring(pipeIdx + 1);
    final cols = rest.split('\t');

    final ageSet = AgeSet();
    ageSet.setSourceURI(sourceUri.toString());
    ageSet.setAgeIndex(_currentAgeSetIndex);

    if (cols.isNotEmpty) {
      ageSet.setName(cols[0].trim());
    }

    // Remaining columns are TOKEN:value pairs — processed by token registry
    // (stub: ignored for now; full impl calls LstUtils.processToken)

    bioSet.addToAgeMap(_region, ageSet);
    bioSet.addToNameMap(ageSet.getKeyName(), _currentAgeSetIndex);
  }

  void _parseRaceName(String body, Uri sourceUri) {
    final cols = body.split('\t');
    if (cols.isEmpty) return;

    final raceName = cols[0].trim();
    for (int i = 1; i < cols.length; i++) {
      final tag = cols[i].trim();
      if (tag.isEmpty) continue;
      bioSet.addToUserMap(_region, raceName, tag, _currentAgeSetIndex);
    }
  }
}
