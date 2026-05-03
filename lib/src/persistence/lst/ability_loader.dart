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
import 'package:flutter_pcgen/src/core/ability.dart';
import 'package:flutter_pcgen/src/core/ability_category.dart';
import 'package:flutter_pcgen/src/rules/context/load_context.dart';
import 'package:flutter_pcgen/src/persistence/lst/generic_loader.dart';
import 'package:flutter_pcgen/src/persistence/lst/source_entry.dart';

/// Loads Ability objects from LST files.
///
/// Extends GenericLoader so BONUS, PRExxx, CHOOSE, AUTO, TYPE, DESC, MULT,
/// STACK, DEFINE, etc. are all handled by the shared token processor.
/// The only extra work here is extracting CATEGORY: before delegating.
class AbilityLoader extends GenericLoader<Ability> {
  AbilityLoader() : super(() => Ability());

  @override
  Ability? parseLine(LoadContext context, Ability? ability, String lstLine, SourceEntry source) {
    final fields = lstLine.split('\t');
    if (fields.isEmpty) return null;

    final name = fields[0];

    // LST files often define the same ability across multiple lines (additive
    // tokens). Look up any already-registered ability with this name so that
    // the second line merges into the first rather than overwriting it.
    Ability anAbility;
    bool isNew = false;
    if (ability != null) {
      anAbility = ability;
    } else {
      final existing = context.getReferenceContext()
          .getConstructed<Ability>(Ability, name);
      if (existing != null) {
        anAbility = existing;
      } else {
        anAbility = Ability();
        isNew = true;
      }
    }

    anAbility.setName(name);
    anAbility.setSourceURI(source.getURI());

    // Extract CATEGORY: first — it determines which registry bucket to use.
    String? categoryToken;
    final remaining = <String>[];
    for (int i = 1; i < fields.length; i++) {
      final token = fields[i].trim();
      if (token.startsWith('CATEGORY:')) {
        categoryToken = token.substring(9).trim();
      } else if (token.isNotEmpty) {
        remaining.add(token);
      }
    }

    if (isNew) {
      if (categoryToken != null) {
        final cat = AbilityCategory.getCategory(categoryToken)
            ?? AbilityCategory(categoryToken);
        anAbility.setCDOMCategory(cat);
      }
      context.getReferenceContext().register(anAbility);
    }

    for (final token in remaining) {
      processToken(context, anAbility, source, token);
    }

    completeObject(context, source, anAbility);
    return null;
  }

  @override
  Ability? getObjectKeyed(LoadContext context, String key) {
    return context.getReferenceContext()
        .getAllConstructed<Ability>(Ability)
        .cast<Ability?>()
        .firstWhere((a) => a?.getKeyName() == key, orElse: () => null);
  }
}
