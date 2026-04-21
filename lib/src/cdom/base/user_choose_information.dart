//
// Copyright 2010 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.base.UserChooseInformation
import 'package:flutter_pcgen/src/core/player_character.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/association_list_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/grouping_state.dart';
import 'package:flutter_pcgen/src/cdom/base/choose_driver.dart';
import 'package:flutter_pcgen/src/cdom/base/choose_information.dart';
import 'package:flutter_pcgen/src/cdom/base/choose_information_utilities.dart';
import 'package:flutter_pcgen/src/cdom/base/chooser.dart';
import 'package:flutter_pcgen/src/cdom/base/choose_selection_actor.dart';

// ChooseInformation that accepts free-text user input.
class UserChooseInformation
    implements ChooseInformation<String>, Chooser<String> {
  static const String uciName = 'User Input';

  String? _title;

  @override
  String getName() => uciName;

  @override
  String getTitle() => _title ?? 'Provide User Input';

  void setTitle(String chooseTitle) => _title = chooseTitle;

  @override
  String getLSTformat([bool useAny = false]) => '*USERINPUT';

  @override
  GroupingState getGroupingState() => GroupingState.allowsNone;

  @override
  bool allowsPersistentStorage() => true;

  @override
  Type getReferenceClass() => String;

  @override
  List<String> getSet(dynamic pc, [dynamic driver]) => ['USERINPUT'];

  @override
  String composeDisplay(List<dynamic> collection) =>
      ChooseInformationUtilities.buildEncodedString(collection);

  @override
  void restoreChoice(dynamic pc, dynamic owner, String choice) {
    final aPC = pc as PlayerCharacter;
    aPC.addAssoc(owner as ChooseDriver, _listKey(), choice);
  }

  @override
  List<String> getCurrentlySelected(ChooseDriver owner, dynamic pc) =>
      (pc as PlayerCharacter).getAssocList(owner, _listKey()) ?? [];

  @override
  void applyChoice(ChooseDriver owner, String choice, dynamic pc) {
    restoreChoice(pc, owner, choice);
    final actors = owner.getActors();
    if (actors != null) {
      for (final csa in actors) {
        (csa as ChooseSelectionActor<String>).applyChoice(owner, choice, pc);
      }
    }
  }

  @override
  void removeChoice(dynamic pc, ChooseDriver owner, String choice) {
    final aPC = pc as PlayerCharacter;
    aPC.removeAssoc(owner, _listKey(), choice);
    final actors = owner.getActors();
    if (actors != null) {
      for (final csa in actors) {
        (csa as ChooseSelectionActor<String>).removeChoice(owner, choice, pc);
      }
    }
  }

  @override
  Chooser<String> getChoiceActor() => this;

  @override
  void setChoiceActor(dynamic actor) {} // ignored — self is the actor

  @override
  bool allow(String choice, dynamic pc, bool allowStack) => true;

  @override
  String decodeChoice(dynamic context, String choice) => choice;

  @override
  String encodeChoice(String choice) => choice;

  @override
  dynamic getChoiceManager(ChooseDriver owner, int cost) =>
      null; // UserInputManager stub

  @override
  String getPersistentFormat() => 'STRING';

  @override
  String? encodeChoiceOrNull(String choice) => choice;

  static AssociationListKey<String> _listKey() =>
      AssociationListKey.getKeyFor(String, 'CHOOSE*USERCHOICE');
}
