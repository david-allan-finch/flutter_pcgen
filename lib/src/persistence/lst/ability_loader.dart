//
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
// Translation of pcgen.persistence.lst.AbilityLoader
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/object_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/string_key.dart';
import 'package:flutter_pcgen/src/core/ability.dart';
import 'package:flutter_pcgen/src/core/ability_category.dart';
import 'package:flutter_pcgen/src/persistence/lst/lst_utils.dart';
import 'package:flutter_pcgen/src/rules/context/load_context.dart';
import 'package:flutter_pcgen/src/persistence/lst/lst_object_file_loader.dart';
import 'package:flutter_pcgen/src/persistence/lst/source_entry.dart';

// Loads Ability objects from LST files.
class AbilityLoader extends LstObjectFileLoader<Ability> {
  @override
  Ability? parseLine(LoadContext context, Ability? ability, String lstLine, SourceEntry source) {
    Ability anAbility = ability ?? Ability();
    final bool isNew = ability == null;

    final fields = lstLine.split('\t');
    if (fields.isEmpty) return null;

    anAbility.setName(fields[0]);
    anAbility.setSourceURI(source.getURI());

    String? categoryToken;
    final remaining = <String>[];

    for (int i = 1; i < fields.length; i++) {
      final token = fields[i];
      if (token.startsWith('CATEGORY:')) {
        categoryToken = token.substring(9);
      } else {
        remaining.add(token);
      }
    }

    if (isNew) {
      if (categoryToken != null) {
        final cat = AbilityCategory.getCategory(categoryToken);
        if (cat != null) {
          anAbility.setCDOMCategory(cat);
        } else {
          // Invalid category — skip
          return null;
        }
      }
      context.getReferenceContext().register(anAbility);
    }

    // Process remaining tokens (BONUS, PRExxx, TYPE, etc.)
    for (final token in remaining) {
      _processToken(context, anAbility, token, source);
    }

    completeObject(context, source, anAbility);
    return null;
  }

  void _processToken(LoadContext context, Ability obj, String token, SourceEntry source) {
    final (tag, value) = LstUtils.splitToken(token);
    if (value.isEmpty) return;
    switch (tag.toUpperCase()) {
      case 'TYPE':
        for (final t in value.split('.')) {
          if (t.isNotEmpty) {
            try { obj.addToListFor(ListKey.getConstant<String>('TYPE'), t); } catch (_) {}
          }
        }
        break;
      case 'DESC':
        obj.putString(StringKey.description, value);
        break;
      case 'SOURCELONG':
        obj.putString(StringKey.sourceLong, value);
        break;
      case 'SOURCESHORT':
        obj.putString(StringKey.sourceShort, value);
        break;
      case 'OUTPUTNAME':
        obj.putString(StringKey.outputName, value);
        break;
      case 'MULT':
        obj.putObject(ObjectKey.multipleAllowed, value.toUpperCase() == 'YES');
        break;
      case 'STACK':
        obj.putObject(ObjectKey.stacks, value.toUpperCase() == 'YES');
        break;
      case 'SORTKEY':
        obj.putString(StringKey.sortKey, value);
        break;
      default:
        // PRE, BONUS, CHOOSE, AUTO, etc. — skipped for now
        break;
    }
  }

  @override
  Ability? getObjectKeyed(LoadContext context, String key) {
    return context.getReferenceContext()
        .getAllConstructed<Ability>(Ability)
        .cast<Ability?>()
        .firstWhere((a) => a?.getKeyName() == key, orElse: () => null);
  }
}
