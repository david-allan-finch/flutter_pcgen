// PCGen PCG v2 character file format — read and write.
//
// The PCG v2 format is a line-based text file where each line is:
//   KEY:value
// or
//   KEY:subkey|SUBKEY2:value2
//
// This implementation reads and writes CharacterFacadeImpl directly,
// so characters can be exchanged with the original Java PCGen application.

import 'package:flutter_pcgen/src/gui2/facade/character_facade_impl.dart';

class PCGCharacterIO {
  static const String _pcgVersion = '8.00.00';

  // ---------------------------------------------------------------------------
  // Write (serialize CharacterFacadeImpl → PCG v2 text)
  // ---------------------------------------------------------------------------

  static String write(CharacterFacadeImpl character) {
    final buf = StringBuffer();
    final data = character.toJson();

    _ln(buf, 'VERSION:$_pcgVersion');

    // Identity
    final name = character.getName();
    _ln(buf, 'CHARACTERNAME:${_esc(name)}');
    final playerName = character.getPlayersName();
    if (playerName.isNotEmpty) _ln(buf, 'PLAYERNAME:${_esc(playerName)}');

    // Ability scores
    final scores = data['statScores'] as Map? ?? {};
    for (final entry in scores.entries) {
      _ln(buf, 'STAT:${entry.key}|SCORE:${entry.value}');
    }

    // Race, alignment, deity
    final raceKey = data['raceKey'] as String? ?? '';
    if (raceKey.isNotEmpty) _ln(buf, 'RACE:$raceKey');
    final alignKey = data['alignmentKey'] as String? ?? '';
    if (alignKey.isNotEmpty) _ln(buf, 'ALIGNMENT:$alignKey');
    final deityKey = data['deityKey'] as String? ?? '';
    _ln(buf, 'DEITY:${deityKey.isEmpty ? "None" : deityKey}');

    // Class levels — emit one CLASS summary line then per-level CLASSLEVEL
    final classLevels = data['classLevels'] as List? ?? [];
    final classCounts = <String, int>{};
    for (final l in classLevels) {
      if (l is Map) {
        final k = l['classKey'] as String? ?? '';
        classCounts[k] = (classCounts[k] ?? 0) + 1;
      }
    }
    for (final entry in classCounts.entries) {
      _ln(buf, 'CLASS:${entry.key}|LEVEL:${entry.value}|SUBCLASS:none');
    }
    int lvlNum = 1;
    for (final l in classLevels) {
      if (l is Map) {
        final clsKey  = l['classKey'] as String? ?? '';
        final hp      = l['hp']       as int? ?? 0;
        _ln(buf, 'CLASSLEVEL:$clsKey|$lvlNum|HP:$hp');
        lvlNum++;
      }
    }

    // Skills with ranks > 0
    final skillRanks = data['skillRanks'] as Map? ?? {};
    int skillOrder = 0;
    for (final entry in skillRanks.entries) {
      final rank = (entry.value as num?)?.toDouble() ?? 0.0;
      if (rank > 0) {
        _ln(buf, 'SKILL:${entry.key}|OUTPUTORDER:${skillOrder++}|RANK:$rank|SKILLPOOL:0');
      }
    }

    // Feats / abilities
    final selectedAbilities = data['selectedAbilities'] as Map? ?? {};
    for (final catEntry in selectedAbilities.entries) {
      final category = catEntry.key as String;
      final keys = catEntry.value;
      if (keys is List) {
        for (final abilityKey in keys) {
          _ln(buf,
              'ABILITY:$category|APPLIED:NORMAL|CATEGORY:$category|ABILITY:$abilityKey');
        }
      }
    }

    // Templates
    final templates = data['appliedTemplates'] as List? ?? [];
    for (final t in templates) {
      _ln(buf, 'TEMPLATE:$t');
    }

    // Languages
    final languages = data['languageKeys'] as List? ?? [];
    for (final lang in languages) {
      _ln(buf, 'LANGUAGE:$lang');
    }

    // Equipment / gear
    final gear = data['gear'] as List? ?? [];
    int eqOrder = 0;
    for (final item in gear) {
      if (item is Map) {
        final itemName = item['name'] as String? ?? '';
        final qty      = (item['qty'] as num?)?.toInt() ?? 1;
        final cost     = (item['cost'] as num?)?.toDouble() ?? 0.0;
        _ln(buf,
            'EQUIPNAME:$itemName|OUTPUTORDER:${eqOrder++}|QTY:$qty|COST:$cost|EQUIPPED:N|LOC:Carried');
      }
    }

    // Biography fields
    final gender = data['gender'] as String? ?? '';
    if (gender.isNotEmpty) _ln(buf, 'GENDER:$gender');
    final age = data['age'] as int? ?? 0;
    if (age > 0) _ln(buf, 'AGE:$age');

    final bio = data['biography'] as String? ?? '';
    if (bio.isNotEmpty) _ln(buf, 'BIOGRAPHY:${_esc(bio)}');
    final appearance = data['appearance'] as String? ?? '';
    if (appearance.isNotEmpty) _ln(buf, 'APPEARANCE:${_esc(appearance)}');

    // Notes block
    final notes = data['notes'] as String? ?? '';
    if (notes.isNotEmpty) {
      buf.writeln('NOTES:BEGIN');
      buf.writeln(notes);
      buf.writeln('NOTES:END');
    }

    // Spells
    final knownSpells = data['knownSpells'] as List? ?? [];
    for (final spell in knownSpells) {
      if (spell is Map) {
        final spellName = spell['name'] as String? ?? '';
        final level = spell['level'] as int? ?? 0;
        if (spellName.isNotEmpty) {
          _ln(buf, 'SPELLNAME:$spellName|TIMES:1|TYPE:KNOWN|SPELL LEVEL:$level|SOURCE:Innate');
        }
      }
    }

    // Numeric fields
    final xp = data['xp'] as int? ?? 0;
    if (xp > 0) _ln(buf, 'EXPERIENCE:$xp');
    final hp = data['hp'] as int? ?? 0;
    if (hp > 0) _ln(buf, 'HP:$hp');
    final funds = data['funds'] as double? ?? 0.0;
    if (funds > 0) _ln(buf, 'GOLD:$funds');

    return buf.toString();
  }

  // ---------------------------------------------------------------------------
  // Read (parse PCG v2 text → CharacterFacadeImpl)
  // ---------------------------------------------------------------------------

  static CharacterFacadeImpl read(String content, {dynamic dataset}) {
    final data = <String, dynamic>{
      'name': '',
      'tabName': '',
      'fileName': null,
      'modified': false,
      'playerName': '',
      'gender': '',
      'age': 0,
      'xp': 0,
      'hp': 0,
      'funds': 0.0,
      'biography': '',
      'appearance': '',
      'notes': '',
      'raceKey': '',
      'alignmentKey': '',
      'deityKey': '',
      'statScores': <String, dynamic>{},
      'classLevels': <dynamic>[],
      'skillRanks': <String, dynamic>{},
      'selectedAbilities': <String, dynamic>{},
      'selectedDomains': <String>[],
      'appliedTemplates': <String>[],
      'languageKeys': <String>[],
      'gear': <dynamic>[],
      'companions': <dynamic>[],
      'tempBonuses': <dynamic>[],
      'knownSpells': <dynamic>[],
      'preparedSpells': <dynamic>[],
    };

    // Temp store for CLASS summary lines; used only if no CLASSLEVEL lines appear.
    final classSummary = <String, int>{};

    final lines = content.split('\n');
    bool inNotes = false;
    final notesBuf = StringBuffer();

    for (final rawLine in lines) {
      final line = rawLine.trimRight();
      if (line.isEmpty) continue;

      if (line == 'NOTES:BEGIN') { inNotes = true; continue; }
      if (line == 'NOTES:END') {
        data['notes'] = notesBuf.toString().trimRight();
        inNotes = false;
        continue;
      }
      if (inNotes) { notesBuf.writeln(line); continue; }

      final colonIdx = line.indexOf(':');
      if (colonIdx < 0) continue;

      final key   = line.substring(0, colonIdx).toUpperCase();
      final value = line.substring(colonIdx + 1);

      switch (key) {
        case 'CHARACTERNAME':
        case 'NAME':
          data['name'] = _unesc(value);
          break;
        case 'PLAYERNAME':
          data['playerName'] = _unesc(value);
          break;
        case 'STAT':
          _readStat(data, value);
          break;
        case 'RACE':
          data['raceKey'] = value.trim();
          break;
        case 'ALIGNMENT':
          data['alignmentKey'] = value.trim();
          break;
        case 'DEITY':
          final d = value.trim();
          if (d != 'None' && d.isNotEmpty) data['deityKey'] = d;
          break;
        case 'CLASS':
          _readClassSummary(classSummary, value);
          break;
        case 'CLASSLEVEL':
          _readClassLevel(data, value);
          break;
        case 'SKILL':
          _readSkill(data, value);
          break;
        case 'FEAT':
          _readFeat(data, value);
          break;
        case 'ABILITY':
          _readAbility(data, value);
          break;
        case 'TEMPLATE':
          final t = value.trim();
          if (t.isNotEmpty) (data['appliedTemplates'] as List).add(t);
          break;
        case 'LANGUAGE':
          final lang = value.trim();
          if (lang.isNotEmpty &&
              !(data['languageKeys'] as List).contains(lang)) {
            (data['languageKeys'] as List).add(lang);
          }
          break;
        case 'EQUIPNAME':
          _readEquip(data, value);
          break;
        case 'SPELLNAME':
          _readSpell(data, value);
          break;
        case 'GENDER':
          data['gender'] = value.trim();
          break;
        case 'AGE':
          data['age'] = int.tryParse(value.trim()) ?? 0;
          break;
        case 'BIOGRAPHY':
          data['biography'] = _unesc(value);
          break;
        case 'APPEARANCE':
          data['appearance'] = _unesc(value);
          break;
        case 'EXPERIENCE':
          data['xp'] = int.tryParse(value.trim()) ?? 0;
          break;
        case 'HP':
          data['hp'] = int.tryParse(value.trim()) ?? 0;
          break;
        case 'GOLD':
          data['funds'] = double.tryParse(value.trim()) ?? 0.0;
          break;
      }
    }

    // If no CLASSLEVEL lines appeared, synthesize from CLASS summary lines.
    if ((data['classLevels'] as List).isEmpty && classSummary.isNotEmpty) {
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

    // Default tabName to character name.
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
    // STAT:STR|SCORE:16  or  STR:16 (old format)
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

  static void _readClassSummary(Map<String, int> store, String value) {
    final parts = value.split('|');
    if (parts.isEmpty) return;
    final className = parts[0].trim();
    int level = 0;
    for (final p in parts.skip(1)) {
      if (p.toUpperCase().startsWith('LEVEL:')) {
        level = int.tryParse(p.substring(6).trim()) ?? 0;
        break;
      }
    }
    store[className] = level;
  }

  static void _readClassLevel(Map<String, dynamic> data, String value) {
    // CLASSLEVEL:Fighter|1|HP:10
    final parts = value.split('|');
    if (parts.isEmpty) return;
    final className = parts[0].trim();
    int hp = 0;
    for (final p in parts.skip(1)) {
      if (p.toUpperCase().startsWith('HP:')) {
        hp = int.tryParse(p.substring(3).trim()) ?? 0;
        break;
      }
    }
    (data['classLevels'] as List).add({
      'classKey': className,
      'className': className,
      'hp': hp,
    });
  }

  static void _readSkill(Map<String, dynamic> data, String value) {
    // SKILL:Climb|OUTPUTORDER:0|RANK:5
    final parts = value.split('|');
    if (parts.isEmpty) return;
    final skillName = parts[0].trim();
    double rank = 0;
    for (final p in parts.skip(1)) {
      if (p.toUpperCase().startsWith('RANK:')) {
        rank = double.tryParse(p.substring(5).trim()) ?? 0;
        break;
      }
    }
    if (rank > 0) (data['skillRanks'] as Map)[skillName] = rank;
  }

  static void _readFeat(Map<String, dynamic> data, String value) {
    // FEAT:Power Attack|APPLIED:NORMAL
    final parts = value.split('|');
    if (parts.isEmpty) return;
    final featName = parts[0].trim();
    if (featName.isEmpty) return;
    final abilities = data['selectedAbilities'] as Map;
    final feats = (abilities['FEAT'] ??= <String>[]) as List;
    if (!feats.contains(featName)) feats.add(featName);
  }

  static void _readAbility(Map<String, dynamic> data, String value) {
    // ABILITY:FEAT|APPLIED:NORMAL|CATEGORY:FEAT|ABILITY:Power Attack
    final parts = value.split('|');
    String category = '';
    String abilityName = '';
    for (final p in parts) {
      final up = p.toUpperCase();
      if (up.startsWith('CATEGORY:')) category    = p.substring(9).trim();
      if (up.startsWith('ABILITY:'))  abilityName = p.substring(8).trim();
    }
    if (category.isEmpty || abilityName.isEmpty) return;
    final abilities = data['selectedAbilities'] as Map;
    final list = (abilities[category] ??= <String>[]) as List;
    if (!list.contains(abilityName)) list.add(abilityName);
  }

  static void _readEquip(Map<String, dynamic> data, String value) {
    // EQUIPNAME:Longsword|OUTPUTORDER:0|QTY:1.0|COST:15.0|...
    final parts = value.split('|');
    if (parts.isEmpty) return;
    final itemName = parts[0].trim();
    double qty  = 1;
    double cost = 0;
    for (final p in parts.skip(1)) {
      final up = p.toUpperCase();
      if (up.startsWith('QTY:'))  qty  = double.tryParse(p.substring(4).trim()) ?? 1;
      if (up.startsWith('COST:')) cost = double.tryParse(p.substring(5).trim()) ?? 0;
    }
    (data['gear'] as List).add({
      'name': itemName,
      'key': itemName.toLowerCase().replaceAll(' ', '_'),
      'qty': qty.toInt(),
      'cost': cost,
    });
  }

  static void _readSpell(Map<String, dynamic> data, String value) {
    // SPELLNAME:Fireball|TIMES:1|TYPE:KNOWN|SPELL LEVEL:3|SOURCE:Innate
    final parts = value.split('|');
    if (parts.isEmpty) return;
    final spellName = parts[0].trim();
    int level = 0;
    for (final p in parts.skip(1)) {
      final up = p.toUpperCase();
      if (up.startsWith('SPELL LEVEL:') || up.startsWith('SPELLLEVEL:')) {
        final idx = p.indexOf(':');
        if (idx >= 0) level = int.tryParse(p.substring(idx + 1).trim()) ?? 0;
      }
    }
    (data['knownSpells'] as List).add({
      'name': spellName,
      'key': spellName.toLowerCase().replaceAll(' ', '_'),
      'level': level,
    });
  }

  // ---------------------------------------------------------------------------
  // Write helpers
  // ---------------------------------------------------------------------------

  static void _ln(StringBuffer buf, String line) => buf.writeln(line);

  /// Escape newlines so single-line values survive round-trips.
  static String _esc(String s) =>
      s.replaceAll('\r', '').replaceAll('\n', '\\n');

  static String _unesc(String s) => s.replaceAll('\\n', '\n');

  // ---------------------------------------------------------------------------
  // Format detection
  // ---------------------------------------------------------------------------

  /// Returns true if [content] looks like a PCG v2 file (starts with VERSION:).
  static bool isPCGFormat(String content) =>
      content.trimLeft().startsWith('VERSION:');
}
