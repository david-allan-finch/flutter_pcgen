//
// Copyright 2012 (C) Tom Parker
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
// Translation of pcgen.persistence.lst.CompanionModLoader

import '../../core/character/companion_mod.dart';
import '../../rules/context/load_context.dart';
import 'simple_loader.dart';
import 'source_entry.dart';

/// Loads CompanionMod objects from LST files.
///
/// Extends SimpleLoader<CompanionMod> in Java. The first token on each line
/// is "FOLLOWER:<class>=<level>" or similar; the remainder are TOKEN:value pairs.
class CompanionModLoader extends SimpleLoader<CompanionMod> {
  CompanionModLoader() : super(CompanionMod);

  @override
  CompanionMod? getLoadable(dynamic context, String firstToken, Uri sourceUri) {
    // The first token is the class/level specification for the companion mod
    // e.g. "Sorcerer=1" or "Familiar=1"
    final mod = CompanionMod();
    mod.setName(firstToken);
    mod.setSourceURI(sourceUri.toString());
    if (context is LoadContext) {
      context.getReferenceContext().register(mod);
    }
    return mod;
  }
}
