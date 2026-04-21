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
// Translation of pcgen.cdom.helper.AbilityTargetSelector
import '../base/choose_driver.dart';
import '../base/choose_information.dart';
import '../base/choose_selection_actor.dart';
import '../base/concrete_prereq_object.dart';
import '../base/constants.dart';
import '../base/qualifying_object.dart';
import '../content/cn_ability_factory.dart';
import '../enumeration/nature.dart';
import '../enumeration/object_key.dart';
import '../reference/cdom_single_ref.dart';
import '../../core/ability.dart';
import '../../core/ability_category.dart';
import 'cn_ability_selection.dart';

// An AbilityTargetSelector applies a specific Ability (known at construction)
// with a runtime-chosen selection to a PlayerCharacter. Typically used by
// ADD:FEAT and similar tokens.
class AbilityTargetSelector<T> extends ConcretePrereqObject
    implements QualifyingObject, ChooseSelectionActor<T> {
  final String _source;
  final CDOMSingleRef<AbilityCategory> _category;
  final CDOMSingleRef<Ability> _ability;
  final Nature _nature;

  AbilityTargetSelector(
    String token,
    CDOMSingleRef<AbilityCategory> cat,
    CDOMSingleRef<Ability> abil,
    Nature nat,
  )   : _source = token,
        _category = cat,
        _ability = abil,
        _nature = nat;

  // Returns the CDOMSingleRef for the AbilityCategory.
  CDOMSingleRef<AbilityCategory> getAbilityCategory() => _category;

  // Returns the Nature with which the ability is applied.
  Nature getNature() => _nature;

  // Returns the resolved Ability.
  Ability getAbility() => _ability.get();

  // Returns a display string like "AbilityName(%LIST)".
  @override
  String toString() {
    return '${_ability.get().getDisplayName()}(${Constants.lstPercentList})';
  }

  // Applies the chosen selection to the PlayerCharacter via the ability's
  // ChooseInformation encoder.
  @override
  void applyChoice(ChooseDriver obj, T choice, dynamic pc) {
    final ab = _ability.get();
    final ci = ab.get(ObjectKey.chooseInfo) as ChooseInformation<T>?;
    if (ci != null) {
      _detailedApply(obj, ci, choice, pc);
    }
  }

  void _detailedApply(
      ChooseDriver obj, ChooseInformation<T> ci, T choice, dynamic pc) {
    final string = ci.encodeChoice(choice);
    final appliedSelection = CnAbilitySelection(
      CNAbilityFactory.getCNAbility(
        _category.get() as dynamic,
        _nature,
        _ability.get(),
      ),
      string,
    );
    appliedSelection.addAllPrerequisites(getPrerequisiteList());
    pc.addAbilitySelection(appliedSelection, obj, this);
  }

  @override
  String getLstFormat() => _ability.getLSTformat(false);

  @override
  String getSource() => _source;

  // Removes the choice from the PlayerCharacter.
  @override
  void removeChoice(ChooseDriver obj, T choice, dynamic pc) {
    final ab = _ability.get();
    final ci = ab.get(ObjectKey.chooseInfo) as ChooseInformation<T>?;
    if (ci != null) {
      _detailedRemove(obj, ci, choice, pc);
    }
  }

  void _detailedRemove(
      ChooseDriver obj, ChooseInformation<T> ci, T choice, dynamic pc) {
    final string = ci.encodeChoice(choice);
    final appliedSelection = CnAbilitySelection(
      CNAbilityFactory.getCNAbility(
        _category.get() as dynamic,
        _nature,
        _ability.get(),
      ),
      string,
    );
    pc.removeAbilitySelection(appliedSelection, obj, this);
  }

  @override
  int get hashCode => _ability.hashCode;

  @override
  bool operator ==(Object o) {
    if (o is AbilityTargetSelector) {
      return _source == o._source &&
          _category == o._category &&
          _ability == o._ability &&
          _nature == o._nature;
    }
    return false;
  }

  @override
  Type getChoiceClass() {
    final ci = _ability.get().get(ObjectKey.chooseInfo) as ChooseInformation?;
    return ci?.getReferenceClass() ?? dynamic;
  }
}
