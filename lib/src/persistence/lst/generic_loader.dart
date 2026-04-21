//
// Copyright 2008-10 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.persistence.lst.GenericLoader
import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/object_key.dart';
import 'package:flutter_pcgen/src/rules/context/load_context.dart';
import 'package:flutter_pcgen/src/persistence/lst/lst_object_file_loader.dart';
import 'package:flutter_pcgen/src/persistence/lst/source_entry.dart';

// Generic loader for CDOMObjects — creates an instance via [factory] then applies LST tokens.
class GenericLoader<T extends CDOMObject> extends LstObjectFileLoader<T> {
  final T Function() factory;
  final List<Function(LoadContext, T, String, SourceEntry)> _tokenHandlers = [];

  GenericLoader(this.factory);

  void addTokenHandler(Function(LoadContext, T, String, SourceEntry) handler) {
    _tokenHandlers.add(handler);
  }

  @override
  T? parseLine(LoadContext context, T? object, String lstLine, SourceEntry source) {
    final bool isNew = object == null;
    final T po = isNew ? factory() : object;

    final fields = lstLine.split('\t');
    if (fields.isEmpty) return null;

    po.setName(fields[0]);
    po.putObject(ObjectKey.sourceCampaign, source.getCampaign());
    po.setSourceURI(source.getURI());

    if (isNew) {
      context.getReferenceContext().register(po);
    }

    for (int i = 1; i < fields.length; i++) {
      _processToken(context, po, source, fields[i]);
    }

    completeObject(context, source, po);
    return null; // one line per object
  }

  void _processToken(LoadContext context, T obj, SourceEntry source, String token) {
    if (token.trim().isEmpty) return;
    for (final handler in _tokenHandlers) {
      handler(context, obj, token, source);
    }
  }

  @override
  T? getObjectKeyed(LoadContext context, String key) {
    return context.getReferenceContext().getAllConstructed<T>(T).cast<T?>().firstWhere(
      (o) => o?.getKeyName() == key,
      orElse: () => null,
    );
  }
}
