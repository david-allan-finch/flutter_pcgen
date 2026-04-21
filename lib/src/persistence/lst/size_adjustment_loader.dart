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
// Translation of pcgen.persistence.lst.SizeAdjustmentLoader

import 'package:flutter_pcgen/src/core/size_adjustment.dart';
import 'package:flutter_pcgen/src/rules/context/load_context.dart';
import 'package:flutter_pcgen/src/persistence/lst/lst_line_file_loader.dart';

/// Loads SizeAdjustment objects from a size.lst game mode file.
///
/// In Java this extends LstLineFileLoader. Each line defines one size category.
/// The first tab-column is the size name/key; the rest are TOKEN:value pairs.
class SizeAdjustmentLoader extends LstLineFileLoader {
  @override
  void parseLine(dynamic context, String lstLine, Uri sourceUri) {
    if (lstLine.isEmpty || lstLine.startsWith('#')) return;

    final fields = lstLine.split('\t');
    if (fields.isEmpty) return;

    final name = fields[0].trim();
    if (name.isEmpty) return;

    final size = SizeAdjustment();
    size.setName(name);
    size.setSourceURI(sourceUri.toString());

    if (context is LoadContext) {
      context.getReferenceContext().register(size);
    }

    // Apply remaining tokens
    for (int i = 1; i < fields.length; i++) {
      final tok = fields[i].trim();
      if (tok.isEmpty) continue;
      // TODO: dispatch via TokenStore
    }
  }
}
