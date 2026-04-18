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
