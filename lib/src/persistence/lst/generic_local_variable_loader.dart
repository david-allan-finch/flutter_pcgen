//
// Copyright 2015 (C) Thomas Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.persistence.lst.GenericLocalVariableLoader

import 'package:flutter_pcgen/src/rules/context/load_context.dart';
import 'package:flutter_pcgen/src/persistence/lst/lst_line_file_loader.dart';
import 'package:flutter_pcgen/src/persistence/lst/source_entry.dart';

/// Loads local variable definitions from LST files for a specific scope.
///
/// In Java this is parameterized by the scope class. Each line defines a
/// variable name and optional type for that scope.
class GenericLocalVariableLoader extends LstLineFileLoader {
  final String scopeName;

  GenericLocalVariableLoader(this.scopeName);

  @override
  void parseLine(dynamic context, String lstLine, Uri sourceUri) {
    if (lstLine.isEmpty || lstLine.startsWith('#')) return;

    final cols = lstLine.split('\t');
    if (cols.isEmpty) return;

    final firstToken = cols[0].trim();
    if (firstToken.isEmpty) return;

    // In the full implementation:
    // 1. Parse the variable name from firstToken
    // 2. Create a DatasetVariable for the given scope
    // 3. Apply remaining tokens (DEFINE, type, etc.)
    // TODO: full variable registration via rules context
  }
}
