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
// Translation of pcgen.gui2.converter.loader.AbilityLoader

import 'package:flutter_pcgen/src/gui2/converter/conversion_decider.dart';
import 'basic_loader.dart';

/// Extends [BasicLoader] with extra pre-processing for Ability files:
/// scans each line for a CATEGORY token and ensures the named
/// AbilityCategory is defined in the context before the base loader runs.
class AbilityLoader extends BasicLoader<dynamic> {
  AbilityLoader({
    required super.context,
    required super.listKey,
    required super.changeLogWriter,
  }) : super(cdomClass: dynamic);

  @override
  List<dynamic>? process(
    StringBuffer sb,
    int line,
    String lineString,
    ConversionDecider decider,
  ) {
    // Ensure the ability category is defined before processing tokens.
    final tokens = lineString.split(BasicLoader.fieldSeparator);
    for (final tok in tokens) {
      if (tok.startsWith('CATEGORY:')) {
        final abilityCatName = tok.substring(9);
        final refCtx = context.getReferenceContext();
        final existing = refCtx.silentlyGetConstructedCDOMObject(
          'AbilityCategory',
          abilityCatName,
        );
        if (existing == null) {
          refCtx.constructCDOMObject('AbilityCategory', abilityCatName);
        }
        break;
      }
    }
    return super.process(sb, line, lineString, decider);
  }
}
