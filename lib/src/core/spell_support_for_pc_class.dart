//
// SpellSupportForPCClass
// Copyright 2009 (c) Tom Parker <thpr@users.sourceforge.net>
// Copyright 2001 (C) Bryan McRoberts <merton_monk@yahoo.com>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.core.SpellSupportForPCClass
// SpellSupportForPCClass.dart
// Translated from pcgen/core/SpellSupportForPCClass.java

import 'player_character.dart';
import 'pc_class.dart';
import 'pc_stat.dart';
import 'globals.dart';
import 'domain.dart';
import 'character/character_spell.dart';
import 'spell/spell.dart';
import 'package:flutter_pcgen/src/cdom/base/constants.dart';
import 'package:flutter_pcgen/src/cdom/content/bonus_spell_info.dart';
import 'package:flutter_pcgen/src/cdom/content/known_spell_identifier.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/association_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/integer_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/object_key.dart';
import 'package:flutter_pcgen/src/cdom/inst/pc_class_level.dart';
import 'analysis/spell_count_calc.dart';
import 'spell_progression_cache.dart';

class SpellSupportForPCClass {
  /// castForLevelMap: key = spell level, value = number of spells castable per day
  Map<int, int>? _castForLevelMap;

  SpellProgressionCache? _spellCache;
  bool _spellCacheValid = false;

  final PCClass source;

  SpellSupportForPCClass(this.source);

  // ---------------------------------------------------------------------------
  // getMaxCastLevel
  // ---------------------------------------------------------------------------

  /// Get the highest level of spell that this class can cast (from the cache map).
  int getMaxCastLevel() {
    int currHighest = -1;
    if (_castForLevelMap != null) {
      for (final MapEntry<int, int> entry in _castForLevelMap!.entries) {
        final int value = entry.value;
        if (value > 0 && entry.key > currHighest) {
          currHighest = entry.key;
        }
      }
    }
    return currHighest;
  }

  /// Get the highest level of spell castable (builds the map first if needed).
  int getMaxCastLevelForPC(PlayerCharacter aPC) {
    _castForLevelMap ??= {};
    calcCastPerDayMapForLevel(aPC);
    return getMaxCastLevel();
  }

  // ---------------------------------------------------------------------------
  // SpellCache
  // ---------------------------------------------------------------------------

  List<dynamic>? getCastListForLevel(int aLevel) {
    if (!updateSpellCache(false)) return null;
    return _spellCache!.getCastForLevel(aLevel);
  }

  bool hasCastList() =>
      updateSpellCache(false) && _spellCache!.hasCastProgression();

  int getHighestLevelSpell() {
    if (!updateSpellCache(false)) return -1;
    return [
      _spellCache!.getHighestCastSpellLevel(),
      _spellCache!.getHighestKnownSpellLevel()
    ].reduce((a, b) => a > b ? a : b);
  }

  bool canCastSpells(PlayerCharacter aPC) {
    if (!updateSpellCache(false) || !_spellCache!.hasCastProgression()) {
      return false;
    }
    for (int i = 0; i < 100; i++) {
      if (getCastForLevel(i, aPC) > 0) return true;
    }
    return false;
  }

  // ---------------------------------------------------------------------------
  // Known spells
  // ---------------------------------------------------------------------------

  int getKnownForLevel(int spellLevel, PlayerCharacter aPC) {
    int total = 0;
    int stat = 0;
    final String classKeyName = 'CLASS.${source.getKeyName()}';
    final String levelSpellLevel = ';LEVEL.$spellLevel';
    final String allSpellLevel = ';LEVEL.All';

    int pcLevel = aPC.getLevel(source);
    pcLevel += aPC.getTotalBonusTo('PCLEVEL', source.getKeyName()).toInt();
    pcLevel +=
        aPC.getTotalBonusTo('PCLEVEL', 'TYPE.${source.getSpellType()}').toInt();

    if (updateSpellCache(false) &&
        _spellCache!.hasCastProgression() &&
        getNumFromCastList(pcLevel, spellLevel, aPC) < 0) {
      return aPC.getTotalBonusTo('SPELLKNOWN', classKeyName + levelSpellLevel).toInt();
    }

    total += aPC.getTotalBonusTo('SPELLKNOWN', classKeyName + levelSpellLevel).toInt();
    total +=
        aPC.getTotalBonusTo('SPELLKNOWN', 'TYPE.${source.getSpellType()}$levelSpellLevel').toInt();
    total += aPC.getTotalBonusTo('SPELLKNOWN', 'CLASS.Any$levelSpellLevel').toInt();
    total += aPC.getTotalBonusTo('SPELLKNOWN', classKeyName + allSpellLevel).toInt();
    total +=
        aPC.getTotalBonusTo('SPELLKNOWN', 'TYPE.${source.getSpellType()}$allSpellLevel').toInt();
    total += aPC.getTotalBonusTo('SPELLKNOWN', 'CLASS.Any$allSpellLevel').toInt();

    final PCStat? aStat = source.baseSpellStat();
    String statString = Constants.none;
    if (aStat != null) {
      stat = aPC.getTotalStatFor(aStat);
      statString = aStat.getKeyName();
    }

    final int bonusStat = aPC.getTotalBonusTo('STAT', 'KNOWN.$statString').toInt() +
        aPC.getTotalBonusTo('STAT', 'BASESPELLKNOWNSTAT').toInt() +
        aPC.getTotalBonusTo('STAT', 'BASESPELLKNOWNSTAT;CLASS=${source.getKeyName()}').toInt();

    if (!(source.getSafe(ObjectKey.useSpellSpellStat) as bool? ?? false) &&
        !(source.getSafe(ObjectKey.casterWithoutSpellStat) as bool? ?? false)) {
      final int maxSpellLevel =
          aPC.getVariableValue('MAXLEVELSTAT=$statString', '').toInt();
      if ((maxSpellLevel + bonusStat) < spellLevel) {
        return total;
      }
    }

    stat += bonusStat;
    int mult = aPC.getTotalBonusTo('SPELLKNOWNMULT', classKeyName + levelSpellLevel).toInt();
    mult +=
        aPC.getTotalBonusTo('SPELLKNOWNMULT', 'TYPE.${source.getSpellType()}$levelSpellLevel').toInt();
    if (mult < 1) mult = 1;

    if (!updateSpellCache(false)) return total;

    if (_spellCache!.hasKnownProgression()) {
      final List<dynamic>? knownList = _spellCache!.getKnownForLevel(pcLevel);
      if (spellLevel >= 0 && knownList != null && spellLevel < knownList.length) {
        total += mult * (knownList[spellLevel].resolve(aPC, '').toInt() as int);

        final BonusSpellInfo? bsi = Globals.getContext()
            .getReferenceContext()
            .silentlyGetConstructedCDOMObject(BonusSpellInfo, spellLevel.toString());

        if (Globals.checkRule('BONUSSPELLKNOWN') && bsi != null && bsi.isValid()) {
          final int base = bsi.getStatScore();
          if (stat >= base) {
            final int range = bsi.getStatRange();
            total += (((stat - base + range) / range) as double).floor().clamp(0, 0x7fffffff);
          }
        }
      }
    }

    if (total > 0 && spellLevel > 0) {
      total += source.getSafe(IntegerKey.knownSpellsFromSpecialty) as int? ?? 0;
      final int? assoc = aPC.getDomainSpellCount(source);
      if (assoc != null) total += assoc;
    }

    total += aPC.getKnownSpellCountForLevel(
        source.get(ObjectKey.classSpelllist), spellLevel);

    return total;
  }

  int getMinLevelForSpellLevel(int spellLevel, bool allowBonus) {
    if (!updateSpellCache(false)) return -1;
    return _spellCache!.getMinLevelForSpellLevel(spellLevel, allowBonus);
  }

  int getMaxSpellLevelForClassLevel(int classLevel) {
    if (!updateSpellCache(false)) return -1;
    return _spellCache!.getMaxSpellLevelForClassLevel(classLevel);
  }

  bool hasKnownList() =>
      updateSpellCache(false) && _spellCache!.hasKnownProgression();

  int getSpecialtyKnownForLevel(int spellLevel, PlayerCharacter aPC) {
    int total = aPC
        .getTotalBonusTo('SPECIALTYSPELLKNOWN',
            'CLASS.${source.getKeyName()};LEVEL.$spellLevel')
        .toInt();
    total += aPC
        .getTotalBonusTo('SPECIALTYSPELLKNOWN',
            'TYPE.${source.getSpellType()};LEVEL.$spellLevel')
        .toInt();

    int pcLevel = aPC.getLevel(source);
    pcLevel += aPC.getTotalBonusTo('PCLEVEL', source.getKeyName()).toInt();
    pcLevel +=
        aPC.getTotalBonusTo('PCLEVEL', 'TYPE.${source.getSpellType()}').toInt();

    final PCStat? aStat = source.baseSpellStat();
    if (aStat != null) {
      final int maxSpellLevel =
          aPC.getVariableValue('MAXLEVELSTAT=${aStat.getKeyName()}', '').toInt();
      if (spellLevel > maxSpellLevel) return total;
    }

    if (updateSpellCache(false)) {
      final List<dynamic>? specKnown = _spellCache!.getSpecialtyKnownForLevel(pcLevel);
      if (specKnown != null && specKnown.length > spellLevel) {
        total += specKnown[spellLevel].resolve(aPC, '').toInt() as int;
      }
    }

    total += source.getSafe(IntegerKey.knownSpellsFromSpecialty) as int? ?? 0;
    final int? assoc = aPC.getDomainSpellCount(source);
    if (assoc != null) total += assoc;

    return total;
  }

  bool updateSpellCache(bool force) {
    if (force || !_spellCacheValid) {
      final SpellProgressionCache cache = SpellProgressionCache();
      for (final PCClassLevel cl in source.getOriginalClassLevelCollection()) {
        final int? lvl = cl.getInt(IntegerKey.level) as int?;
        if (lvl == null) continue;
        final List<dynamic>? cast = cl.getListFor(ListKey.cast);
        if (cast != null) cache.setCast(lvl, cast);
        final List<dynamic>? known = cl.getListFor(ListKey.known);
        if (known != null) cache.setKnown(lvl, known);
        final List<dynamic>? spec = cl.getListFor(ListKey.specialtyKnown);
        if (spec != null) cache.setSpecialtyKnown(lvl, spec);
      }
      if (!cache.isEmpty()) {
        _spellCache = cache;
      }
      _spellCacheValid = true;
    }
    return _spellCache != null;
  }

  // ---------------------------------------------------------------------------
  // Cast per day
  // ---------------------------------------------------------------------------

  void calcCastPerDayMapForLevel(PlayerCharacter aPC) {
    _castForLevelMap ??= {};
    for (int i = 0; i < 100; i++) {
      final int s = getCastForLevel(i, aPC);
      _castForLevelMap![i] = s;
    }
  }

  bool isAutoKnownSpell(Spell aSpell, int spellLevel, bool useMap, PlayerCharacter aPC) {
    final List<KnownSpellIdentifier>? knownSpellsList =
        source.getListFor(ListKey.knownSpells) as List<KnownSpellIdentifier>?;
    if (knownSpellsList == null) return false;

    if (useMap) {
      final int? val = _castForLevelMap?[spellLevel];
      if (val == null || val == 0) return false;
    } else if (getCastForLevel(spellLevel, aPC) == 0) {
      return false;
    }

    if (SpellCountCalc.isProhibited(aSpell, source, aPC) &&
        !SpellCountCalc.isSpecialtySpell(aPC, source, aSpell)) {
      return false;
    }

    for (final KnownSpellIdentifier filter in knownSpellsList) {
      if (filter.matchesFilter(aSpell, spellLevel)) return true;
    }
    return false;
  }

  int getNumFromCastList(int iCasterLevel, int iSpellLevel, PlayerCharacter aPC) {
    if (iCasterLevel == 0) return -1;
    final List<dynamic>? castListForLevel = getCastListForLevel(iCasterLevel);
    if (castListForLevel == null || iSpellLevel >= castListForLevel.length) return -1;
    return castListForLevel[iSpellLevel].resolve(aPC, '').toInt() as int;
  }

  int getCastForLevel(int spellLevel, PlayerCharacter aPC) {
    return getCastForLevelFull(spellLevel, Globals.getDefaultSpellBook(), true, true, aPC);
  }

  int getCastForLevelFull(
    int spellLevel,
    String bookName,
    bool includeAdj,
    bool limitByStat,
    PlayerCharacter aPC,
  ) {
    int pcLevel = aPC.getLevel(source);
    int total = 0;
    int stat = 0;
    final String classKeyName = 'CLASS.${source.getKeyName()}';
    final String levelSpellLevel = ';LEVEL.$spellLevel';
    final String allSpellLevel = ';LEVEL.All';

    pcLevel += aPC.getTotalBonusTo('PCLEVEL', source.getKeyName()).toInt();
    pcLevel +=
        aPC.getTotalBonusTo('PCLEVEL', 'TYPE.${source.getSpellType()}').toInt();

    final PCStat? aStat = source.bonusSpellStat();
    String statString = Constants.none;
    if (aStat != null) {
      stat = aPC.getTotalStatFor(aStat);
      statString = aStat.getKeyName();
    }

    final int bonusStat =
        aPC.getTotalBonusTo('STAT', 'CAST.$statString').toInt() +
            aPC.getTotalBonusTo('STAT', 'BASESPELLSTAT').toInt() +
            aPC
                .getTotalBonusTo('STAT', 'BASESPELLSTAT;CLASS=${source.getKeyName()}')
                .toInt();

    if (getNumFromCastList(pcLevel, spellLevel, aPC) < 0) {
      total = aPC.getTotalBonusTo('SPELLCAST', classKeyName + levelSpellLevel).toInt();
      if (total > 0) {
        final BonusSpellInfo? bsi = Globals.getContext()
            .getReferenceContext()
            .silentlyGetConstructedCDOMObject(BonusSpellInfo, spellLevel.toString());
        if (bsi != null && bsi.isValid()) {
          final int base = bsi.getStatScore();
          stat += bonusStat;
          if (stat >= base) {
            final int range = bsi.getStatRange();
            total += (((stat - base + range) / range) as double).floor().clamp(0, 0x7fffffff);
          }
        }
      }
      return total;
    }

    total += aPC.getTotalBonusTo('SPELLCAST', classKeyName + levelSpellLevel).toInt();
    total +=
        aPC.getTotalBonusTo('SPELLCAST', 'TYPE.${source.getSpellType()}$levelSpellLevel').toInt();
    total += aPC.getTotalBonusTo('SPELLCAST', 'CLASS.Any$levelSpellLevel').toInt();
    total += aPC.getTotalBonusTo('SPELLCAST', classKeyName + allSpellLevel).toInt();
    total +=
        aPC.getTotalBonusTo('SPELLCAST', 'TYPE.${source.getSpellType()}$allSpellLevel').toInt();
    total += aPC.getTotalBonusTo('SPELLCAST', 'CLASS.Any$allSpellLevel').toInt();

    if (limitByStat) {
      final PCStat? ss = source.baseSpellStat();
      if (ss != null) {
        final int maxSpellLevel =
            aPC.getVariableValue('MAXLEVELSTAT=${ss.getKeyName()}', '').toInt();
        if ((maxSpellLevel + bonusStat) < spellLevel) {
          return total;
        }
      }
    }

    stat += bonusStat;

    // Specialty slots
    int adj = 0;
    if (includeAdj &&
        bookName != Globals.getDefaultSpellBook() &&
        (aPC.hasAssocs(source, AssociationKey.specialty) || aPC.hasDomains())) {
      for (int ix = 0; ix <= spellLevel; ++ix) {
        final List<CharacterSpell> aList = aPC.getCharacterSpells(source, ix);
        List<Spell> bList = [];
        if (aList.isNotEmpty) {
          if (ix > 0 &&
              source.getSpellType().toLowerCase() == 'divine') {
            for (final Domain d in aPC.getDomainSet()) {
              if (source.getKeyName() ==
                  aPC.getDomainSource(d).getPcclass().getKeyName()) {
                bList = aPC.getSpellsIn(
                    d.get(ObjectKey.domainSpelllist) as dynamic, ix);
              }
            }
          }
          for (final CharacterSpell cs in aList) {
            int x = -1;
            if (bList.isNotEmpty) {
              if (bList.contains(cs.getSpell())) x = 0;
            } else {
              x = cs.getInfoIndexFor(aPC, '', ix, 1);
            }
            if (x > -1) {
              PCClass target = source;
              final String? subClassKey = aPC.getSubClassName(source);
              if (subClassKey != null &&
                  subClassKey.isNotEmpty &&
                  subClassKey != Constants.none) {
                target = source.getSubClassKeyed(subClassKey) ?? source;
              }
              adj = aPC.getSpellSupport(target).getSpecialtyKnownForLevel(spellLevel, aPC);
              break;
            }
          }
        }
        if (adj > 0) break;
      }
    }

    int mult = aPC.getTotalBonusTo('SPELLCASTMULT', classKeyName + levelSpellLevel).toInt();
    mult +=
        aPC.getTotalBonusTo('SPELLCASTMULT', 'TYPE.${source.getSpellType()}$levelSpellLevel').toInt();
    if (mult < 1) mult = 1;

    final int t = getNumFromCastList(pcLevel, spellLevel, aPC);
    total += (t * mult) + adj;

    final BonusSpellInfo? bsi = Globals.getContext()
        .getReferenceContext()
        .silentlyGetConstructedCDOMObject(BonusSpellInfo, spellLevel.toString());
    if (bsi != null && bsi.isValid()) {
      final int base = bsi.getStatScore();
      if (stat >= base) {
        final int range = bsi.getStatRange();
        total += (((stat - base + range) / range) as double).floor().clamp(0, 0x7fffffff);
      }
    }

    return total;
  }

  int getHighestLevelSpellForPC(PlayerCharacter pc) {
    final String classKeyName = 'CLASS.${source.getKeyName()}';
    final int mapHigh = getHighestLevelSpell();
    int high = mapHigh;
    for (int i = mapHigh; i < mapHigh + 30; i++) {
      final String levelSpellLevel = ';LEVEL.$i';
      if (pc.getTotalBonusTo('SPELLCAST', classKeyName + levelSpellLevel) > 0) {
        high = i;
      } else if (pc.getTotalBonusTo('SPELLKNOWN', classKeyName + levelSpellLevel) > 0) {
        high = i;
      }
    }
    return high;
  }

  String getBonusCastForLevelString(int spellLevel, String bookName, PlayerCharacter aPC) {
    if (getCastForLevelFull(spellLevel, bookName, true, true, aPC) > 0) {
      if (aPC.hasAssocs(source, AssociationKey.specialty)) {
        PCClass target = source;
        final String? subClassKey = aPC.getSubClassName(source);
        if (subClassKey != null &&
            subClassKey.isNotEmpty &&
            subClassKey != Constants.none) {
          target = source.getSubClassKeyed(subClassKey) ?? source;
        }
        return '+${aPC.getSpellSupport(target).getSpecialtyKnownForLevel(spellLevel, aPC)}';
      }

      if (!aPC.hasDomains()) return '';

      if (spellLevel > 0 && source.getSpellType().toLowerCase() == 'divine') {
        for (final Domain d in aPC.getDomainSet()) {
          if (source.getKeyName() ==
              aPC.getDomainSource(d).getPcclass().getKeyName()) {
            return '+1';
          }
        }
      }
    }
    return '';
  }

  bool hasKnownSpells(PlayerCharacter aPC) {
    for (int i = 0; i <= getHighestLevelSpell(); i++) {
      if (getKnownForLevel(i, aPC) > 0) return true;
    }
    return false;
  }
}
