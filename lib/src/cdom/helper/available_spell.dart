import '../base/cdom_list.dart';
import '../base/concrete_prereq_object.dart';
import '../../core/spell/spell.dart';

// Associates a spell with a spell list and level — used to track available spells.
class AvailableSpell extends ConcretePrereqObject {
  final CDOMList<Spell> spelllist;
  final Spell spell;
  final int level;

  AvailableSpell(this.spelllist, this.spell, this.level);
}
