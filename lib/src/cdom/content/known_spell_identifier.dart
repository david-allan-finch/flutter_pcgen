import '../../core/player_character.dart';
import '../../core/spell.dart';
import '../base/cdom_reference.dart';
import '../base/concrete_prereq_object.dart';
import '../list/class_spell_list.dart';

// Identifies Spell objects that are known at a specific spell level.
class KnownSpellIdentifier extends ConcretePrereqObject {
  final CDOMReference<Spell> ref;
  final int? spellLevel; // null = no level limit

  KnownSpellIdentifier(this.ref, this.spellLevel) {
    if (spellLevel != null && spellLevel! < 0) {
      throw ArgumentError('Known Spell Identifier level limit cannot be negative');
    }
  }

  bool matchesFilter(Spell spell, int testSpellLevel) {
    return ref.contains(spell) && (spellLevel == null || testSpellLevel == spellLevel);
  }

  CDOMReference<Spell> getSpellReference() => ref;
  int? getSpellLevel() => spellLevel;

  List<Spell> getContainedSpells(PlayerCharacter pc, List<ClassSpellList> classSpellLists) {
    final spellList = <Spell>[];
    for (final sp in ref.getContainedObjects()) {
      final hml = pc.getSpellLevelInfo(sp);
      for (final cdomList in hml.keys) {
        if (classSpellLists.contains(cdomList)) {
          final levels = hml[cdomList];
          if (spellLevel == null || (levels != null && levels.contains(spellLevel))) {
            spellList.add(sp);
          }
        }
      }
    }
    return spellList;
  }

  String getLSTformat() => ref.getLSTformat(false);

  @override
  int get hashCode => spellLevel == null ? ref.hashCode : spellLevel! * ref.hashCode;

  @override
  bool operator ==(Object obj) {
    if (identical(this, obj)) return true;
    if (obj is! KnownSpellIdentifier) return false;
    if (spellLevel == null) return obj.spellLevel == null && ref == obj.ref;
    if (ref == obj.ref) return false; // check ref equality if refs exist
    return spellLevel == obj.spellLevel && ref == obj.ref;
  }
}
