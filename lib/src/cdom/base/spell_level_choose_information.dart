//
// Copyright 2007, 2008 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.base.SpellLevelChooseInformation
import 'package:flutter_pcgen/src/core/player_character.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/grouping_state.dart';
import 'package:flutter_pcgen/src/cdom/helper/spell_level.dart';
import 'package:flutter_pcgen/src/cdom/helper/spell_level_info.dart';
import 'package:flutter_pcgen/src/cdom/base/choose_driver.dart';
import 'package:flutter_pcgen/src/cdom/base/choose_information.dart';
import 'package:flutter_pcgen/src/cdom/base/choose_information_utilities.dart';
import 'package:flutter_pcgen/src/cdom/base/chooser.dart';
import 'package:flutter_pcgen/src/cdom/base/constants.dart';

// ChooseInformation for spell-level selections.
class SpellLevelChooseInformation implements ChooseInformation<SpellLevel> {
  final List<SpellLevelInfo> info;
  final String setName;
  String? title;
  Chooser<SpellLevel>? choiceActor;

  SpellLevelChooseInformation(String name, List<SpellLevelInfo> choice)
      : setName = name,
        info = List.from(choice) {
    if (info.isEmpty) {
      throw ArgumentError('PrimitiveChoiceSet cannot be empty');
    }
  }

  @override
  void setChoiceActor(dynamic actor) => choiceActor = actor as Chooser<SpellLevel>;

  @override
  Chooser<SpellLevel>? getChoiceActor() => choiceActor;

  @override
  String encodeChoice(SpellLevel choice) => choiceActor!.encodeChoice(choice);

  @override
  SpellLevel decodeChoice(dynamic context, String persistenceFormat) =>
      choiceActor!.decodeChoice(context, persistenceFormat);

  @override
  bool allowsPersistentStorage() => false;

  @override
  Type getReferenceClass() => SpellLevel;

  @override
  List<SpellLevel> getSet(dynamic pc, [dynamic driver]) {
    final aPC = pc as PlayerCharacter;
    final set = <SpellLevel>{};
    for (final sli in info) {
      set.addAll(sli.getLevels(aPC));
    }
    return set.toList();
  }

  @override
  String getName() => setName;

  @override
  String getTitle() => title ?? setName;

  void setTitleStr(String choiceTitle) => title = choiceTitle;

  @override
  String getLSTformat([bool useAny = false]) => info.join(Constants.pipe);

  @override
  GroupingState getGroupingState() => GroupingState.allowsNone;

  @override
  void restoreChoice(dynamic pc, dynamic owner, SpellLevel choice) =>
      choiceActor?.restoreChoice(pc, owner as ChooseDriver, choice);

  @override
  void removeChoice(PlayerCharacter pc, ChooseDriver owner, SpellLevel choice) =>
      choiceActor?.removeChoice(pc, owner, choice);

  @override
  dynamic getChoiceManager(ChooseDriver owner, int cost) =>
      null; // CDOMChoiceManager stub

  @override
  String composeDisplay(List<dynamic> collection) =>
      ChooseInformationUtilities.buildEncodedString(collection);

  @override
  String getPersistentFormat() => 'INVALID*NOT*PERSISTENT*';

  @override
  int get hashCode => setName.hashCode + 29;

  @override
  bool operator ==(Object obj) {
    if (obj is SpellLevelChooseInformation) {
      if (title != obj.title) return false;
      return setName == obj.setName && info == obj.info;
    }
    return false;
  }
}
