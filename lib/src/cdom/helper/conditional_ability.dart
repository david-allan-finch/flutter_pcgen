import '../base/associated_prereq_object.dart';
import '../base/cdom_object.dart';
import '../../core/ability.dart';

// Holds an Ability, its AssociatedPrereqObject, and its parent CDOMObject.
class ConditionalAbility {
  final Ability _ability;
  final AssociatedPrereqObject _assoc;
  final CDOMObject _parent;

  ConditionalAbility(Ability abil, AssociatedPrereqObject apo, CDOMObject cdo)
      : _ability = abil,
        _assoc = apo,
        _parent = cdo;

  CDOMObject getParent() => _parent;
  AssociatedPrereqObject getAPO() => _assoc;
  Ability getAbility() => _ability;
}
