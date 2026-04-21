//
// Copyright 2016 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.rules.persistence.CodeControlLoader
import '../../rules/context/load_context.dart';

// Loader for Code Control Definitions.
class CodeControlLoader {
  void parseLine(LoadContext context, String inputLine, String sourceURI) {
    final sepLoc = inputLine.indexOf('\t');
    if (sepLoc != -1) {
      // log: Unsure what to do with line with multiple tokens
      return;
    }
    final refContext = context.getReferenceContext();
    final controller =
        refContext.constructNowIfNecessary(dynamic, 'Controller'); // CodeControl
    // stub — LstUtils.processToken not yet translated
  }
}
