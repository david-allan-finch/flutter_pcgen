// PCGen PCG v2 character file format — read and write.
//
// Reference format from real PCGen files:
//   PCGVERSION:2.0
//   CAMPAIGN:Book1|CAMPAIGN:Book2
//   VERSION:6.09.07          ← PCGen app version (ignored on read)
//   STAT:STR|SCORE:16
//   ALIGN:LG
//   RACE:Human
//   CLASS:Fighter|SUBCLASS:None|LEVEL:5|...
//   CLASSABILITIESLEVEL:Fighter=1|HITPOINTS:10|SKILLSGAINED:2|...
//   SKILL:Climb|OUTPUTORDER:0|CLASSBOUGHT:[CLASS:Fighter|RANKS:5.0|COST:1|CLASSSKILL:Y]
//   ABILITY:FEAT|TYPE:NORMAL|CATEGORY:FEAT|KEY:Power Attack|TYPE:Combat|DESC:...
//   TEMPLATESAPPLIED:[NAME:Human]
//   EQUIPNAME:Longsword|OUTPUTORDER:0|COST:15.0|WT:4.0|QUANTITY:1.0
//   MONEY:0
//   CHARACTERBIO:text
//   CHARACTERDESC:text
//   SPELLBOOK:Class|TYPE:4
//   SPELLNAME:Fireball|TIMES:1|CLASS:Wizard|BOOK:Class|SPELLLEVEL:3|SOURCE:[TYPE:CLASS|NAME:Wizard]
//   NOTE:name|ID:1|PARENTID:-1|VALUE:text

import 'package:flutter_pcgen/src/gui2/facade/character_facade_impl.dart';

class PCGCharacterIO {
  static const String _pcgVersion = '2.0';
  static const String _appVersion = '8.00.00'; // reported app version

  // ---------------------------------------------------------------------------
  // Write
  // ---------------------------------------------------------------------------

  static String write(CharacterFacadeImpl character) {
    final buf = StringBuffer();
    final data = character.toJson();

    buf.writeln('PCGVERSION:$_pcgVersion');
    buf.writeln();

    // System info
    buf.writeln('# System Information');
    buf.writeln('VERSION:$_appVersion');
    buf.writeln('ROLLMETHOD:1|EXPRESSION:10');
    buf.writeln('PURCHASEPOINTS:N');
    buf.writeln('CHARACTERTYPE:PC');
    buf.writeln('POOLPOINTS:0');
    buf.writeln('POOLPOINTSAVAIL:0');
    buf.writeln('GAMEMODE:35e');
    buf.writeln('TABLABEL:0');
    buf.writeln('AUTOSPELLS:Y');
    buf.writeln('USEHIGHERKNOWN:N');
    buf.writeln('USEHIGHERPREPPED:N');
    buf.writeln('LOADCOMPANIONS:N');
    buf.writeln('USETEMPMODS:Y');
    buf.writeln('AUTOSORTGEAR:Y');
    buf.writeln('SKILLSOUTPUTORDER:0');
    buf.writeln('IGNORECOST:N');
    buf.writeln('ALLOWDEBT:N');
    buf.writeln('AUTORESIZEGEAR:N');
    buf.writeln();

    // Character bio
    buf.writeln('# Character Bio');
    buf.writeln('CHARACTERNAME:${_esc(character.getName())}');
    buf.writeln('TABNAME:');
    buf.writeln('PLAYERNAME:${_esc(character.getPlayersName())}');
    buf.writeln('HEIGHT:${data['height'] ?? 0}');
    buf.writeln('WEIGHT:${data['weight'] ?? 0}');
    buf.writeln('AGE:${data['age'] ?? 0}');
    buf.writeln('GENDER:${data['gender'] ?? ''}');
    buf.writeln('HANDED:Right');
    buf.writeln('SKINCOLOR:${data['skinColor'] ?? ''}');
    buf.writeln('EYECOLOR:${data['eyeColor'] ?? ''}');
    buf.writeln('HAIRCOLOR:${data['hairColor'] ?? ''}');
    buf.writeln('HAIRSTYLE:');
    buf.writeln('LOCATION:');
    buf.writeln('CITY:');
    buf.writeln('BIRTHDAY:');
    buf.writeln('BIRTHPLACE:');
    buf.writeln('PERSONALITYTRAIT1:');
    buf.writeln('PERSONALITYTRAIT2:');
    buf.writeln('PORTRAIT:');
    buf.writeln();

    // Attributes
    buf.writeln('# Character Attributes');
    final scores = data['statScores'] as Map? ?? {};
    for (final entry in scores.entries) {
      buf.writeln('STAT:${entry.key}|SCORE:${entry.value}');
    }
    final alignKey = data['alignmentKey'] as String? ?? '';
    if (alignKey.isNotEmpty) buf.writeln('ALIGN:$alignKey');
    final raceKey = data['raceKey'] as String? ?? '';
    if (raceKey.isNotEmpty) buf.writeln('RACE:$raceKey');
    buf.writeln();

    // Classes
    final classLevels = data['classLevels'] as List? ?? [];
    if (classLevels.isNotEmpty) {
      buf.writeln('# Character Class(es)');
      final counts = <String, int>{};
      final classNames = <String, String>{};
      for (final l in classLevels) {
        if (l is Map) {
          final k = l['classKey'] as String? ?? '';
          classNames[k] = l['className'] as String? ?? k;
          counts[k] = (counts[k] ?? 0) + 1;
        }
      }
      final classSpellBase = data['classSpellBase'] as Map? ?? {};
      for (final entry in counts.entries) {
        final spellBase = classSpellBase[entry.key] as String? ?? 'WIS';
        buf.writeln('CLASS:${entry.key}|SUBCLASS:None|LEVEL:${entry.value}'
            '|SKILLPOOL:0|SPELLBASE:$spellBase|CANCASTPERDAY:');
      }
      // Per-level lines
      final levelNums = <String, int>{};
      for (final l in classLevels) {
        if (l is Map) {
          final k = l['classKey'] as String? ?? '';
          levelNums[k] = (levelNums[k] ?? 0) + 1;
          final n = levelNums[k]!;
          final hp = (l['hp'] as num?)?.toInt() ?? 0;
          final skillsGained = (l['skillsGained'] as num?)?.toInt() ?? 0;
          final statGains = l['statGains'] as Map? ?? {};
          final buf2 = StringBuffer(
              'CLASSABILITIESLEVEL:$k=$n|HITPOINTS:$hp');
          for (final sg in statGains.entries) {
            buf2.write('|PRESTAT:${sg.key}=${sg.value}');
          }
          buf2.write('|SKILLSGAINED:$skillsGained');
          buf.writeln(buf2);
        }
      }
      buf.writeln();
    }

    // Experience
    final xp = data['xp'] as int? ?? 0;
    buf.writeln('# Character Experience');
    buf.writeln('EXPERIENCE:$xp');
    final xpTableName = data['xpTableName'] as String? ?? '';
    if (xpTableName.isNotEmpty) buf.writeln('EXPERIENCETABLE:$xpTableName');
    buf.writeln();

    // Templates
    final templates = data['appliedTemplates'] as List? ?? [];
    buf.writeln('# Character Templates');
    if (templates.isNotEmpty) {
      buf.writeln('TEMPLATESAPPLIED:${templates.map((t) => '[NAME:$t]').join('')}');
    }
    buf.writeln();

    // Skills
    final skillRanks = data['skillRanks'] as Map? ?? {};
    if (skillRanks.isNotEmpty) {
      buf.writeln('# Character Skills');
      int order = 1;
      for (final entry in skillRanks.entries) {
        final rank = (entry.value as num?)?.toDouble() ?? 0.0;
        if (rank > 0) {
          // Determine which class this skill belongs to (first class by default)
          final firstClass = classLevels.isNotEmpty && classLevels[0] is Map
              ? classLevels[0]['classKey'] as String? ?? ''
              : '';
          final classBought = firstClass.isNotEmpty
              ? '|CLASSBOUGHT:[CLASS:$firstClass|RANKS:$rank|COST:1|CLASSSKILL:Y]'
              : '';
          buf.writeln(
              'SKILL:${entry.key}|OUTPUTORDER:${order++}$classBought');
        } else {
          buf.writeln('SKILL:${entry.key}|OUTPUTORDER:${order++}|');
        }
      }
      buf.writeln();
    }

    // Languages
    final languages = data['languageKeys'] as List? ?? [];
    if (languages.isNotEmpty) {
      buf.writeln('# Character Languages');
      buf.writeln('LANGUAGE:${languages.join('|LANGUAGE:')}');
      buf.writeln();
    }

    // Abilities (feats + special abilities)
    final selectedAbilities = data['selectedAbilities'] as Map? ?? {};
    if (selectedAbilities.isNotEmpty) {
      buf.writeln('# Character Abilities');
      for (final catEntry in selectedAbilities.entries) {
        final category = catEntry.key as String;
        final keys = catEntry.value;
        if (keys is List) {
          for (final stored in keys) {
            final s = stored.toString();
            final sep = s.indexOf('|');
            final abilKey  = sep > 0 ? s.substring(0, sep) : s;
            final appliedTo = sep > 0 ? s.substring(sep + 1) : '';
            final appliedToPart = appliedTo.isNotEmpty ? '|APPLIEDTO:$appliedTo' : '';
            buf.writeln(
                'ABILITY:$category|TYPE:NORMAL|CATEGORY:$category|KEY:$abilKey'
                '$appliedToPart|TYPE:|DESC:');
          }
        }
      }
      buf.writeln();
    }

    // Equipment
    final gear = data['gear'] as List? ?? [];
    final funds = (data['funds'] as num?)?.toDouble() ?? 0.0;
    buf.writeln('# Character Equipment');
    buf.writeln('MONEY:${funds.toStringAsFixed(0)}');
    final equippedSlots = data['equippedSlots'] as Map? ?? {};
    // Build reverse map: itemKey → slot name
    final keyToSlot = <String, String>{};
    equippedSlots.forEach((slot, key) {
      if (key is String && key.isNotEmpty) keyToSlot[key] = slot as String;
    });

    if (gear.isNotEmpty) {
      int eqOrder = 1;
      for (final item in gear) {
        if (item is Map) {
          final name = item['name'] as String? ?? '';
          final key  = item['key']  as String? ?? '';
          final qty  = (item['qty']  as num?)?.toInt() ?? 1;
          final cost = (item['cost'] as num?)?.toDouble() ?? 0.0;
          final wt   = (item['weight'] as num?)?.toDouble() ?? 0.0;
          final slot = keyToSlot[key];
          final locationPart = slot != null
              ? '|LOCATION:${_slotToPcgenLocation(slot)}'
              : '';
          buf.writeln(
              'EQUIPNAME:$name|OUTPUTORDER:${eqOrder++}|COST:$cost|WT:$wt'
              '|QUANTITY:$qty.0$locationPart');
        }
      }
    }
    buf.writeln();

    // Deity & Domains
    final deityKey = data['deityKey'] as String? ?? '';
    buf.writeln('# Character Deity/Domain');
    if (deityKey.isNotEmpty) buf.writeln('DEITY:$deityKey');
    final selectedDomains = data['selectedDomains'] as List? ?? [];
    for (final d in selectedDomains) {
      buf.writeln('DOMAIN:$d');
    }
    buf.writeln();

    // Companions
    final companions = data['companions'] as List? ?? [];
    if (companions.isNotEmpty) {
      buf.writeln('# Character Master/Follower');
      for (final c in companions) {
        if (c is Map) {
          final cName = c['name'] as String? ?? '';
          final cType = c['type'] as String? ?? 'Familiar';
          final cRace = c['race'] as String? ?? '';
          final cFile = c['file'] as String? ?? '';
          buf.write('FOLLOWER:$cName|TYPE:$cType');
          if (cRace.isNotEmpty) buf.write('|RACE:$cRace');
          buf.write('|HITDICE:0');
          if (cFile.isNotEmpty) buf.write('|FILE:$cFile');
          buf.writeln();
        }
      }
      buf.writeln();
    }

    // Spells
    final knownSpells = data['knownSpells'] as List? ?? [];
    if (knownSpells.isNotEmpty) {
      buf.writeln('# Character Spells Information');
      // Determine spellcasting class
      final spellClass = classLevels.isNotEmpty && classLevels[0] is Map
          ? classLevels[0]['classKey'] as String? ?? 'Unknown'
          : 'Unknown';
      buf.writeln('SPELLBOOK:Class|TYPE:4');
      for (final spell in knownSpells) {
        if (spell is Map) {
          final sName  = spell['name']  as String? ?? '';
          final sLevel = spell['level'] as int?    ?? 0;
          buf.writeln('SPELLNAME:$sName|TIMES:1|CLASS:$spellClass|BOOK:Class'
              '|SPELLLEVEL:$sLevel|SOURCE:[TYPE:CLASS|NAME:$spellClass]');
        }
      }
      buf.writeln();
    }

    // Character descriptions
    buf.writeln('# Character Description/Bio/History');
    buf.writeln('CHARACTERBIO:${_esc(data['biography'] as String? ?? '')}');
    buf.writeln('CHARACTERDESC:${_esc(data['appearance'] as String? ?? '')}');
    buf.writeln('CHARACTERCOMP:');
    buf.writeln('CHARACTERASSET:');
    buf.writeln('CHARACTERMAGIC:');
    buf.writeln('CHARACTERDMNOTES:');
    buf.writeln();

    // Notes
    final notes = data['notes'] as String? ?? '';
    buf.writeln('# Character Notes Tab');
    buf.writeln('NOTE:Character Sheet Notes|ID:1|PARENTID:-1'
        '|VALUE:${_esc(notes)}');
    buf.writeln();

    return buf.toString();
  }

  // ---------------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------------

  static CharacterFacadeImpl read(String content, {dynamic dataset}) {
    final data = <String, dynamic>{
      'name': '', 'tabName': '', 'fileName': null, 'modified': false,
      'playerName': '', 'gender': '', 'age': 0,
      'height': 0, 'weight': 0, 'eyeColor': '', 'hairColor': '', 'skinColor': '',
      'xp': 0, 'hp': 0, 'funds': 0.0,
      'biography': '', 'appearance': '', 'notes': '',
      'raceKey': '', 'alignmentKey': '', 'deityKey': '',
      'statScores': <String, dynamic>{},
      'classLevels': <dynamic>[],
      'classSpellBase': <String, String>{},
      'classSpellSlots': <String, List<int>>{},
      'skillRanks': <String, dynamic>{},
      'selectedAbilities': <String, dynamic>{},
      'selectedDomains': <String>[],
      'appliedTemplates': <String>[],
      'languageKeys': <String>[],
      'gear': <dynamic>[],
      'equippedSlots': <String, String>{},
      'companions': <dynamic>[],
      'tempBonuses': <dynamic>[],
      'knownSpells': <dynamic>[],
      'preparedSpells': <dynamic>[],
    };

    // Temp: class summary from CLASS: lines (fallback if no CLASSABILITIESLEVEL)
    final classSummary = <String, int>{};
    bool hasClassAbilityLines = false;

    for (final rawLine in content.split('\n')) {
      final line = rawLine.trimRight();
      if (line.isEmpty || line.startsWith('#')) continue;

      final colonIdx = line.indexOf(':');
      if (colonIdx < 0) continue;

      final key   = line.substring(0, colonIdx).toUpperCase();
      final value = line.substring(colonIdx + 1);

      switch (key) {
        case 'PCGVERSION':
        case 'VERSION':
        case 'ROLLMETHOD':
        case 'PURCHASEPOINTS':
        case 'POOLPOINTS':
        case 'POOLPOINTSAVAIL':
        case 'GAMEMODE':
          data['gameMode'] = value.trim();
          break;
        case 'TABLABEL':
        case 'AUTOSPELLS':
        case 'USEHIGHERKNOWN':
        case 'USEHIGHERPREPPED':
        case 'LOADCOMPANIONS':
        case 'USETEMPMODS':
        case 'AUTOSORTGEAR':
        case 'SKILLSOUTPUTORDER':
        case 'IGNORECOST':
        case 'ALLOWDEBT':
        case 'AUTORESIZEGEAR':
        case 'CHARACTERTYPE':
        case 'PREVIEWSHEET':
        case 'SKILLFILTER':
        case 'CALCEQUIPSET':
        case 'EQUIPSET':
        case 'WEAPONPROF':
        case 'USERPOOL':
        case 'FEATPOOL':
        case 'AGESET':
        case 'HAIRSTYLE':
        case 'LOCATION':
        case 'CITY':
        case 'BIRTHDAY':
        case 'BIRTHPLACE':
        case 'PERSONALITYTRAIT1':
        case 'PERSONALITYTRAIT2':
        case 'SPEECHPATTERN':
        case 'PHOBIAS':
        case 'INTERESTS':
        case 'CATCHPHRASE':
        case 'PORTRAIT':
        case 'SPELLBOOK':
          break; // explicitly ignored

        case 'CHARACTERNAME':
        case 'NAME':
          data['name'] = _unesc(value);
          break;
        case 'TABNAME':
          if (value.isNotEmpty) data['tabName'] = value;
          break;
        case 'PLAYERNAME':
          data['playerName'] = _unesc(value);
          break;
        case 'AGE':
          data['age'] = int.tryParse(value.trim()) ?? 0;
          break;
        case 'GENDER':
          data['gender'] = value.trim();
          break;
        case 'HANDED':
          break;
        case 'HEIGHT':
          data['height'] = int.tryParse(value.trim()) ?? 0;
          break;
        case 'WEIGHT':
          data['weight'] = int.tryParse(value.trim()) ?? 0;
          break;
        case 'EYECOLOR':
          if (value.trim().isNotEmpty) data['eyeColor'] = value.trim();
          break;
        case 'HAIRCOLOR':
          if (value.trim().isNotEmpty) data['hairColor'] = value.trim();
          break;
        case 'SKINCOLOR':
          if (value.trim().isNotEmpty) data['skinColor'] = value.trim();
          break;
        case 'STAT':
          _readStat(data, value);
          break;
        case 'ALIGN':
        case 'ALIGNMENT':
          data['alignmentKey'] = value.trim();
          break;
        case 'RACE':
          data['raceKey'] = value.trim();
          break;
        case 'DEITY':
          final d = value.trim();
          if (d != 'None' && d.isNotEmpty) data['deityKey'] = d;
          break;
        case 'CLASS':
          _readClassSummary(data, classSummary, value);
          break;
        case 'CLASSABILITIESLEVEL':
          hasClassAbilityLines = true;
          _readClassAbilitiesLevel(data, value);
          break;
        case 'EXPERIENCE':
          data['xp'] = int.tryParse(value.trim()) ?? 0;
          break;
        case 'TEMPLATESAPPLIED':
          _readTemplates(data, value);
          break;
        case 'SKILL':
          _readSkill(data, value);
          break;
        case 'CAMPAIGN':
          break; // skip campaign lines
        case 'EXPERIENCETABLE':
          final et = value.trim();
          if (et.isNotEmpty) data['xpTableName'] = et;
          break;
        case 'DOMAIN':
          _readDomain(data, value);
          break;
        case 'FOLLOWER':
          _readFollower(data, value);
          break;
        case 'MASTER':
        case 'REGION':
        case 'SUPPRESSBIOFIELDS':
        case 'KIT':
        case 'TEMPBONUS':
          break; // recognised but not yet used
        case 'LANGUAGE':
          _readLanguages(data, value);
          break;
        case 'ABILITY':
          _readAbility(data, value);
          break;
        case 'FEAT':
          _readFeat(data, value);
          break;
        case 'EQUIPNAME':
          _readEquip(data, value);
          break;
        case 'MONEY':
          data['funds'] = double.tryParse(value.trim()) ?? 0.0;
          break;
        case 'GOLD':
          data['funds'] = double.tryParse(value.trim()) ?? 0.0;
          break;
        case 'SPELLNAME':
          _readSpell(data, value);
          break;
        case 'CHARACTERBIO':
        case 'BIOGRAPHY':
          data['biography'] = _unesc(value);
          break;
        case 'CHARACTERDESC':
        case 'APPEARANCE':
          data['appearance'] = _unesc(value);
          break;
        case 'CHARACTERCOMP':
        case 'CHARACTERASSET':
        case 'CHARACTERMAGIC':
        case 'CHARACTERDMNOTES':
          break; // additional bio fields — could map later
        case 'NOTE':
          _readNote(data, value);
          break;
        case 'HP':
          data['hp'] = int.tryParse(value.trim()) ?? 0;
          break;
      }
    }

    // If no CLASSABILITIESLEVEL lines, synthesize from CLASS summary
    if (!hasClassAbilityLines && classSummary.isNotEmpty) {
      for (final entry in classSummary.entries) {
        for (int i = 0; i < entry.value; i++) {
          (data['classLevels'] as List).add({
            'classKey': entry.key,
            'className': entry.key,
            'hp': 0,
          });
        }
      }
    }

    if ((data['tabName'] as String).isEmpty) {
      data['tabName'] = data['name'];
    }

    final character = CharacterFacadeImpl(data);
    if (dataset != null) character.restoreFromDataset(dataset);
    return character;
  }

  // ---------------------------------------------------------------------------
  // Read helpers
  // ---------------------------------------------------------------------------

  static void _readStat(Map<String, dynamic> data, String value) {
    // STAT:STR|SCORE:16
    final parts = value.split('|');
    final statName = parts[0].trim().toUpperCase();
    int score = 10;
    for (final p in parts.skip(1)) {
      final up = p.toUpperCase();
      if (up.startsWith('SCORE:')) {
        score = int.tryParse(p.substring(6).trim()) ?? 10;
        break;
      }
    }
    (data['statScores'] as Map)[statName] = score;
  }

  static void _readClassSummary(
      Map<String, dynamic> data, Map<String, int> store, String value) {
    // CLASS:Fighter|SUBCLASS:None|LEVEL:5|SPELLBASE:WIS|CANCASTPERDAY:4,4,3
    final parts = value.split('|');
    if (parts.isEmpty) return;
    final className = parts[0].trim();
    int level = 0;
    for (final p in parts.skip(1)) {
      final up = p.toUpperCase();
      if (up.startsWith('LEVEL:')) {
        level = int.tryParse(p.substring(6).trim()) ?? 0;
      } else if (up.startsWith('SPELLBASE:')) {
        final sb = p.substring(10).trim();
        if (sb.isNotEmpty && sb != 'None') {
          final spellBases = (data['classSpellBase'] ??= <String, String>{}) as Map;
          spellBases[className] = sb;
        }
      } else if (up.startsWith('CANCASTPERDAY:')) {
        final slots = p.substring(14).trim();
        if (slots.isNotEmpty) {
          final slotMap = (data['classSpellSlots'] ??= <String, List<int>>{}) as Map;
          slotMap[className] = slots.split(',')
              .map((s) => int.tryParse(s.trim()) ?? 0)
              .toList();
        }
      }
    }
    store[className] = level;
  }

  static void _readClassAbilitiesLevel(
      Map<String, dynamic> data, String value) {
    // CLASSABILITIESLEVEL:Fighter=1|HITPOINTS:10|PRESTAT:STR=1|SKILLSGAINED:2|...
    final parts = value.split('|');
    if (parts.isEmpty) return;

    // First token is ClassName=levelNum
    final eqIdx = parts[0].indexOf('=');
    final className = eqIdx > 0
        ? parts[0].substring(0, eqIdx).trim()
        : parts[0].trim();

    int hp = 0;
    int skillsGained = 0;
    final statGains = <String, int>{};

    for (final p in parts.skip(1)) {
      final up = p.toUpperCase();
      if (up.startsWith('HITPOINTS:')) {
        hp = int.tryParse(p.substring(10).trim()) ?? 0;
      } else if (up.startsWith('SKILLSGAINED:') || up.startsWith('SKILLPOINTSGAINED:')) {
        final idx = p.indexOf(':');
        skillsGained = int.tryParse(p.substring(idx + 1).trim()) ?? 0;
      } else if (up.startsWith('SKILLSREMAINING:') || up.startsWith('SKILLPOINTSREMAINING:')) {
        // stored but not currently used in UI
      } else if (up.startsWith('PRESTAT:')) {
        // PRESTAT:STR=1
        final rest = p.substring(8).trim();
        final sIdx = rest.indexOf('=');
        if (sIdx > 0) {
          final stat = rest.substring(0, sIdx).toUpperCase();
          final gain = int.tryParse(rest.substring(sIdx + 1)) ?? 0;
          statGains[stat] = (statGains[stat] ?? 0) + gain;
        }
      }
    }
    (data['classLevels'] as List).add({
      'classKey': className,
      'className': className,
      'hp': hp,
      'skillsGained': skillsGained,
      if (statGains.isNotEmpty) 'statGains': statGains,
    });
  }

  static void _readTemplates(Map<String, dynamic> data, String value) {
    // TEMPLATESAPPLIED:[NAME:Human][NAME:Vampire]
    final regex = RegExp(r'\[NAME:([^\]]+)\]');
    for (final m in regex.allMatches(value)) {
      final name = m.group(1)?.trim() ?? '';
      if (name.isNotEmpty) (data['appliedTemplates'] as List).add(name);
    }
  }

  static void _readSkill(Map<String, dynamic> data, String value) {
    // SKILL:Diplomacy|OUTPUTORDER:6|CLASSBOUGHT:[CLASS:Paladin|RANKS:5.0|...]
    // Skills with no CLASSBOUGHT have 0 ranks.
    final nameEnd = value.indexOf('|');
    final skillName = nameEnd > 0 ? value.substring(0, nameEnd).trim() : value.trim();

    // Extract RANKS from CLASSBOUGHT block
    double rank = 0;
    final cbMatch = RegExp(r'CLASSBOUGHT:\[([^\]]+)\]').firstMatch(value);
    if (cbMatch != null) {
      for (final part in cbMatch.group(1)!.split('|')) {
        if (part.toUpperCase().startsWith('RANKS:')) {
          rank = double.tryParse(part.substring(6).trim()) ?? 0;
          break;
        }
      }
    }
    // Also handle simple RANK: outside CLASSBOUGHT
    if (rank == 0) {
      final rankMatch = RegExp(r'RANK:([0-9.]+)').firstMatch(value);
      if (rankMatch != null) rank = double.tryParse(rankMatch.group(1)!) ?? 0;
    }

    if (rank > 0) (data['skillRanks'] as Map)[skillName] = rank;
  }

  static void _readLanguages(Map<String, dynamic> data, String value) {
    // LANGUAGE:Common  or  Common|LANGUAGE:Elvish  (tag already stripped)
    // The value after 'LANGUAGE:' may be 'Common' or 'Common|LANGUAGE:Elvish'
    final langs = data['languageKeys'] as List;
    for (final part in value.split('|')) {
      // Each part may be 'Common' or 'LANGUAGE:Elvish'
      final lang = part.startsWith('LANGUAGE:')
          ? part.substring(9).trim()
          : part.trim();
      if (lang.isNotEmpty && !langs.contains(lang)) langs.add(lang);
    }
  }

  static void _readAbility(Map<String, dynamic> data, String value) {
    // ABILITY:FEAT|TYPE:NORMAL|CATEGORY:FEAT|KEY:Power Attack|APPLIEDTO:Longsword|TYPE:Combat|DESC:...
    final parts = value.split('|');
    if (parts.isEmpty) return;

    String category   = parts[0].trim();
    String abilityKey = '';
    String appliedTo  = '';
    for (final p in parts.skip(1)) {
      final up = p.toUpperCase();
      if (up.startsWith('CATEGORY:'))  category   = p.substring(9).trim();
      if (up.startsWith('KEY:'))       abilityKey = p.substring(4).trim();
      if (up.startsWith('APPLIEDTO:')) appliedTo  = p.substring(10).trim();
    }
    if (abilityKey.isEmpty) return;

    // Store as "Key|AppliedTo" internally; split on '|' for display & write.
    // Simple keys have no '|', so this is safe.
    final storeKey = appliedTo.isNotEmpty ? '$abilityKey|$appliedTo' : abilityKey;

    final abilities = data['selectedAbilities'] as Map;
    final list = (abilities[category] ??= <String>[]) as List;
    if (!list.contains(storeKey)) list.add(storeKey);
  }

  static void _readFeat(Map<String, dynamic> data, String value) {
    // Legacy FEAT:Power Attack|APPLIED:NORMAL|...
    final parts = value.split('|');
    if (parts.isEmpty) return;
    final featName = parts[0].trim();
    if (featName.isEmpty) return;
    final abilities = data['selectedAbilities'] as Map;
    final feats = (abilities['FEAT'] ??= <String>[]) as List;
    if (!feats.contains(featName)) feats.add(featName);
  }

  static void _readEquip(Map<String, dynamic> data, String value) {
    // EQUIPNAME:Longsword +1|OUTPUTORDER:2|COST:5015.0|WT:4.0|QUANTITY:1.0|LOCATION:Primary Hand|...
    final nameEnd = value.indexOf('|');
    final itemName = nameEnd > 0 ? value.substring(0, nameEnd).trim() : value.trim();
    double qty    = 1;
    double cost   = 0;
    double weight = 0;
    String location = '';
    for (final p in value.split('|').skip(1)) {
      final up = p.toUpperCase();
      if (up.startsWith('QUANTITY:') || up.startsWith('QTY:')) {
        qty = double.tryParse(p.substring(p.indexOf(':') + 1).trim()) ?? 1;
      } else if (up.startsWith('COST:')) {
        cost = double.tryParse(p.substring(5).trim()) ?? 0;
      } else if (up.startsWith('WT:')) {
        weight = double.tryParse(p.substring(3).trim()) ?? 0;
      } else if (up.startsWith('LOCATION:')) {
        location = p.substring(9).trim();
      }
    }
    final key = itemName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
    (data['gear'] as List).add({
      'name':   itemName,
      'key':    key,
      'qty':    qty.toInt(),
      'cost':   cost,
      'weight': weight,
    });
    // Map PCGen Java location names to our slot names
    if (location.isNotEmpty) {
      final slot = _pcgenLocationToSlot(location);
      if (slot != null) {
        final eq = (data['equippedSlots'] ??= <String, String>{}) as Map;
        eq[slot] = key;
      }
    }
  }

  static String _slotToPcgenLocation(String slot) {
    switch (slot) {
      case 'Primary Hand':  return 'Primary Hand';
      case 'Off Hand':      return 'Secondary Hand';
      case 'Head':          return 'Head';
      case 'Eyes':          return 'Eyes';
      case 'Neck':          return 'Neck';
      case 'Shoulders':     return 'Shoulders';
      case 'Back':          return 'Back';
      case 'Armor':         return 'Body';
      case 'Torso':         return 'Torso';
      case 'Arms':          return 'Arms';
      case 'Hands':         return 'Hands';
      case 'Ring (Left)':   return 'Left Ring';
      case 'Ring (Right)':  return 'Right Ring';
      case 'Belt':          return 'Waist';
      case 'Feet':          return 'Feet';
      case 'Ammunition':    return 'Ammunition';
      case 'Carried':       return 'Carried';
      default:              return slot;
    }
  }

  static String? _pcgenLocationToSlot(String location) {
    switch (location.toLowerCase()) {
      case 'primary hand':   return 'Primary Hand';
      case 'secondary hand':
      case 'off hand':       return 'Off Hand';
      case 'head':           return 'Head';
      case 'eyes':           return 'Eyes';
      case 'neck':           return 'Neck';
      case 'shoulders':      return 'Shoulders';
      case 'back':           return 'Back';
      case 'body':
      case 'armor':          return 'Armor';
      case 'torso':          return 'Torso';
      case 'arms':           return 'Arms';
      case 'hands':          return 'Hands';
      case 'left ring':
      case 'ring (left)':    return 'Ring (Left)';
      case 'right ring':
      case 'ring (right)':   return 'Ring (Right)';
      case 'waist':
      case 'belt':           return 'Belt';
      case 'feet':           return 'Feet';
      case 'ammunition':     return 'Ammunition';
      case 'carried':        return 'Carried';
      default:               return null;
    }
  }

  static void _readSpell(Map<String, dynamic> data, String value) {
    // SPELLNAME:Fireball|TIMES:1|CLASS:Wizard|BOOK:Known Spells|SPELLLEVEL:3|SOURCE:[...]
    final parts = value.split('|');
    if (parts.isEmpty) return;
    final spellName = parts[0].trim();
    int level = 0;
    String book = 'Class';
    String spellClass = '';
    for (final p in parts.skip(1)) {
      final up = p.toUpperCase();
      if (up.startsWith('SPELLLEVEL:')) {
        level = int.tryParse(p.substring(11).trim()) ?? 0;
      } else if (up.startsWith('BOOK:')) {
        book = p.substring(5).trim();
      } else if (up.startsWith('CLASS:')) {
        spellClass = p.substring(6).trim();
      }
    }
    // "Prepared Spells" book → prepared list; anything else → known list.
    final isPrepared = book.toLowerCase().contains('prepared');
    final spell = {
      'name': spellName,
      'key': spellName.toLowerCase().replaceAll(' ', '_'),
      'level': level,
      if (spellClass.isNotEmpty) 'class': spellClass,
      'book': book,
    };
    if (isPrepared) {
      (data['preparedSpells'] as List).add(spell);
    } else {
      (data['knownSpells'] as List).add(spell);
    }
  }

  static void _readDomain(Map<String, dynamic> data, String value) {
    // DOMAIN:Protection|DOMAINGRANTS:text|SOURCE:[...]
    final nameEnd = value.indexOf('|');
    final domainName = nameEnd > 0 ? value.substring(0, nameEnd).trim() : value.trim();
    if (domainName.isEmpty) return;
    final domains = (data['selectedDomains'] ??= <String>[]) as List;
    if (!domains.contains(domainName)) domains.add(domainName);
  }

  static void _readFollower(Map<String, dynamic> data, String value) {
    // FOLLOWER:name|TYPE:Familiar|RACE:race|HITDICE:0|FILE:x.pcg
    final parts = value.split('|');
    if (parts.isEmpty) return;
    final name = parts[0].trim();
    String type = '';
    String race = '';
    String file = '';
    for (final p in parts.skip(1)) {
      final up = p.toUpperCase();
      if (up.startsWith('TYPE:'))     type = p.substring(5).trim();
      if (up.startsWith('RACE:'))     race = p.substring(5).trim();
      if (up.startsWith('FILE:'))     file = p.substring(5).trim();
    }
    (data['companions'] as List).add({
      'name': name,
      'type': type,
      'race': race,
      'file': file,
    });
  }

  static void _readNote(Map<String, dynamic> data, String value) {
    // NOTE:name|ID:n|PARENTID:n|VALUE:text
    final valueMatch = RegExp(r'VALUE:(.*)$').firstMatch(value);
    if (valueMatch != null) {
      final text = _unesc(valueMatch.group(1) ?? '');
      if (text.isNotEmpty) {
        final existing = data['notes'] as String? ?? '';
        data['notes'] = existing.isEmpty ? text : '$existing\n$text';
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static String _esc(String s) =>
      s.replaceAll('\r', '').replaceAll('\n', '\\n');

  static String _unesc(String s) => s.replaceAll('\\n', '\n');

  /// Returns true if content is a PCGen PCG file (starts with PCGVERSION:).
  static bool isPCGFormat(String content) =>
      content.trimLeft().startsWith('PCGVERSION:');

  /// Quickly peek key fields from the first ~80 lines of a PCG or JSON file.
  /// Returns a map with keys: name, gameMode, race, primaryClass, totalLevel.
  static Map<String, String> peekHeader(String content) {
    final result = <String, String>{};
    if (content.trimLeft().startsWith('{')) {
      // JSON — extract fields via regex
      try {
        final nameMatch  = RegExp(r'"name"\s*:\s*"([^"]*)"').firstMatch(content);
        if (nameMatch != null) result['name'] = nameMatch.group(1)!;
        final modeMatch  = RegExp(r'"gameMode"\s*:\s*"([^"]*)"').firstMatch(content);
        if (modeMatch != null) result['gameMode'] = modeMatch.group(1)!;
        final raceMatch  = RegExp(r'"raceKey"\s*:\s*"([^"]*)"').firstMatch(content);
        if (raceMatch != null) result['race'] = raceMatch.group(1)!;
        // classLevels: count entries for total level + find primary class
        final classKeys = RegExp(r'"classKey"\s*:\s*"([^"]*)"')
            .allMatches(content)
            .map((m) => m.group(1)!)
            .toList();
        if (classKeys.isNotEmpty) {
          final counts = <String, int>{};
          for (final k in classKeys) counts[k] = (counts[k] ?? 0) + 1;
          final primary = counts.entries
              .reduce((a, b) => a.value >= b.value ? a : b)
              .key;
          result['primaryClass'] = primary;
          result['totalLevel'] = '${classKeys.length}';
        }
      } catch (_) {}
      return result;
    }

    // PCG — scan first 80 lines
    // CLASS lines: CLASS:Name|SUBCLASS:None|LEVEL:5|...
    final classes = <String, int>{}; // className → level
    int lineCount = 0;
    for (final raw in content.split('\n')) {
      if (++lineCount > 80) break;
      final line = raw.trimRight();
      if (line.isEmpty || line.startsWith('#')) continue;
      final idx = line.indexOf(':');
      if (idx < 0) continue;
      final key = line.substring(0, idx).toUpperCase();
      final val = line.substring(idx + 1).trim();
      switch (key) {
        case 'CHARACTERNAME':
        case 'NAME':
          result['name'] = _unesc(val);
        case 'GAMEMODE':
          result['gameMode'] = val;
        case 'RACE':
          result['race'] = val;
        case 'CLASS':
          // CLASS:Paladin|SUBCLASS:None|LEVEL:5|...
          final parts = val.split('|');
          final className = parts[0].trim();
          int level = 0;
          for (final p in parts.skip(1)) {
            if (p.toUpperCase().startsWith('LEVEL:')) {
              level = int.tryParse(p.substring(6).trim()) ?? 0;
              break;
            }
          }
          if (className.isNotEmpty) classes[className] = level;
      }
    }
    if (classes.isNotEmpty) {
      final total = classes.values.fold(0, (s, v) => s + v);
      // Primary class = highest level; on tie, first encountered
      final primary = classes.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
      result['primaryClass'] = primary;
      result['totalLevel'] = '$total';
    }
    return result;
  }
}
