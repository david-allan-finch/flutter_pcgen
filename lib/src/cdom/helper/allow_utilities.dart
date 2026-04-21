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
// Translation of pcgen.cdom.helper.AllowUtilities
import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/map_key.dart';
import 'package:flutter_pcgen/src/core/player_character.dart';
import 'package:flutter_pcgen/src/cdom/helper/info_boolean.dart';
import 'package:flutter_pcgen/src/cdom/helper/info_utilities.dart';

// Utilities for the ALLOW token — builds HTML text for allowed conditions.
final class AllowUtilities {
  AllowUtilities._();

  static String getAllowInfo(PlayerCharacter pc, CDOMObject cdo) {
    final allowItems = cdo.getListFor(ListKey.allow) as List<InfoBoolean>?;
    if (allowItems == null || allowItems.isEmpty) return '';

    final sb = StringBuffer();
    bool needSeparator = false;

    for (final infoBoolean in allowItems) {
      final info = cdo.get(MapKey.info, infoBoolean.getInfoName());
      if (info != null) {
        if (needSeparator) sb.write(' and ');
        needSeparator = true;
        final passes = pc.solve(infoBoolean.getFormula());
        if (!passes) sb.write('<i>');
        final infoVars =
            InfoUtilities.getInfoVars(pc.getCharID(), cdo, infoBoolean.getInfoName());
        sb.write(_htmlEscape(info.format(infoVars)));
        if (!passes) sb.write('</i>');
      }
    }
    return sb.toString();
  }

  static String _htmlEscape(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');
}
