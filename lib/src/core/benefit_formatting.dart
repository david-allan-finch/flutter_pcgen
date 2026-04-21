//
// Missing License Header, Copyright 2016 (C) Andrew Maitland <amaitland@users.sourceforge.net>
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
// Translation of pcgen.core.BenefitFormatting
import 'package:flutter_pcgen/src/cdom/content/cn_ability.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/core/description.dart';
import 'package:flutter_pcgen/src/core/player_character.dart';
import 'package:flutter_pcgen/src/core/pcobject.dart';

final class BenefitFormatting {
  BenefitFormatting._();

  static String getBenefits(PlayerCharacter aPC, List<Object> objList) {
    if (objList.isEmpty) return '';
    final b = objList.first;
    final PObject sampleObject;
    if (b is PObject) {
      sampleObject = b;
    } else if (b is CNAbility) {
      sampleObject = b.getAbility();
    } else {
      return '';
    }
    final theBenefits =
        sampleObject.getListFor(ListKey.benefit) as List<Description>?;
    if (theBenefits == null) return '';
    final buf = StringBuffer();
    bool needSpace = false;
    for (final desc in theBenefits) {
      final str = desc.getDescription(aPC, objList);
      if (str.isNotEmpty) {
        if (needSpace) buf.write(' ');
        buf.write(str);
        needSpace = true;
      }
    }
    return buf.toString();
  }
}
