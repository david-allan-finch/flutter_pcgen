//
// Copyright 2013 (C) James Dempsey <jdempsey@users.sourceforge.net>
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
// Translation of pcgen.io.freemarker.CharacterExportAction
// Generates an HTML character sheet by either:
//   (a) processing a FreeMarker .htm.ftl template, or
//   (b) using the built-in HTML sheet generator.

import 'dart:io';
import 'package:flutter_pcgen/src/gui2/facade/character_facade_impl.dart';
import 'package:flutter_pcgen/src/io/freemarker/ftl_engine.dart';
import 'package:flutter_pcgen/src/io/freemarker/pcgen_token_api.dart';
import 'package:flutter_pcgen/src/io/html/builtin_sheet_generator.dart';

class CharacterExportAction {
  final CharacterFacadeImpl pc;
  final dynamic dataset;

  CharacterExportAction(this.pc, {this.dataset});

  /// Generate HTML from an external FreeMarker template file.
  String executeFromTemplate(String templatePath) {
    final ctx = PcgenTokenContext(pc, dataset);
    final baseDir = File(templatePath).parent.path;
    final content = File(templatePath).readAsStringSync();
    return FtlEngine().render(content, ctx, baseDir: baseDir);
  }

  /// Generate HTML using the built-in character sheet.
  String executeBuiltIn() => BuiltinSheetGenerator(pc, dataset).generate();

  /// Export HTML to a temp file and return its path.
  Future<String> exportToTempFile({String? templatePath}) async {
    final html = templatePath != null
        ? executeFromTemplate(templatePath)
        : executeBuiltIn();
    final dir = Directory.systemTemp;
    final safeName = pc.getName().replaceAll(RegExp(r'[^\w\-]'), '_');
    final file = File('${dir.path}/$safeName.html');
    await file.writeAsString(html);
    return file.path;
  }
}
