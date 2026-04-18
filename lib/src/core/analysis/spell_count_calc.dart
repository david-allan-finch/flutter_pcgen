import '../pc_class.dart';
import '../player_character.dart';
import '../character/character_spell.dart';
import '../spell.dart';

abstract final class SpellCountCalc {
  static int memorizedSpellForLevelBook(PlayerCharacter pc, PCClass cl, int aLevel, String bookName) {
    final aList = pc.getCharacterSpells(cl, null, bookName, aLevel);
    if (aList.isEmpty) return 0;
    int total = 0;
    for (final cs in aList) {
      final info = cs.getSpellInfoFor(bookName, aLevel);
      if (info != null) total += info.times;
    }
    return total;
  }

  static int memorizedSpecialtiesForLevelBook(int aLevel, String bookName, PlayerCharacter pc, PCClass cl) {
    final aList = pc.getCharacterSpells(cl, null, bookName, aLevel);
    if (aList.isEmpty) return 0;
    int total = 0;
    for (final cs in aList) {
      if (cs.isSpecialtySpell(pc)) {
        final info = cs.getSpellInfoFor(bookName, aLevel);
        if (info != null) total += info.times;
      }
    }
    return total;
  }

  static bool isSpecialtySpell(PlayerCharacter pc, PCClass cl, Spell aSpell) {
    final specialty = pc.getAssoc(cl, 'SPECIALTY');
    if (specialty != null) {
      // Check if the spell belongs to the specialty school, subschool, or descriptor
      return aSpell.containsSpellSchool(specialty) ||
          aSpell.containsSpellSubschool(specialty) ||
          aSpell.containsSpellDescriptor(specialty);
    }
    return false;
  }

  static bool isProhibited(Spell aSpell, PCClass cl, PlayerCharacter aPC) {
    if (!aSpell.qualifies(aPC, aSpell)) return true;
    return aPC.getProhibitedSchools(cl).any((prohibit) => prohibit.isProhibited(aSpell, aPC, cl));
  }
}
