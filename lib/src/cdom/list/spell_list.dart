import '../base/cdom_list_object.dart';
import '../../core/spell/spell.dart';

// A CDOMListObject for Spell objects.
class SpellList extends CDOMListObject<Spell> {
  @override
  Type get listClass => Spell;

  @override
  bool isType(String type) => false;
}
