//
// Copyright 2003 (C) David Hibbs <sage_sam@users.sourceforge.net>
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
// Translation of pcgen.persistence.lst.LstLineFileLoader
import 'package:flutter_pcgen/src/rules/context/load_context.dart';
import 'package:flutter_pcgen/src/persistence/persistence_layer_exception.dart';
import 'package:flutter_pcgen/src/persistence/lst/campaign_source_entry.dart';
import 'package:flutter_pcgen/src/persistence/lst/lst_file_loader.dart';

// Base loader for non-CDOMObject LST data (system files: sizes, paper, etc.)
// Unlike LstObjectFileLoader, does not handle .MOD/.COPY/.FORGET.
abstract class LstLineFileLoader {
  final Set<String> _loadedFiles = {};

  /// Load a list of files, invoking [parseLine] for each content line.
  Future<void> loadLstFiles(LoadContext context, List<CampaignSourceEntry> fileList) async {
    for (final sourceEntry in fileList) {
      final uri = sourceEntry.getURI();
      if (_loadedFiles.contains(uri)) continue;
      _loadedFiles.add(uri);
      await _loadLstFile(context, sourceEntry);
    }
  }

  Future<void> _loadLstFile(LoadContext context, CampaignSourceEntry sourceEntry) async {
    final uri = sourceEntry.getURI();
    final content = await LstFileLoader.readFromURI(uri);
    if (content == null) return;

    context.setSourceURI(uri);
    final lines = content.split(RegExp(LstFileLoader.lineSeparatorRegexp));
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.trim().isEmpty || line.codeUnitAt(0) == LstFileLoader.lineCommentChar) continue;
      try {
        parseLine(context, line, Uri.parse(uri));
      } catch (e) {
        print('ERROR parsing $uri line ${i+1}: $e');
      }
    }
  }

  /// Parse a single content line. Subclasses implement this.
  void parseLine(LoadContext context, String lstLine, Uri uri);
}
