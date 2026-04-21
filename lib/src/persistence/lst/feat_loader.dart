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
// Translation of pcgen.persistence.lst.FeatLoader

import 'package:flutter_pcgen/src/core/ability.dart';
import 'package:flutter_pcgen/src/core/ability_category.dart';
import 'package:flutter_pcgen/src/rules/context/load_context.dart';
import 'package:flutter_pcgen/src/persistence/lst/ability_loader.dart';
import 'package:flutter_pcgen/src/persistence/lst/source_entry.dart';

/// Loads Feat objects from LST files.
///
/// FeatLoader extends AbilityLoader in Java. Feats are Ability objects whose
/// category defaults to FEAT if no CATEGORY: token is present.
class FeatLoader extends AbilityLoader {
  static final AbilityCategory _featCategory =
      AbilityCategory.getCategory('FEAT') ?? AbilityCategory('FEAT');

  @override
  Ability? parseLine(
      LoadContext context, Ability? ability, String lstLine, SourceEntry source) {
    // Inject a default CATEGORY:FEAT before delegating
    if (!lstLine.contains('CATEGORY:')) {
      lstLine = lstLine.contains('\t')
          ? lstLine.replaceFirst('\t', '\tCATEGORY:FEAT\t')
          : '$lstLine\tCATEGORY:FEAT';
    }
    return super.parseLine(context, ability, lstLine, source);
  }
}
