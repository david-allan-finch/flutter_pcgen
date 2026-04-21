//
// Copyright (c) 2008 Tom Parker <thpr@users.sourceforge.net>
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
//
// Translation of pcgen.cdom.helper.AbilitySelector
import '../base/choose_driver.dart';
import '../base/choose_selection_actor.dart';
import '../base/concrete_prereq_object.dart';
import '../base/qualifying_object.dart';
import '../content/ability_selection.dart';
import '../content/cn_ability_factory.dart';
import '../enumeration/nature.dart';
import '../reference/cdom_single_ref.dart';
import '../../core/ability_category.dart';
import 'cn_ability_selection.dart';

// An AbilitySelector applies an AbilitySelection (category + nature + ability
// chosen via CHOOSE) to a PlayerCharacter, as used in AUTO:FEAT|%LIST.
class AbilitySelector extends ConcretePrereqObject
    implements QualifyingObject, ChooseSelectionActor<AbilitySelection> {
  final String _source;
  final CDOMSingleRef<AbilityCategory> _category;
  final Nature _nature;

  AbilitySelector(
    String token,
    CDOMSingleRef<AbilityCategory> cat,
    Nature nat,
  )   : _source = token,
        _category = cat,
        _nature = nat;

  // Returns the CDOMSingleRef for the AbilityCategory.
  CDOMSingleRef<AbilityCategory> getAbilityCategory() => _category;

  // Returns the Nature with which abilities are applied.
  Nature getNature() => _nature;

  // Applies the chosen AbilitySelection to the PlayerCharacter.
  @override
  void applyChoice(ChooseDriver obj, AbilitySelection as_, dynamic pc) {
    final cna = CNAbilityFactory.getCNAbility(
      _category.get() as dynamic,
      _nature,
      as_.getObject(),
    );
    final cnas = CnAbilitySelection(cna, as_.getSelection());
    pc.associateSelection(as_, cnas);
    pc.addAbilitySelection(cnas, obj, this);
  }

  @override
  String getLstFormat() => '%LIST';

  // Removes the previously applied AbilitySelection from the PlayerCharacter.
  @override
  void removeChoice(ChooseDriver obj, AbilitySelection as_, dynamic pc) {
    final cnas = pc.getAssociatedSelection(as_);
    if (cnas == null) {
      // Unexpected null — log a warning but do not crash.
      // ignore: avoid_print
      print('WARNING: Unexpected: Found null CNAS');
    } else {
      pc.removeAbilitySelection(cnas, obj, this);
    }
  }

  @override
  String getSource() => _source;

  @override
  int get hashCode => _category.hashCode ^ _nature.hashCode;

  @override
  bool operator ==(Object o) {
    if (o is AbilitySelector) {
      return _source == o._source &&
          _category == o._category &&
          _nature == o._nature;
    }
    return false;
  }

  @override
  Type getChoiceClass() => AbilitySelection;
}
