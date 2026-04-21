//
// Copyright 2018 (C) Tom Parker <thpr@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or modify it under the terms
// of the GNU Lesser General Public License as published by the Free Software Foundation;
// either version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along with
// this library; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
// Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.cdom.helper.InfoUtilities
import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/map_key.dart';

// Utilities for INFOVARS token evaluation.
final class InfoUtilities {
  InfoUtilities._();

  static List<Object?> getInfoVars(dynamic id, CDOMObject cdo, String cis) {
    final vars = cdo.get(MapKey.infoVars, cis) as List<String>?;
    final varCount = vars?.length ?? 0;
    if (varCount == 0) return [];
    // resultFacet.getLocalVariable stub
    return List.filled(varCount, null);
  }
}
