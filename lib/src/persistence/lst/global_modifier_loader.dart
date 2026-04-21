//
// LstObjecttFileLoader and GenericLoader Copyright 2008-10 (C) Tom Parker
// <thpr@users.sourceforge.net> Copyright 2003 (C) David Hibbs
// <sage_sam@users.sourceforge.net> Copyright 2001 (C) Bryan McRoberts
// <merton_monk@yahoo.com>
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
// Translation of pcgen.persistence.lst.GlobalModifierLoader

import '../../rules/context/load_context.dart';
import 'lst_line_file_loader.dart';

/// Loads global modifier definitions from a globalmodifier.lst file.
///
/// Each line must be a single TOKEN:value (no tabs allowed per Java impl).
/// The tokens are applied to a singleton "Global Modifiers" object in the
/// reference context.
class GlobalModifierLoader extends LstLineFileLoader {
  static const String globalModifiersName = 'Global Modifiers';

  @override
  void parseLine(dynamic context, String lstLine, Uri sourceUri) {
    if (lstLine.isEmpty || lstLine.startsWith('#')) return;

    // GlobalModifier lines must not contain tabs
    if (lstLine.contains('\t')) {
      // errorPrint: tabs not allowed in global modifier file
      return;
    }

    final tok = lstLine.trim();
    final colonIdx = tok.indexOf(':');
    if (colonIdx <= 0) {
      // errorPrint: missing or leading colon
      return;
    }

    if (context is LoadContext) {
      // TODO: obtain GlobalModifiers object from context.getReferenceContext()
      //       and dispatch token via LstUtils.processToken
    }
  }
}
