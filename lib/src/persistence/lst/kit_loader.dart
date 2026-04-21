//
// Copyright 2001 (C) Greg Bingleman <byngl@hotmail.com>
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
// Translation of pcgen.persistence.lst.KitLoader

import 'package:flutter_pcgen/src/core/kit.dart';
import 'package:flutter_pcgen/src/rules/context/load_context.dart';
import 'lst_object_file_loader.dart';
import 'source_entry.dart';

/// Loads Kit objects from LST files.
///
/// KitLoader extends LstObjectFileLoader<Kit> in Java.
class KitLoader extends LstObjectFileLoader<Kit> {
  @override
  Kit? parseLine(LoadContext context, Kit? kit, String lstLine, SourceEntry source) {
    final fields = lstLine.split('\t');
    if (fields.isEmpty) return null;

    final firstName = fields[0].trim();
    if (firstName.isEmpty) return null;

    final currentKit = kit ?? Kit();
    if (kit == null) {
      currentKit.setName(firstName);
      currentKit.setSourceURI(source.getURI().toString());
      context.getReferenceContext().register(currentKit);
    }

    // Process remaining token:value pairs
    for (int i = 1; i < fields.length; i++) {
      final token = fields[i].trim();
      if (token.isEmpty) continue;
      // TODO: dispatch token via TokenStore / LstUtils.processToken
    }

    return currentKit;
  }

  @override
  Kit? getObjectKeyed(LoadContext context, String key) {
    return context.getReferenceContext()
        .getAllConstructed<Kit>(Kit)
        .cast<Kit?>()
        .firstWhere((k) => k?.getKeyName() == key, orElse: () => null);
  }
}
