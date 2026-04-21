//
// Copyright 2008 (C) Tom Parker <thpr@users.sourceforge.net>
// Copyright 2001 (C) Bryan McRoberts <merton_monk@yahoo.com>
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
// Translation of pcgen.core.analysis.QualifiedName
import 'package:flutter_pcgen/src/cdom/base/choose_information.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/object_key.dart';
import 'package:flutter_pcgen/src/core/player_character.dart';
import 'package:flutter_pcgen/src/core/skill.dart';
import 'output_name_formatting.dart';

// Produces qualified display names for Abilities and Skills (with sub-choices).
final class QualifiedName {
  QualifiedName._();

  static String qualifiedNameForAbilities(dynamic pc, List<dynamic> list) {
    // dynamic = PlayerCharacter, list = List<CNAbility>
    final a = _validateCNAList(list);
    if (a == null) return '';
    final outputName = OutputNameFormatting.getOutputName(a);
    if ('[BASE]'.toLowerCase() == outputName.toLowerCase()) {
      return a.getDisplayName();
    }
    final buf = StringBuffer(outputName);
    final chooseInfo = a.getObject(ObjectKey.chooseInfo) as ChooseInformation?;
    if (chooseInfo != null) {
      _processChooseInfo(buf, pc, chooseInfo, list);
    }
    return buf.toString();
  }

  static void _processChooseInfo(
      StringBuffer buf, dynamic pc, ChooseInformation chooseInfo, List<dynamic> list) {
    final allSelections = [];
    for (final cna in list) {
      if (pc.hasAssociations(cna)) {
        allSelections.addAll(pc.getDetailedAssociations(cna));
      }
    }
    final choiceInfo = chooseInfo.composeDisplay(allSelections).toString();
    if (choiceInfo.isNotEmpty) {
      buf.write(' (');
      buf.write(choiceInfo);
      buf.write(')');
    }
  }

  static String qualifiedNameForSkill(dynamic pc, Skill s) {
    final outputName = OutputNameFormatting.getOutputName(s);
    if (!pc.hasAssociations(s)) return outputName;

    final assocList = List<String>.from(pc.getAssociationList(s))..sort();
    return '$outputName(${assocList.join(', ')})';
  }

  static dynamic _validateCNAList(List<dynamic> list) =>
      list.isEmpty ? null : list.first.getAbility();
}
