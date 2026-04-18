import '../../../cdom/enumeration/integer_key.dart';
import '../../../cdom/enumeration/list_key.dart';
import '../../../cdom/enumeration/object_key.dart';
import '../../player_character.dart';
import '../../pc_class.dart';
import 'bonus_activation.dart';
import 'spell_level.dart';

// Applies or removes a Domain from a PlayerCharacter, including domain spells.
final class DomainApplication {
  DomainApplication._();

  static void applyDomain(PlayerCharacter pc, dynamic d) {
    final source = pc.getDomainSource(d);
    final aClass = pc.getClassKeyed(source.getPcclass().getKeyName());
    if (aClass != null) {
      int maxLevel = 0;
      for (; maxLevel < 10; maxLevel++) {
        if (pc.getSpellSupport(aClass).getCastForLevel(maxLevel, pc) == 0) break;
      }

      if (maxLevel > 0) {
        addSpellsToClassForLevels(pc, d, aClass, 0, maxLevel - 1);
      }

      if (maxLevel > 1 &&
          aClass.getSafe(IntegerKey.knownSpellsFromSpecialty) == 0) {
        final domainSpellList = d.get(ObjectKey.domainSpellList);
        final aList = pc.getAllSpellsInLists([domainSpellList]);
        for (final gcs in aList) {
          if (SpellLevel.getFirstLvlForKey(gcs, domainSpellList, pc) < maxLevel) {
            pc.setDomainSpellCount(aClass, 1);
            break;
          }
        }
      }
    }

    for (final ref in d.getSafeListMods(/* Spell.SPELLS */ 'SPELLS')) {
      final spells = ref.getContainedObjects();
      final assoc = d.getListAssociations('SPELLS', ref);
      for (final apo in assoc) {
        if (!_prereqsPassed(apo, pc, d)) continue;
        for (final s in spells) {
          final book = apo.getAssociation('SPELLBOOK');
          final aList = pc.getCharacterSpells(aClass, s, book, -1);
          if (aList.isEmpty) {
            final times = apo.getAssociation('TIMES_PER_UNIT');
            final cs = _newCharacterSpell(d, s);
            final resolvedTimes = times.resolve(pc, d.getQualifiedKey()).toInt();
            cs.addInfo(1, resolvedTimes, book);
            pc.addCharacterSpell(aClass, cs);
          }
        }
      }
    }
  }

  static void removeDomain(PlayerCharacter pc, dynamic domain) {
    final source = pc.getDomainSource(domain);
    final aClass = pc.getClassKeyed(source.getPcclass().getKeyName());

    if (aClass != null) {
      int maxLevel = 0;
      for (; maxLevel < 10; maxLevel++) {
        if (pc.getSpellSupport(aClass).getCastForLevel(maxLevel, pc) == 0) break;
      }
      if (maxLevel > 0) {
        removeSpellsFromClassForLevels(pc, domain, aClass);
      }
      if (maxLevel > 1 &&
          aClass.getSafe(IntegerKey.knownSpellsFromSpecialty) == 0) {
        final domainSpellList = domain.get(ObjectKey.domainSpellList);
        final aList = pc.getAllSpellsInLists([domainSpellList]);
        for (final gcs in aList) {
          if (SpellLevel.getFirstLvlForKey(gcs, domainSpellList, pc) < maxLevel) {
            pc.removeDomainSpellCount(aClass);
            break;
          }
        }
      }
    }

    if (!pc.isImporting()) {
      BonusActivation.deactivateBonuses(domain, pc);
    }
  }

  static void removeSpellsFromClassForLevels(
      PlayerCharacter pc, dynamic domain, PCClass aClass) {
    for (final cs in List.from(pc.getCharacterSpells(aClass))) {
      if (cs.getOwner() == domain) {
        pc.removeCharacterSpell(aClass, cs);
      }
    }
  }

  static void addSpellsToClassForLevels(
      PlayerCharacter pc, dynamic d, PCClass aClass, int minLevel, int maxLevel) {
    if (aClass == null) return;
    final defaultBook = _getDefaultSpellBook();
    for (int aLevel = minLevel; aLevel <= maxLevel; aLevel++) {
      final domainSpells =
          pc.getSpellsIn(d.get(ObjectKey.domainSpellList), aLevel);
      for (final spell in domainSpells) {
        final slist = pc.getCharacterSpells(aClass, spell, defaultBook, aLevel);
        bool flag = true;
        for (final cs1 in slist) {
          if (cs1.getOwner() == d) {
            flag = false;
            break;
          }
        }
        if (flag) {
          final cs = _newCharacterSpell(d, spell);
          cs.addInfo(aLevel, 1, defaultBook);
          pc.addCharacterSpell(aClass, cs);
        }
      }
    }
  }

  static void addDomainsUpToLevel(
      PCClass cl, int aLevel, PlayerCharacter aPC) {
    if (aPC.isImporting()) return;
    for (final qo in cl.getSafeListFor(ListKey.domain)) {
      final ref = qo.getObject(aPC, cl);
      if (ref != null) _addDomain(aPC, cl, ref.get());
    }
    for (int i = 0; i <= aLevel; i++) {
      final pcl = aPC.getActiveClassLevel(cl, i);
      for (final qo in pcl.getSafeListFor(ListKey.domain)) {
        final ref = qo.getObject(aPC, cl);
        if (ref != null) _addDomain(aPC, cl, ref.get());
      }
    }
  }

  static void removeDomainsForLevel(
      PCClass cl, int removedLevel, PlayerCharacter aPC) {
    for (final qo in cl.getSafeListFor(ListKey.domain)) {
      dynamic ref = qo.getObject(aPC, cl);
      if (ref == null) {
        ref = qo.getRawObject();
        aPC.removeDomain(ref.get());
      }
    }
    for (int i = 0; i <= removedLevel; i++) {
      final pcl = aPC.getActiveClassLevel(cl, i);
      for (final qo in pcl.getSafeListFor(ListKey.domain)) {
        dynamic ref = qo.getObject(aPC, cl);
        if (ref == null || i == removedLevel) {
          ref = qo.getRawObject();
          aPC.removeDomain(ref.get());
        }
      }
    }
  }

  static void _addDomain(PlayerCharacter aPC, PCClass cl, dynamic d) {
    if (d.qualifies(aPC, d)) {
      final cs = _newClassSource(cl, aPC.getLevel(cl));
      aPC.addDomain(d, cs);
      applyDomain(aPC, d);
    }
  }

  static bool _prereqsPassed(dynamic apo, dynamic pc, dynamic d) => true; // stub
  static dynamic _newCharacterSpell(dynamic owner, dynamic spell) => null; // stub
  static String _getDefaultSpellBook() => ''; // stub
  static dynamic _newClassSource(dynamic cl, int level) => null; // stub
}
