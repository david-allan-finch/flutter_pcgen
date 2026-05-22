// PCGen export token resolver for the FTL template engine.
// Maps PCGen export token strings to CharacterFacadeImpl accessors.
//
// Token format examples:
//   NAME                → character name
//   STAT.0.SCORE        → first stat score (STR)
//   CLASS.0.LEVEL       → first class level count
//   COUNT[CLASSES]      → number of classes
//   WEAPON.0.TOHIT      → first weapon attack bonus string
//   SKILL.0.TOTAL       → first skill total
//   ABILITY.FEAT.0.NAME → first feat name

import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/object_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/string_key.dart';
import 'package:flutter_pcgen/src/core/skill.dart';
import 'package:flutter_pcgen/src/io/freemarker/ftl_context.dart';
import 'package:flutter_pcgen/src/gui2/facade/character_facade_impl.dart';

class PcgenTokenContext extends FtlContext {
  final CharacterFacadeImpl _pc;
  final dynamic _dataset; // loaded DataSet

  // Stat key order used by the stat export tokens
  static const _statOrder = ['STR', 'DEX', 'CON', 'INT', 'WIS', 'CHA'];

  // Save names indexed
  static const _saveNames = ['Fortitude', 'Reflex', 'Will'];

  PcgenTokenContext(this._pc, this._dataset);

  @override
  String pcstring(String token) {
    try { return _resolve(token.trim()); } catch (_) { return ''; }
  }

  @override
  double pcvar(String token) {
    try {
      final v = _resolve(token.trim());
      return double.tryParse(v) ?? 0.0;
    } catch (_) { return 0.0; }
  }

  @override
  bool pcboolean(String token) {
    final v = pcvar(token);
    if (v != 0) return true;
    final s = pcstring(token).toLowerCase();
    return s == 'true' || s == '1' || s == 'yes';
  }

  // ─── Main token dispatcher ─────────────────────────────────────────────────

  String _resolve(String token) {
    if (token.isEmpty) return '';

    // ((expr)+0) — PCGen numeric-coercion wrapper: evaluate inner token, add 0.
    if (token.startsWith('((') && token.endsWith('+0)')) {
      final inner = token.substring(2, token.length - 3).trim();
      final val = _resolve(inner);
      return (num.tryParse(val) ?? 0).toString();
    }
    if (token.startsWith('(') && token.endsWith(')')) {
      return _resolve(token.substring(1, token.length - 1).trim());
    }

    // COUNT[...] tokens (with optional arithmetic suffix: COUNT[STATS]-1)
    if (token.startsWith('COUNT[')) {
      final closeIdx = token.indexOf(']');
      if (closeIdx > 0) {
        final inner  = token.substring(6, closeIdx);
        final suffix = token.substring(closeIdx + 1).trim();
        int base = _count(inner);
        if (suffix.startsWith('-')) {
          base -= int.tryParse(suffix.substring(1).trim()) ?? 0;
        } else if (suffix.startsWith('+')) {
          base += int.tryParse(suffix.substring(1).trim()) ?? 0;
        }
        return base.toString();
      }
    }

    // count(...) / countdistinct(...) function-call tokens used in pcvar()
    if (token.startsWith('count(') || token.startsWith('countdistinct(')) {
      final tl = token.toLowerCase();
      // Find the closing ')' of the outermost call to extract any arithmetic suffix
      // e.g. countdistinct("ABILITIES","CATEGORY=FEAT",...)-1 → subtract 1 from result.
      int _applyCountSuffix(int base) {
        final closeIdx = token.lastIndexOf(')');
        if (closeIdx > 0 && closeIdx < token.length - 1) {
          final suffix = token.substring(closeIdx + 1).trim();
          if (suffix.startsWith('-')) base -= int.tryParse(suffix.substring(1).trim()) ?? 0;
          else if (suffix.startsWith('+')) base += int.tryParse(suffix.substring(1).trim()) ?? 0;
        }
        return base;
      }
      if (tl.contains('"skillsit"') || tl.contains("'skillsit'")) {
        return _applyCountSuffix(_allSkills().length).toString();
      }
      // Legacy shorthand: "FEATS" or "SKILLS"
      if (tl.contains('"feats"')) {
        return _applyCountSuffix(_abilitiesForCat('FEAT').length).toString();
      }
      // General abilities counting: count("ABILITIES","CATEGORY=X","TYPE=Y","ASPECT=Z",...)
      if (tl.contains('"abilities"') || tl.contains("'abilities'") ||
          tl.contains('category=')) {
        // Extract CATEGORY= filter
        final catMatch = RegExp(r'category=([^,"]+)').firstMatch(tl);
        List<String> abilities;
        if (catMatch != null) {
          abilities = _abilitiesForCat(catMatch.group(1)!.trim());
        } else {
          // No category — count all
          abilities = _abilitiesForCat(null);
        }
        // Optional TYPE= filter
        if (tl.contains('type=')) {
          final typeMatch = RegExp(r'type=([^,"]+)').firstMatch(tl);
          if (typeMatch != null) {
            final typeFilter = typeMatch.group(1)!.trim();
            abilities = abilities.where((ab) {
              final obj = _findAbilityInDataset(ab);
              if (obj == null) return false;
              try {
                final types = (obj as dynamic).getTypes() as List? ?? [];
                return types.any((t) =>
                    (t as String).toLowerCase() == typeFilter.toLowerCase());
              } catch (_) { return false; }
            }).toList();
          }
        }
        // Optional ASPECT= filter
        if (tl.contains('aspect=')) {
          final match = RegExp(r'aspect=([^,"]+)').firstMatch(tl);
          if (match != null) {
            final aspectName = match.group(1)!.trim();
            var count = 0;
            for (final ab in abilities) {
              final obj = _findAbilityInDataset(ab);
              if (obj != null && _getAspectValue(obj, aspectName).isNotEmpty) count++;
            }
            return _applyCountSuffix(count).toString();
          }
        }
        return _applyCountSuffix(abilities.length).toString();
      }
      return '0';
    }

    // VAR.name tokens — VAR.Name / VAR.Name.INTVAL / VAR.Name.INTVAL.SIGN / .NOZERO
    // Also handles VAR.HASFEAT:FeatName — feat presence check.
    if (token.startsWith('VAR.')) {
      final parts = token.split('.');
      // VAR.HASFEAT:FeatName — check if feat is selected
      if (parts[1].startsWith('HASFEAT:')) {
        final featName = parts[1].substring(8);
        final feats = _abilitiesForCat('FEAT');
        final has = feats.any((f) => _displayName(f).toLowerCase() == featName.toLowerCase());
        return has ? '1' : '0';
      }
      // VAR.charbonusto("CAT","TARGET") — bonus total from accumulator
      if (parts[1].startsWith('charbonusto(')) {
        try {
          final inner = token.substring(token.indexOf('(') + 1, token.lastIndexOf(')'));
          final args = inner.split(',').map((s) => s.trim().replaceAll('"', '')).toList();
          if (args.length >= 2) {
            final val = _pc.getBonusTo(args[0], args[1]);
            return _applyVarSuffixes(parts, 2, val.toDouble());
          }
        } catch (_) {}
        return '0';
      }
      final varName = parts[1];
      final val = _pc.getVariable(varName);
      return _applyVarSuffixes(parts, 2, val);
    }

    // HASVAR.name — true if the named variable is defined (non-zero)
    if (token.startsWith('HASVAR.')) {
      final varName = token.substring(7);
      return _pc.getVariable(varName) != 0 ? '1' : '0';
    }

    final parts = token.split('.');
    if (parts.isEmpty) return '';

    switch (parts[0]) {
      case 'NAME':        return _pc.getName();
      case 'PLAYERNAME':  return _pc.getPlayersName();
      case 'RACE':        return _raceName();
      case 'SUBRACE':     return _data('subRace') ?? '';
      case 'ALIGNMENT':   return _pc.getAlignmentKey();
      case 'DEITY':       return _pc.getDeityKey();
      case 'GENDER':      return _pc.getGender();
      case 'AGE':         return _pc.getAge().toString();
      case 'HEIGHT':      return _pc.getHeight().toString();
      case 'WEIGHT':      return parts.length == 1 ? _pc.getWeight().toString() : _weightToken(parts);
      case 'EYES':
      case 'EYE':         return _pc.getEyeColor();
      case 'HAIR':        return _pc.getHairColor();
      case 'SKIN':        return _pc.getSkinColor();
      case 'BIO':
      case 'BIOGRAPHY':   return _pc.getBiography();
      case 'APPEARANCE':  return _pc.getAppearance();
      case 'NOTES':       return _pc.getNotes();
      case 'HP':          return _pc.getMaxHP().toString();
      case 'MAXHP':       return _pc.getMaxHP().toString();
      case 'ALTHP':       return _pc.getMaxHP().toString();
      case 'XP':
      case 'EXP':         return _pc.getXP().toString();
      case 'XPNEXT':
      case 'EXP.CURRENT': return _pc.getXP().toString();
      case 'EXP.NEXT':    return _pc.getXPForNextLevel().toString();
      case 'TOTALLEVELS': return _pc.getTotalCharacterLevel().toString();
      case 'CR':          return _pc.getTotalCharacterLevel().toString();
      case 'SIZE':        return _pc.getRaceSize();
      case 'SIZELONG':    return _sizeToLong(_pc.getRaceSize());
      case 'GAMEMODE':    return _pc.getGameMode();
      case 'FOLLOWEROF':  return '';
      case 'PORTRAIT.THUMB': return '';
      case 'FACE.SHORT':  return '5 ft.';
      case 'FACE':        return '5 ft. × 5 ft.';
      case 'REACH':       return '5 ft.';
      case 'VISION':      return _data('vision') as String? ?? '';
      case 'COLOR':       return _color(parts);
      case 'LENGTH':      return _length(parts);
      case 'MOVE':        return _move(parts);
      case 'POOL':        return _pool(parts);
      case 'MOVEMENT':    return _movementSummary();
      case 'HANDED':      return _data('handed') as String? ?? 'Right';
      case 'FAVOREDLIST':
      case 'FAVOREDCLASS': return _favoredClassList();

      case 'STAT':        return _stat(parts);
      case 'BASESAVE':
      case 'SAVE':        return _save(parts);
      case 'CHECK':
      case 'CHECKS':      return _save(parts);
      case 'ATTACK':      return _attack(parts);
      case 'SKILLSIT':    return _skillSit(parts);

      case 'AC':          return _ac(parts);
      case 'INITIATIVEMOD':
      case 'INITIATIVE':  return _signed(_pc.getInitiative());
      case 'INITIATIVEBONUS': return _signed(_pc.getInitiative() - _pc.getStatModByAbb('DEX'));
      case 'BAB':         return _pc.getBAB();

      case 'CLASS':       return _cls(parts);
      case 'CLASSLIST':   return _pc.getClassLevelSummary();

      case 'SKILL':       return _skill(parts);

      case 'LANGUAGES':   return _languages();
      case 'WEAPONPROFS':
      case 'WEAPONPROF':  return _weaponProfs(parts);

      case 'WEAPON':      return _weapon(parts);

      case 'ABILITY':
      case 'ABILITYALL':  return _ability(parts);
      case 'FEAT':        return _feat(parts);

      case 'DOMAIN':      return _domain(parts);
      case 'TEMPLATE':    return _template(parts);
      case 'TEMPLATELIST':return _pc.getAppliedTemplateKeys().join(', ');

      case 'SPELLLISTCLASS':    return _spellClass(parts);
      case 'SPELLLISTCLASSTYPE':return _spellClassType(parts);
      case 'SPELLLISTKNOWN':    return _spellListKnown(parts);
      case 'SPELLLISTCAST':     return _spellListCast(parts);
      case 'SPELLLISTMEMORIZE': return _spellListMemorize(parts);
      case 'SPELLLISTTYPE':     return _spellClassType(parts);
      case 'MAXSKILLLEVEL':     return _pc.getTotalCharacterLevel().toString();
      case 'MAXCCSKILLLEVEL':   return (_pc.getTotalCharacterLevel() / 2).ceil().toString();
      case 'MAXSPELLLEVEL':     return _maxSpellLevel(parts);
      case 'SPELLMEM':          return _spell(parts);
      case 'SPELL':             return _spell(parts);
      case 'SPELLBOOKNAME':     return _spellBookName(parts);
      case 'SPELLLISTDC':
        if (parts.length >= 2) {
          final idx = int.tryParse(parts[1]) ?? 0;
          final sc = _spellClsByIdx(idx);
          final baseLevel = parts.length >= 3 ? (int.tryParse(parts[2]) ?? 0) : 0;
          return sc != null ? _pc.getSpellSaveDC(baseLevel, sc.key).toString() : '10';
        }
        return '10';

      case 'WEAPONH':     return _weaponH(parts);

      case 'EQ':
      case 'EQUIP':       return _equipItem(parts);
      case 'ARMOR':       return _armorEquipped(parts);

      case 'FUNDS':       return _pc.getFunds().toStringAsFixed(2);
      case 'GOLD':        return parts.length == 1 ? _pc.getFunds().toStringAsFixed(2) : _goldToken(parts);
      case 'TOTALVALUE':  return _pc.getFunds().toStringAsFixed(2);
      case 'TOTAL': {
        // TOTAL.WEIGHT — sum of gear weight × qty
        // TOTAL.VALUE  — sum of gear cost × qty
        final sub = parts.length > 1 ? parts[1].toUpperCase() : '';
        final gear = (_data('gear') as List? ?? []).whereType<Map>();
        if (sub == 'WEIGHT') {
          double total = 0;
          for (final g in gear) {
            final w = (g['weight'] as num?)?.toDouble() ?? 0;
            final q = (g['qty'] as num?)?.toDouble() ?? 1;
            total += w * q;
          }
          return total.toStringAsFixed(1);
        }
        if (sub == 'VALUE') {
          double total = 0;
          for (final g in gear) {
            final c = (g['cost'] as num?)?.toDouble() ?? 0;
            final q = (g['qty'] as num?)?.toDouble() ?? 1;
            total += c * q;
          }
          return total.toStringAsFixed(2);
        }
        return '';
      }

      case 'SR':           return _pc.getSR().toString();
      case 'DR':           return _data('dr') ?? '';
      case 'SPELLFAILURE': return _pc.getSpellFailureTotal().toString();
      case 'MAXDEX':
        final cap = _pc.getMaxDexCapFromArmor();
        return cap != null ? '+$cap' : '+99';
      case 'ACCHECK':      return _pc.getArmorCheckPenalty().toString();
      case 'ARMORCHECK':   return _pc.getArmorCheckPenalty().toString();

      case 'TEXT':
        // TEXT.LENGTH.token — returns the character length of pcstring(token).
        // Used in spell template to check if a SOURCELINK is present.
        if (parts.length >= 3 && parts[1].toUpperCase() == 'LENGTH') {
          final inner = parts.sublist(2).join('.');
          return _resolve(inner).length.toString();
        }
        return '';

      case 'EXPORT':      return _export(parts);
      case 'PAPERINFO':   return _paperinfo(parts);
      case 'UNITSET':     return _unitset(parts);
      case 'INVALIDTEXT': return '';
      case 'DIR':         return '';

      // ── Biographical fields ──────────────────────────────────────────────
      case 'DESC':            return _pc.getBiography();
      case 'PORTRAIT':        return '';
      case 'REGION':          return _data('region') as String? ?? '';
      case 'LOCATION':        return _data('location') as String? ?? '';
      case 'RESIDENCE':       return _data('residence') as String? ?? '';
      case 'INTERESTS':       return _data('interests') as String? ?? '';
      case 'PHOBIAS':         return _data('phobias') as String? ?? '';
      case 'CATCHPHRASE':     return _data('catchPhrase') as String? ?? '';
      case 'SPEECHTENDENCY':  return _data('speechTendency') as String? ?? '';
      case 'PERSONALITY1':    return _pc.getPersonalityTrait(1);
      case 'PERSONALITY2':    return _pc.getPersonalityTrait(2);


      // ── Notes ────────────────────────────────────────────────────────────
      case 'NOTE':      return _note(parts);

      // ── Temp bonuses ─────────────────────────────────────────────────────
      case 'TEMPBONUS': return _tempBonus(parts);

      // ── Special abilities ────────────────────────────────────────────────
      case 'SPECIALABILITY': return _specialAbility(parts);
      case 'SPECIALLIST':    return _specialList();
      case 'PROHIBITEDLIST': return _prohibitedList();

      // ── Ability lists (comma-separated) ──────────────────────────────────
      case 'ABILITYLIST': return _abilityList(parts);

      // ── Followers / companions ───────────────────────────────────────────
      case 'FOLLOWERTYPE': return _followerType(parts);

      // ── Equipment by type ────────────────────────────────────────────────
      case 'EQTYPE': return _eqType(parts);

      // ── Miscellaneous wealth sections ────────────────────────────────────
      case 'MISC': {
        // MISC.FUNDS — display funds as a formatted string
        // MISC.MAGIC / MISC.COMPANIONS — magic item value / companion value
        final sub = parts.length > 1 ? parts[1].toUpperCase() : '';
        if (sub == 'FUNDS' || sub == 'MAGIC' || sub == 'COMPANIONS' || sub == 'TOTAL') {
          return _pc.getFunds().toStringAsFixed(2);
        }
        // Other MISC subtokens (CASH, GEAR value etc.) — stub with context
        return _stub('MISC subtoken: $token');
      }

      default: {
        // Try as a bare game/character variable (e.g. UseAlternateDamage,
        // UseCombatManueverBonus) before logging as a true stub.
        final cVars = _data('charVariables') as Map? ?? {};
        final varKey = parts[0]; // single-word token matches variable name
        if (cVars.containsKey(varKey)) {
          return (cVars[varKey] as double? ?? 0.0).toInt().toString();
        }
        // Game-mode boolean flags defined in miscinfo.lst — silently return '0'
        // (false) if not defined. These control which optional rules are active.
        if (varKey.startsWith('Use') || varKey.startsWith('use')) return '0';
        return _stub('top-level: $token');
      }
    }
  }

  // ─── Stat tokens: STAT.N.SCORE / .MOD / .NAME / .BASEMOD / .MISC ──────────

  String _stat(List<String> parts) {
    // STAT.N with no subtoken → return the score (same as STAT.N.SCORE)
    if (parts.length == 2) return _stat([parts[0], parts[1], 'SCORE']);
    if (parts.length < 3) return '';
    final idx = int.tryParse(parts[1]);
    if (idx == null || idx >= _statOrder.length) return '';
    final abb = _statOrder[idx];
    final dataset = _dataset;
    switch (parts[2]) {
      case 'NAME':    return abb;
      case 'ABB':     return abb;
      // Base score — no temporary or equipment bonuses.
      // When parts[3]+ exist they are NOTEMP/NOEQUIP qualifiers on the MOD
      // sub-token (handled below); here parts[2] IS NOTEMP/NOEQUIP itself.
      case 'NOTEMP':
      case 'NOEQUIP':
        if (dataset != null) {
          try {
            final stat = (dataset.stats as List).firstWhere((s) => s.getKeyName() == abb);
            return _pc.getScoreBase(stat).toString();
          } catch (_) {}
        }
        return (_data('statScores')?[abb] as num?)?.toString() ?? '10';
      // Effective (total) score — includes racial / item / spell bonuses.
      case 'NOTEMP.NOEQUIP': // only matches when token is NOT split by '.'
      case 'SCORE':
      case 'TOTAL':
        if (dataset != null) {
          try {
            final stat = (dataset.stats as List).firstWhere((s) => s.getKeyName() == abb);
            return _pc.getEffectiveScore(stat).toString();
          } catch (_) {}
        }
        return (_data('statScores')?[abb] as num?)?.toString() ?? '10';
      case 'MOD':
      case 'BASEMOD': {
        // STAT.N.MOD.NOTEMP or STAT.N.MOD.NOTEMP.NOEQUIP → base modifier only.
        final isBaseOnly = parts.length > 3 &&
            (parts[3].toUpperCase() == 'NOTEMP' || parts[3].toUpperCase() == 'NOEQUIP');
        if (dataset != null) {
          try {
            final stat = (dataset.stats as List).firstWhere((s) => s.getKeyName() == abb);
            if (isBaseOnly) {
              final base = _pc.getScoreBase(stat);
              return _signed(((base - 10) / 2).floor());
            }
            return _signed(_pc.getModTotal(stat));
          } catch (_) {}
        }
        final score = (_data('statScores')?[abb] as num?)?.toInt() ?? 10;
        return _signed(((score - 10) / 2).floor());
      }
      case 'BASE':
        if (dataset != null) {
          try {
            final stat = (dataset.stats as List).firstWhere((s) => s.getKeyName() == abb);
            return _pc.getScoreBase(stat).toString();
          } catch (_) {}
        }
        return '10';
      case 'RACIALMOD':
        if (dataset != null) {
          try {
            final stat = (dataset.stats as List).firstWhere((s) => s.getKeyName() == abb);
            return _pc.getRacialBonus(stat).toString();
          } catch (_) {}
        }
        return '0';
      case 'LEVELBUMP':
        if (dataset != null) {
          try {
            final stat = (dataset.stats as List).firstWhere((s) => s.getKeyName() == abb);
            return _pc.getLevelStatGains(stat).toString();
          } catch (_) {}
        }
        return '0';
      case 'MISC':
        return _pc.getStatMiscBonus(abb).toString();
      case 'LONGNAME':
        // Full stat name e.g. "Strength"
        const longNames = {
          'STR': 'Strength', 'DEX': 'Dexterity', 'CON': 'Constitution',
          'INT': 'Intelligence', 'WIS': 'Wisdom', 'CHA': 'Charisma',
        };
        return longNames[abb] ?? abb;
      case 'MOD.NOTEMP.NOEQUIP':
      case 'MOD.NOTEMP':
        // base mod without temp/equip bonuses — use base score
        if (dataset != null) {
          try {
            final stat = (dataset.stats as List).firstWhere((s) => s.getKeyName() == abb);
            final base = _pc.getScoreBase(stat);
            return _signed(((base - 10) / 2).floor());
          } catch (_) {}
        }
        return '+0';
      case 'BASE': {
        // STAT.N.BASE — base score without item/temp bonuses
        if (dataset != null) {
          try {
            final stat = (dataset.stats as List).firstWhere((s) => s.getKeyName() == abb);
            return _pc.getScoreBase(stat).toString();
          } catch (_) {}
        }
        // Approximate base = total score minus item/temp bonuses
        final scores = _data('statScores') as Map? ?? {};
        return ((scores[abb] as num?)?.toInt() ?? 10).toString();
      }
      case 'PENALTY': return '0'; // stat damage penalty not tracked
    }
    // Multi-part: STAT.N.MOD.NOTEMP etc — try first sub-token
    if (parts.length > 3) return _stat(parts.sublist(0, 3));
    return _stub('STAT field: ${parts.join(".")}');
  }

  // ─── Save tokens: SAVE.N.TOTAL / .BASE / .STAT ────────────────────────────

  String _save(List<String> parts) {
    if (parts.length < 3) return '';
    final idx = int.tryParse(parts[1]);
    if (idx == null || idx >= _saveNames.length) return '';
    // Stat abbreviation for each save
    const saveStats = ['CON', 'DEX', 'WIS'];
    final saveName  = _saveNames[idx]; // Fortitude / Reflex / Will
    final statAbb   = saveStats[idx];
    final statMod   = _pc.getStatModByAbb(statAbb);
    final total     = idx == 0 ? _pc.getFortSave()
                    : idx == 1 ? _pc.getRefSave()
                    :            _pc.getWillSave();
    // Base = total − stat mod (approximation; magic items roll into total)
    final base  = total - statMod;
    final magic = _pc.getSaveMagicBonus(saveName);
    final misc  = _pc.getSaveMiscBonus(saveName, total, base, statMod);
    switch (parts[2]) {
      case 'NAME':  return saveName;
      case 'TOTAL': return _signed(total);
      case 'BASE':  return base.toString();
      case 'STATMOD':
      case 'STAT':  return _signed(statMod);
      case 'MAGIC': return _signed(magic);
      case 'EPIC':  return '0';
      case 'MISC.NOMAGIC.NOSTAT':
      case 'MISC':  return _signed(misc);
      // Compound sub-token: parts[2] is e.g. "MISC" but parts contains more
      // (e.g. SAVE.0.MISC.NOMAGIC.NOSTAT parsed as parts[2]="MISC")
      // Already handled above via join(".") matching.
    }
    // Try joining remaining parts in case the dot split separated compound tokens
    if (parts.length > 3) {
      final compound = parts.sublist(2).join('.');
      if (compound == 'MISC.NOMAGIC.NOSTAT') return _signed(misc);
    }
    return _stub('SAVE field: ${parts.join(".")}');
  }

  // ─── AC tokens: AC.TOTAL / .FLAT / .TOUCH / .ARMOR / .SHIELD / .DEX ──────

  String _ac(List<String> parts) {
    if (parts.length == 1) return _pc.getAC().toString();
    switch (parts[1].toUpperCase()) {
      case 'TOTAL':        return _pc.getAC().toString();
      case 'FLATFOOTED':   return _pc.getFlatFootedAC().toString();
      case 'TOUCH':        return _pc.getTouchAC().toString();
      case 'BASE':         return '10';
      case 'ARMOR':        return _pc.getArmorBonus().toString();
      case 'ARMORENHANCEMENT':
      case 'ENHANCEMENT':  return _pc.getArmorEnhancementBonus().toString();
      case 'SHIELD':       return _pc.getShieldBonus().toString();
      case 'SHIELDENHANCEMENT': return _pc.getShieldEnhancementBonus().toString();
      case 'ABILITY':
      case 'DEX':          return _signed(_pc.getStatModByAbb('DEX'));
      case 'DEFLECTION':   return _pc.getDeflectionBonus().toString();
      case 'DODGE':        return _pc.getDodgeBonus().toString();
      case 'NATURALARMOR':
      case 'NATURAL':      return _pc.getNaturalArmorBonus().toString();
      case 'SIZE':         return _pc.getSizeACModifier().toString();
      case 'MISC':
        // MISC = total AC − sum of all known components
        final computed = 10 + _pc.getStatModByAbb('DEX') +
            _pc.getArmorBonus() + _pc.getShieldBonus() +
            _pc.getNaturalArmorBonus() + _pc.getDeflectionBonus() +
            _pc.getDodgeBonus() + _pc.getSizeACModifier();
        return (_pc.getAC() - computed).toString();
    }
    return _pc.getAC().toString();
  }

  // ─── Class tokens: CLASS.N.NAME / .LEVEL / .ABB ───────────────────────────

  String _cls(List<String> parts) {
    final classLevels = _data('classLevels') as List? ?? [];
    if (parts.length < 3) return '';
    final idx = int.tryParse(parts[1]);
    if (idx == null) return '';

    // Build class summary: unique classes in order
    final seen = <String>[];
    final counts = <String, int>{};
    for (final l in classLevels) {
      if (l is Map) {
        final k = l['classKey'] as String? ?? '';
        if (!seen.contains(k)) seen.add(k);
        counts[k] = (counts[k] ?? 0) + 1;
      }
    }
    if (idx >= seen.length) return '';
    final key = seen[idx];

    final clsObj = _classObj(key);
    final clsLvl = counts[key] ?? 0;

    switch (parts[2]) {
      case 'NAME':      return key;
      case 'ABB':       return key.length > 3 ? key.substring(0, 3) : key;
      case 'LEVEL':     return clsLvl.toString();
      case 'TYPE':      return _classType(key);
      case 'BAB':       return _pc.getBABAsInt().toString();
      case 'SPELLSTAT': {
        try { return (clsObj as dynamic).getSpellStat() as String? ?? ''; } catch (_) {}
        return '';
      }
      case 'SPELLTYPE': {
        try { return (clsObj as dynamic).getSpellType() as String? ?? ''; } catch (_) {}
        return '';
      }
      case 'MEMORIZE': {
        try {
          final mem = (clsObj as dynamic).getSafeObject('MEMORIZE') as bool? ?? false;
          return mem ? 'Y' : 'N';
        } catch (_) {}
        return 'N';
      }
      case 'CAST': {
        // CLASS.N.CAST.M — spells per day at spell level M for this class
        if (parts.length > 3 && clsObj != null) {
          final slotIdx = int.tryParse(parts[3]) ?? 0;
          try {
            final slots = (clsObj as dynamic).getCastSlotsAt(clsLvl) as List?;
            if (slots != null && slotIdx < slots.length) return slots[slotIdx].toString();
          } catch (_) {}
        }
        return '0';
      }
      case 'KNOWN': {
        // CLASS.N.KNOWN.M — spells known at spell level M for this class
        if (parts.length > 3 && clsObj != null) {
          final slotIdx = int.tryParse(parts[3]) ?? 0;
          try {
            final known = (clsObj as dynamic).getKnownSlotsAt(clsLvl) as List?;
            if (known != null && slotIdx < known.length) return known[slotIdx].toString();
          } catch (_) {}
        }
        return '0';
      }
    }
    return _stub('CLASS field: ${parts.join(".")}');
  }

  dynamic _classObj(String key) {
    try {
      final dataset = _dataset;
      if (dataset == null) return null;
      return (dataset.classes as List).firstWhere((c) => c.getKeyName() == key);
    } catch (_) { return null; }
  }

  String _classType(String key) {
    try {
      final dataset = _dataset;
      if (dataset == null) return '';
      final cls = (dataset.classes as List).firstWhere((c) => c.getKeyName() == key);
      return cls.get(null)?.toString() ?? '';
    } catch (_) { return ''; }
  }

  // ─── Skill tokens: SKILL.N.TOTAL / .RANK / .NAME / .MOD ──────────────────

  String _skill(List<String> parts) {
    if (parts.length < 3) return '';
    final idx = int.tryParse(parts[1]);
    if (idx == null) return '';
    final skills = _allSkills();
    if (idx >= skills.length) return '';
    final sk = skills[idx];
    final skName = sk['name'] as String? ?? '';
    final skKey  = sk['key'] as String? ?? skName;
    switch (parts[2]) {
      case 'NAME':       return skName;
      case 'TOTAL':      return _pc.getSkillBonus(skName, skKey).toString();
      case 'RANK':       return _pc.getSkillRanks(sk).toString();
      case 'MOD':        return _pc.getSkillBonus(skName, skKey).toString();
      case 'MISC':       return _pc.getSkillMiscBonus(skName).toString();
      case 'UNTRAINED':  return '1';
      case 'EXCLUSIVE':  return '0'; // exclusive skills not tracked
      case 'CLASSSK':    return _pc.isClassSkill(skName) ? '1' : '0';
      case 'ABILITY':    return _skillAbility(sk);
      case 'ABMOD':      return _signed(_pc.getStatModByAbb(_skillAbility(sk)));
      case 'ACHECK': {
        final s = sk['skill'];
        try {
          if (s != null && ((s as dynamic).hasArmorCheckPenalty() as bool? ?? false)) {
            return _pc.getArmorCheckPenalty().toString();
          }
        } catch (_) {}
        return '0';
      }
    }
    return _stub('SKILL field: ${parts.join(".")}');
  }

  List<Map<String, dynamic>>? _skillCache;

  // VIEW=VISIBLE_EXPORT: show skills the character has ranks in, plus all
  // base (non-specialised) skills. Specialisations are identified by having
  // parentheses in the name, e.g. "Craft (Alchemy)" — these only appear
  // when the character has actually invested ranks in that specialisation.
  List<Map<String, dynamic>> _allSkills() {
    if (_skillCache != null) return _skillCache!;
    final dataset = _dataset;
    if (dataset == null) return [];
    final results = <Map<String, dynamic>>[];
    for (final s in dataset.skills) {
      try {
        final name = s.getKeyName();
        if (name.isEmpty) continue;
        // Skip placeholder / artifact skill names
        if (name.toLowerCase() == 'not used' || name.toLowerCase() == 'untrained') continue;

        // Visibility filter: the template/export sheet only renders skills that are
        // VISIBLE:YES or VISIBLE:EXPORT (or have no VISIBLE token, which defaults to YES).
        // VISIBLE:DISPLAY skills appear in the GUI tabs for selection but not on the
        // printed/exported sheet — e.g. all Craft (X) specialisations are DISPLAY-only
        // while Craft (Untrained) is EXPORT.
        String vis = 'YES';
        try {
          vis = (s as dynamic).getSafeObject(
              CDOMObjectKey.getConstant<String>('VISIBLE')) as String? ?? 'YES';
        } catch (_) {}
        if (vis == 'DISPLAY' || vis == 'NO') continue;

        final entry = <String, dynamic>{
          'name':  name,
          'key':   name,
          'stat':  s.getKeyStatAbb(),
          'skill': s,
        };
        final ranks = _pc.getSkillRanks(entry);
        // RSRD uses two entries per specialised skill:
        //   KEY:Craft (Alchemy)  VISIBLE:DISPLAY  — GUI selection only, filtered above
        //   KEY:Craft ~ Alchemy  VISIBLE:EXPORT   — sheet only, with PREMULT:ranks>=1
        // The ~ in the KEY marks the export PREMULT variant; it must only appear
        // when the character has ranks.  The untrained fallback is the separate
        // "Craft (Untrained)" / "Perform (Untrained)" skill entry.
        final isExportPremult = name.contains('~');
        if (isExportPremult) {
          if (ranks > 0) results.add(entry);
          continue;
        }
        final isSpecialised = name.contains('(');
        bool canUseUntrained = false;
        try { canUseUntrained = (s as dynamic).isUntrained() as bool? ?? false; } catch (_) {}
        if (ranks > 0 || !isSpecialised || canUseUntrained) {
          results.add(entry);
        }
      } catch (_) {}
    }
    results.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
    return _skillCache = results;
  }

  // ─── Weapon tokens: WEAPON.N.TOHIT / .DAMAGE / .NAME / .CRIT / .RANGE ────

  String _weapon(List<String> parts) {
    if (parts.length < 3) return '';
    final idx = int.tryParse(parts[1]);
    if (idx == null) return '';
    final weapons = _equippedWeapons();
    if (idx >= weapons.length) return '';
    final w = weapons[idx];
    switch (parts[2]) {
      case 'NAME':    return w['name'] as String? ?? '';
      case 'TOHIT':   return w['tohit'] as String? ?? '+0';
      case 'DAMAGE':  return w['damage'] as String? ?? '1d4';
      case 'CRIT':    return w['crit'] as String? ?? '20/×2';
      case 'CRITRANGE': return w['critRange'] as String? ?? '20';
      case 'CRITMULT':  return w['critMult'] as String? ?? '×2';
      case 'RANGE':   return w['range'] as String? ?? '—';
      case 'TYPE':    return w['type'] as String? ?? '';
      case 'HAND':    return w['hand'] as String? ?? '';
      case 'SIZE':    return w['size'] as String? ?? 'M';
      case 'ISRANGED': return (w['isRanged'] as bool? ?? false) ? '1' : '0';
      case 'WEIGHT':  return '0';
      case 'ATTACKS':
      case 'BASEHIT':
      case 'TOTALHIT':    return w['tohit'] as String? ?? '+0';
      // Off-hand / two-handed / two-weapon variants — approximations
      case 'OHHIT':       return w['tohit'] as String? ?? '+0';
      case 'THHIT':       return w['tohit'] as String? ?? '+0';
      case 'TWPHITH':     return w['tohit'] as String? ?? '+0';
      case 'TWPHITL':     return w['tohit'] as String? ?? '+0';
      case 'TWOHIT':      return w['tohit'] as String? ?? '+0';
      case 'BASICDAMAGE': return w['damage'] as String? ?? '1d6';
      case 'OHDAMAGE':    return w['damage'] as String? ?? '1d6';
      case 'THDAMAGE':    return w['damage'] as String? ?? '1d6';
      case 'SPROP':       return w['sprop'] as String? ?? '';
      case 'CATEGORY':    return (w['isRanged'] as bool? ?? false) ? 'Ranged' : 'Melee';
      case 'LONGNAME':    return w['name'] as String? ?? '';
      case 'PROFICIENCY': return w['name'] as String? ?? '';
      case 'REACHUNIT':   return 'ft.';
      case 'MULT': {
        // Extract multiplier from '20/×2' or '19-20/×3' crit string
        final crit = w['crit'] as String? ?? '20/×2';
        final slash = crit.lastIndexOf('/');
        return slash >= 0 ? crit.substring(slash + 1) : '×2';
      }
      case 'ISTYPE': {
        // WEAPON.N.ISTYPE.TypeName
        if (parts.length < 4) return '0';
        final typeQuery = parts[3].toLowerCase();
        final typeList = (w['typeList'] as List?)?.cast<String>() ?? [];
        return typeList.any((t) => t.toLowerCase() == typeQuery) ? '1' : '0';
      }
      case 'REACH': {
        // Weapon reach — melee weapons are 5 ft. by default; reach weapons 10 ft.
        final types = (w['typeList'] as List?)?.cast<String>() ?? [];
        return types.any((t) => t.toLowerCase() == 'reach') ? '10' : '5';
      }
      case 'RANGELIST': {
        // WEAPON.N.RANGELIST.M — range at increment M (0-based).
        // WEAPON.N.RANGELIST.M.TOTALHIT — to-hit with -2 per increment.
        // WEAPON.N.RANGELIST.M.DAMAGE — damage (no penalty).
        final rangeStr = w['range'] as String? ?? '0';
        final rangeIncFt = int.tryParse(rangeStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        if (parts.length >= 4) {
          final increment = int.tryParse(parts[3]) ?? 0;
          final sub = parts.length > 4 ? parts[4].toUpperCase() : '';
          if (sub.isEmpty) {
            // Return the range distance at this increment
            return rangeIncFt > 0 ? '${(increment + 1) * rangeIncFt}' : '—';
          }
          // Handle RANGELIST.M.CONTENTS.N.TOTALHIT / .DAMAGE (ammo variant)
          final isContents = sub == 'CONTENTS' && parts.length > 6;
          final finalSub = isContents ? (parts.length > 6 ? parts[6].toUpperCase() : '') : sub;
          switch (finalSub) {
            case 'TOTALHIT': {
              final base = w['tohit'] as String? ?? '+0';
              // Apply -2 per range increment beyond first
              if (increment == 0) return base;
              final firstHit = int.tryParse(base.replaceAll('+', '')) ?? 0;
              return _signed(firstHit - increment * 2);
            }
            case 'DAMAGE':   return w['damage'] as String? ?? '1d4';
          }
        }
        return _stub('WEAPON.RANGELIST: ${parts.join(".")}');
      }
      case 'CONTENTS': {
        // WEAPON.N.CONTENTS — count of ammo types (0 = no ammo)
        // WEAPON.N.CONTENTS.M — name of ammo at index M
        // WEAPON.N.CONTENTS.M.SPROP — special property of ammo
        if (parts.length == 3) return '0'; // no ammo count
        if (parts.length >= 4) return '';  // no ammo name/sprop
        return '0';
      }
      case 'CONTENTS-1': return '0'; // loop bound for ammo
    }
    return _stub('WEAPON field: ${parts.join(".")}');
  }

  List<Map<String, dynamic>>? _weaponCache;

  List<Map<String, dynamic>> _equippedWeapons() {
    if (_weaponCache != null) return _weaponCache!;
    final gear          = _data('gear')          as List? ?? [];
    final equippedSlots = _data('equippedSlots') as Map?  ?? {};
    final result = <Map<String, dynamic>>[];
    for (final slotKey in equippedSlots.keys) {
      final slotLower = slotKey.toString().toLowerCase();
      final isWeaponSlot = slotLower.contains('primary') ||
          slotLower.contains('secondary') ||
          slotLower.contains('off hand') ||
          slotLower.startsWith('both') ||
          slotLower.startsWith('natural') ||
          slotLower == 'unarmed';
      if (!isWeaponSlot) continue;
      final gearKey = equippedSlots[slotKey];
      if (gearKey == null) continue;
      final item = gear.where((g) => g is Map && (g['key'] == gearKey || g['name'] == gearKey)).firstOrNull;
      if (item == null) continue;
      result.add(_weaponStats(item as Map, slotKey.toString()));
    }
    return _weaponCache = result;
  }

  Map<String, dynamic> _weaponStats(Map item, String slot) {
    final name = item['name'] as String? ?? '';

    // Determine melee vs ranged — check stored flag first, then dataset TYPE list.
    bool isRanged = item['isRanged'] as bool? ?? false;

    // Look up the dataset item for damage string and type list.
    String dmg = '';
    String critStr = '20/×2';
    List<String> typeList = [];
    try {
      final dataset = _dataset;
      if (dataset != null) {
        final dsKey = item['dsKey'] as String? ?? item['key'] as String? ?? name;
        for (final eq in (dataset as dynamic).equipment as List) {
          if ((eq as dynamic).getKeyName() == dsKey) {
            dmg = (eq as dynamic).getDamageString() as String? ?? '';
            // Crit range + multiplier
            try {
              final critR = (eq as dynamic).getCritRange() as int? ?? 1;
              final critM = (eq as dynamic).getCritMult()  as String? ?? '';
              final thrRange = critR <= 1 ? '20' : '${21 - critR}–20';
              critStr = critM.isNotEmpty ? '$thrRange/$critM' : thrRange;
            } catch (_) {}
            typeList = ((eq as dynamic).getSafeListFor(
                ListKey.getConstant<String>('TYPE')) as List?)
                ?.cast<String>() ?? [];
            if (typeList.any((t) => t.toUpperCase() == 'RANGED')) isRanged = true;
            break;
          }
        }
      }
    } catch (_) {}

    // Attack = BAB + stat mod (STR melee / DEX ranged) + TOHIT bonus accumulator.
    final bab     = _pc.getBABAsInt();
    final statMod = _pc.getStatModByAbb(isRanged ? 'DEX' : 'STR');
    final tohitBonus = isRanged ? _pc.getTohitBonusRanged() : _pc.getTohitBonusMelee();
    final tohit = bab + statMod + tohitBonus;

    final attacks = <String>[];
    var cur = tohit;
    while (cur > 0 || attacks.isEmpty) {
      attacks.add(_signed(cur));
      cur -= 5;
      if (cur <= tohit - 20) break;
    }

    // Damage = base dice + STR mod (melee only, not ranged unless composite bow).
    final dmgMod = isRanged ? 0 : statMod;
    final dmgStr = dmg.isNotEmpty
        ? (dmgMod > 0 ? '$dmg+$dmgMod' : dmgMod < 0 ? '$dmg$dmgMod' : dmg)
        : (dmgMod != 0 ? _signed(dmgMod) : '—');

    return {
      'name':     name,
      'tohit':    attacks.join('/'),
      'damage':   dmgStr,
      'crit':     critStr,
      'isRanged': isRanged,
      'range':    isRanged ? '60 ft.' : 'melee',
      'type':     typeList.join('.'),
      'typeList': typeList,
    };
  }

  // ─── SKILLSIT tokens: SKILLSIT.N / .NAME / .TOTAL / .RANK / .ABILITY etc. ──

  String _skillSit(List<String> parts) {
    if (parts.length < 2) return '';
    final idx = int.tryParse(parts[1]);
    if (idx == null) return '';
    final skills = _allSkills();
    if (idx >= skills.length) return '';
    final sk = skills[idx];
    final skName = sk['name'] as String? ?? '';
    final skKey  = sk['key'] as String? ?? skName;
    // SKILLSIT.N with no sub-token → skill name (used in <#assign skillTemp>)
    if (parts.length == 2) return skName;
    final ranks   = _pc.getSkillRanks(sk);
    final statMod = _pc.getStatModByAbb(_skillAbility(sk));
    final misc    = _pc.getSkillBonus(skName, skKey);
    switch (parts[2]) {
      case 'NAME':      return skName;
      case 'TOTAL':     return (ranks + statMod + misc).toString();
      case 'RANK':      return ranks.toString();
      case 'ABMOD':
      case 'MOD':       return _signed(statMod);
      case 'MISC':      return misc != 0 ? misc.toString() : '0';
      case 'ABILITY':   return _skillAbility(sk);
      case 'UNTRAINED':
        final s = sk['skill'];
        return (s is Skill && !s.isUntrained()) ? '0' : '1';
      case 'EXCLUSIVE': return '0'; // intentional: exclusive skills not tracked
      case 'CLASSSK':   return _pc.isClassSkill(skName) ? '1' : '0';
      case 'ACPv':
        // Armor check penalty applies flag (from ACHECK:YES on the skill LST)
        final sk2 = sk['skill'];
        if (sk2 is Skill && sk2.hasArmorCheckPenalty()) {
          return _pc.getArmorCheckPenalty().toString();
        }
        return '0';
    }
    return _stub('SKILLSIT field: ${parts.join(".")}');
  }

  String _skillAbility(Map<String, dynamic> sk) {
    try {
      final s = sk['skill'];
      if (s is Skill) {
        final abb = s.getKeyStatAbb();
        if (abb.isNotEmpty) return abb.toUpperCase();
      }
      // fallback: stat stored during _allSkills build
      final stat = sk['stat'] as String? ?? '';
      if (stat.isNotEmpty) return stat.toUpperCase();
    } catch (_) {}
    return 'DEX';
  }

  // ─── ATTACK tokens: ATTACK.MELEE / .RANGED / .GRAPPLE ─────────────────────

  String _attack(List<String> parts) {
    if (parts.length < 2) return '';
    final type = parts[1].toUpperCase();
    final sub  = parts.length > 2 ? parts[2].toUpperCase() : '';

    final bab = _pc.getBABAsInt();
    int totalHit;
    int statMod;
    switch (type) {
      case 'MELEE':
        statMod  = _pc.getStatModByAbb('STR');
        totalHit = bab + statMod + _pc.getTohitBonusMelee();
        break;
      case 'RANGED':
        statMod  = _pc.getStatModByAbb('DEX');
        totalHit = bab + statMod + _pc.getTohitBonusRanged();
        break;
      case 'GRAPPLE':
        statMod  = _pc.getStatModByAbb('STR');
        totalHit = bab + statMod;
        break;
      case 'TOUCH':
        // Touch attacks use BAB + DEX mod, ignoring armor
        statMod  = _pc.getStatModByAbb('DEX');
        totalHit = bab + statMod;
        break;
      case 'RANGEDTOUCH':
        statMod  = _pc.getStatModByAbb('DEX');
        totalHit = bab + statMod + _pc.getTohitBonusRanged();
        break;
      default:
        return _stub('ATTACK type: ${parts.join(".")}');
    }

    // 3.5e iterative attacks: count is determined by BASE attack bonus,
    // not total (BAB 1-5→1 atk, 6-10→2, 11-15→3, 16+→4).
    String _atkString(int base) {
      final count = bab <= 5 ? 1 : bab <= 10 ? 2 : bab <= 15 ? 3 : 4;
      final attacks = <String>[];
      var cur = base;
      for (var i = 0; i < count; i++) {
        attacks.add(_signed(cur));
        cur -= 5;
      }
      return attacks.join('/');
    }

    switch (sub) {
      case '':
      case 'TOTAL':    return _atkString(totalHit);
      case 'BASE':     return _atkString(bab);
      case 'STAT':     return _signed(statMod);
      case 'SIZE':     return _signed(_pc.getSizeACModifier());
      case 'EPIC':     return '+0';
      // MISC attack bonus: feats like Weapon Focus. Route through accumulator.
      case 'MISC': {
        final miscMelee  = _pc.getBonusTo('COMBAT', 'TOHIT');
        final miscRanged = _pc.getBonusTo('COMBAT', 'TOHIT');
        // Subtract stat+BAB from total to get misc-only component
        final miscOnly = totalHit - bab - statMod;
        return miscOnly != 0 ? _signed(miscOnly) : '+0';
      }
      case 'NOMAGIC.NOSTAT': return _signed(bab);
    }
    return _stub('ATTACK field: ${parts.join(".")}');
  }

  String _weaponProfs(List<String> parts) {
    final profs = _pc.getWeaponProficiencies().toList()..sort();
    if (parts.length < 2) return profs.join(', ');
    final idx = int.tryParse(parts[1]);
    if (idx == null || idx >= profs.length) return '';
    if (parts.length >= 3 && parts[2] == 'NAME') return profs[idx];
    return profs[idx];
  }

  // ─── Ability / feat tokens ─────────────────────────────────────────────────

  String _ability(List<String> parts) {
    // Formats:
    //   ABILITYALL.Feat.VISIBLE.0         → feat name
    //   ABILITYALL.Feat.VISIBLE.0.DESC    → description
    //   ABILITYALL.ANY.0.ASPECT=x.ASPECT.x
    if (parts.length < 3) return '';
    final cat = parts[1]; // FEAT, Feat, Special Ability, ANY, etc.

    // parts[2] may be 'VISIBLE' filter keyword or an index
    int sub = 2;
    if (parts[sub].toUpperCase() == 'VISIBLE') sub++;
    if (sub >= parts.length) return '';

    final idx = int.tryParse(parts[sub]);
    if (idx == null) return '';
    sub++;

    final catKey = (cat == 'ANY') ? null : cat;
    final abilities = _abilitiesForCat(catKey);
    if (idx >= abilities.length) return '';
    final ab = abilities[idx];

    if (sub >= parts.length) return _displayName(ab);
    final field = parts[sub];
    sub++;

    if (field.startsWith('ASPECT=')) {
      final aspectKey = field.substring(7);
      if (sub < parts.length && parts[sub].toUpperCase() == 'ASPECT') {
        // ASPECT=X.ASPECT.Y — return aspect Y's value from this ability object
        final returnAspect = sub + 1 < parts.length ? parts[sub + 1] : aspectKey;
        final obj = _findAbilityInDataset(ab);
        if (obj != null) return _getAspectValue(obj, returnAspect);
        return '';
      }
      // ASPECT=X as filter — return the aspect X value
      final obj = _findAbilityInDataset(ab);
      if (obj != null) return _getAspectValue(obj, aspectKey);
      return _displayName(ab);
    }

    if (field.startsWith('TYPE=')) {
      if (sub < parts.length && parts[sub].toUpperCase() == 'HASASPECT') {
        // TYPE=X.HASASPECT.Y — return 'Y' if ability has aspect Y
        final aspectName = sub + 1 < parts.length ? parts[sub + 1] : '';
        final obj = _findAbilityInDataset(ab);
        if (obj != null && _getAspectValue(obj, aspectName).isNotEmpty) return 'Y';
        return '';
      }
      return _displayName(ab);
    }

    switch (field) {
      case 'NAME':    return _displayName(ab);
      case 'SOURCE':  return '';
      case 'TYPE':    return cat;
      case 'DESC': {
        final obj = _findAbilityInDataset(ab);
        if (obj != null) {
          try {
            final d = (obj as dynamic).getString(StringKey.description) as String?;
            if (d != null && d.isNotEmpty) return d;
          } catch (_) {}
        }
        // Fall back to DESC stored directly in the PCG ABILITY: line.
        return (_data('abilityDescs') as Map?)?[_displayName(ab)] as String? ?? '';
      }
      case 'BENEFIT': {
        final obj = _findAbilityInDataset(ab);
        if (obj != null) {
          try {
            final b = (obj as dynamic).getString(StringKey.benefit) as String?;
            if (b != null && b.isNotEmpty) return b;
          } catch (_) {}
        }
        return '';
      }
      default: return _displayName(ab);
    }
  }

  String _languages() {
    final langs = _data('languageKeys');
    if (langs is List) return langs.cast<String>().join(', ');
    return '';
  }

  List<String> _abilitiesForCat(String? cat) {
    final selected = _data('selectedAbilities') as Map? ?? {};
    if (cat == null) {
      return selected.values
          .expand((v) => (v as List?)?.cast<String>() ?? <String>[])
          .toList();
    }
    // Case-insensitive key search — PCG files may use 'Feat', 'FEAT', etc.
    final catUpper = cat.toUpperCase();
    for (final key in selected.keys) {
      if ((key as String).toUpperCase() == catUpper) {
        return (selected[key] as List?)?.cast<String>() ?? [];
      }
    }
    return [];
  }

  /// Find the dataset ability/feat object matching [nameKey] (display name or key).
  dynamic _findAbilityInDataset(String nameKey) {
    final displayName = _displayName(nameKey);
    try {
      final dataset = _dataset;
      if (dataset == null) return null;
      final allAbilities = (dataset as dynamic).getAllAbilities() as List? ?? [];
      for (final ab in allAbilities) {
        final k = (ab as dynamic).getKeyName() as String? ?? '';
        final d = (ab as dynamic).getDisplayName() as String? ?? '';
        if (k == nameKey || k == displayName || d == displayName || d == nameKey) {
          return ab;
        }
      }
    } catch (_) {}
    return null;
  }

  /// Return the value of the named ASPECT stored on [obj] ('ASPECT:Key|Value').
  String _getAspectValue(dynamic obj, String aspectName) {
    try {
      final aspects = (obj as dynamic)
          .getSafeListFor(ListKey.getConstant<String>('ASPECT_LIST')) as List?;
      if (aspects == null) return '';
      final upper = aspectName.toUpperCase();
      for (final a in aspects) {
        if (a is String) {
          final idx = a.indexOf('|');
          if (idx > 0 && a.substring(0, idx).toUpperCase() == upper) {
            return a.substring(idx + 1);
          }
        }
      }
    } catch (_) {}
    return '';
  }

  String _feat(List<String> parts) {
    if (parts.length < 3) return '';
    final idx = int.tryParse(parts[1]);
    if (idx == null) return '';
    final feats = _abilitiesForCat('FEAT');
    if (idx >= feats.length) return '';
    final ab = feats[idx];
    switch (parts[2]) {
      case 'NAME': return _displayName(ab);
      case 'DESC': {
        final obj = _findAbilityInDataset(ab);
        if (obj != null) {
          try {
            final d = (obj as dynamic).getString(StringKey.description) as String?;
            if (d != null && d.isNotEmpty) return d;
          } catch (_) {}
        }
        return (_data('abilityDescs') as Map?)?[_displayName(ab)] as String? ?? '';
      }
      case 'BENEFIT': {
        final obj = _findAbilityInDataset(ab);
        if (obj != null) {
          try {
            final b = (obj as dynamic).getString(StringKey.benefit) as String?;
            if (b != null && b.isNotEmpty) return b;
          } catch (_) {}
        }
        return '';
      }
    }
    return _displayName(ab);
  }

  // ─── Domain / template tokens ──────────────────────────────────────────────

  String _domain(List<String> parts) {
    final domains = _pc.getSelectedDomainKeys();
    if (parts.length < 3) return domains.join(', ');
    final idx = int.tryParse(parts[1]);
    if (idx == null || idx >= domains.length) return '';
    return domains[idx];
  }

  String _template(List<String> parts) {
    final tmpl = _pc.getAppliedTemplateKeys();
    if (parts.length < 2) return tmpl.join(', ');
    final idx = int.tryParse(parts[1]);
    if (idx == null || idx >= tmpl.length) return '';
    return tmpl[idx];
  }

  // ─── Spell system ─────────────────────────────────────────────────────────

  // Cached list of casting classes with their progression data.
  List<_SpellCls>? _spellClsCache;

  List<_SpellCls> _spellClasses() {
    if (_spellClsCache != null) return _spellClsCache!;
    final result = <_SpellCls>[];
    try {
      final dataset = _dataset;
      if (dataset == null) return _spellClsCache = result;
      final classLevels = _data('classLevels') as List? ?? [];
      final counts = <String, int>{};
      final order  = <String>[];
      for (final l in classLevels) {
        if (l is Map) {
          final k = l['classKey'] as String? ?? '';
          if (!order.contains(k)) order.add(k);
          counts[k] = (counts[k] ?? 0) + 1;
        }
      }
      final classes = (dataset as dynamic).classes as List? ?? [];
      for (final key in order) {
        for (final cls in classes) {
          if ((cls as dynamic).getKeyName() != key) continue;
          final hasSpells = (cls as dynamic).hasSpells as bool? ?? false;
          if (!hasSpells) break;
          // Effective caster level = class's own levels + prestige-class CL grants.
          // getCasterLevel() only returns prestige bonuses; add class's own count.
          final ownLevel = counts[key] ?? 0;
          final effLevel = ownLevel + _pc.getCasterLevel(key);
          if (effLevel <= 0) break;
          final stat = (cls as dynamic).getSpellStat() as String? ?? 'INT';
          final type = (cls as dynamic).getSpellType() as String? ?? '';
          // Memorizes if the MEMORIZE_SPELLS CDOMObjectKey is set to true, OR
          // if no KNOWN: rows are defined (prepared casters don't have known lists).
          bool memorizes = false;
          try {
            final mem = (cls as dynamic).getSafeObject(
                _cdkMemorize ??= _getCDKMemorize()) as bool?;
            memorizes = mem ?? true; // default true (prepared) if unspecified
          } catch (_) { memorizes = true; }
          result.add(_SpellCls(key, cls, effLevel, stat, type, memorizes));
          break;
        }
      }
    } catch (_) {}
    return _spellClsCache = result;
  }

  // Lazily cached CDOMObjectKey for MEMORIZE_SPELLS to avoid repeated lookups.
  dynamic _cdkMemorize;
  static dynamic _getCDKMemorize() {
    try {
      // Use the existing CDOMObjectKey.getConstant infrastructure
      return null; // will use try/catch path in each call
    } catch (_) { return null; }
  }

  /// Bonus spell slots at [spellLevel] for a caster stat modifier [statMod].
  /// In 3.5e: if statMod >= spellLevel, you get +1 slot at that spell level.
  int _bonusSpells(int statMod, int spellLevel) {
    if (spellLevel == 0 || statMod < spellLevel) return 0;
    // One bonus slot per spell level up to statMod (capped at level 9).
    return 1;
  }

  String _spellClass(List<String> parts) {
    final clses = _spellClasses();
    // SPELLLISTCLASS.N where N = classIdx within the character's class list.
    // The template iterates all classes; return '' for non-casters.
    if (parts.length < 2) return clses.firstOrNull?.key ?? '';
    final idx = int.tryParse(parts[1]);
    if (idx == null) return '';
    // Map class list index to spell class — skip non-casting classes.
    // The index here is the global class index, not the spell-class index.
    final classLevels = _data('classLevels') as List? ?? [];
    final order = <String>[];
    for (final l in classLevels) {
      if (l is Map) {
        final k = l['classKey'] as String? ?? '';
        if (!order.contains(k)) order.add(k);
      }
    }
    if (idx >= order.length) return '';
    final key = order[idx];
    // Return the class name only if it is a casting class.
    return clses.any((c) => c.key == key) ? key : '';
  }

  String _spellClassType(List<String> parts) {
    final clses = _spellClasses();
    if (parts.length < 2) return clses.firstOrNull?.spellType ?? '';
    final idx = int.tryParse(parts[1]);
    if (idx == null || idx >= clses.length) return '';
    return clses[idx].spellType;
  }

  // SPELLLISTKNOWN.classIdx.level — spells known at level (spontaneous casters).
  // For prepared casters returns '*' (infinite — they can prepare any known spell).
  String _spellListKnown(List<String> parts) {
    if (parts.length < 3) return '0';
    final idx   = int.tryParse(parts[1]) ?? 0;
    final level = int.tryParse(parts[2]) ?? 0;
    final clses = _spellClasses();
    // parts[1] is a global class index — find the spell class for that position.
    final sc = _spellClsByIdx(idx);
    if (sc == null) return '0';
    if (sc.memorizes) return '∞'; // prepared casters know all spells in their list
    try {
      final known = (sc.cls as dynamic).getKnownSlotsAt(sc.effectiveLevel) as List?;
      if (known != null && level < known.length) return known[level].toString();
    } catch (_) {}
    return '0';
  }

  // SPELLLISTCAST.classIdx.level — spell slots per day.
  String _spellListCast(List<String> parts) {
    if (parts.length < 3) return '0';
    final idx   = int.tryParse(parts[1]) ?? 0;
    final level = int.tryParse(parts[2]) ?? 0;
    final sc = _spellClsByIdx(idx);
    if (sc == null) return '0';
    try {
      final slots = (sc.cls as dynamic).getSpellsPerDayAt(sc.effectiveLevel) as List?;
      if (slots == null || level >= slots.length) return '0';
      int base = (slots[level] as num?)?.toInt() ?? 0;
      if (base < 0) return '0'; // -1 means "no access at this level"
      // Add stat bonus spells (level ≥ 1 only, not cantrips).
      if (level > 0) {
        final statMod = _pc.getStatModByAbb(sc.spellStat);
        base += _bonusSpells(statMod, level);
      }
      return base.toString();
    } catch (_) { return '0'; }
  }

  // SPELLLISTMEMORIZE.classIdx — 1 if class prepares spells, 0 if spontaneous.
  String _spellListMemorize(List<String> parts) {
    if (parts.length < 2) return '0';
    final idx = int.tryParse(parts[1]) ?? 0;
    final sc = _spellClsByIdx(idx);
    return (sc?.memorizes ?? false) ? '1' : '0';
  }

  /// Maps a global class index to a _SpellCls, or null if that class doesn't cast.
  _SpellCls? _spellClsByIdx(int globalIdx) {
    final classLevels = _data('classLevels') as List? ?? [];
    final order = <String>[];
    for (final l in classLevels) {
      if (l is Map) {
        final k = l['classKey'] as String? ?? '';
        if (!order.contains(k)) order.add(k);
      }
    }
    if (globalIdx >= order.length) return null;
    final key = order[globalIdx];
    final clses = _spellClasses();
    for (final sc in clses) { if (sc.key == key) return sc; }
    return null;
  }

  // MAXSPELLLEVEL.classIdx — highest spell level available at current level.
  String _maxSpellLevel(List<String> parts) {
    if (parts.length < 2) return '0';
    final idx = int.tryParse(parts[1]) ?? 0;
    final sc = _spellClsByIdx(idx);
    if (sc == null) return '0';
    try {
      final slots = (sc.cls as dynamic).getSpellsPerDayAt(sc.effectiveLevel) as List?;
      if (slots == null || slots.isEmpty) return '0';
      // Max level is the highest index with a non-negative entry.
      for (int i = slots.length - 1; i >= 0; i--) {
        if (((slots[i] as num?)?.toInt() ?? -1) >= 0) return i.toString();
      }
    } catch (_) {}
    return '0';
  }

  // ─── Spellbook / prepared spell data ──────────────────────────────────────

  /// Returns 0 (innate/racial) + number of casting classes as spellbooks.
  /// Template convention: books 2..COUNT[SPELLBOOKS]-1 are actual spellbooks.
  int _countSpellbooks() {
    final clses = _spellClasses();
    if (clses.isEmpty) return 1; // base only — no spell section rendered
    return 2 + clses.length; // book 0=known, 1=unused, 2+N=class spellbooks
  }

  /// Spellbook name for book index N.
  String _spellBookName(List<String> parts) {
    if (parts.length < 2) return 'Spellbook';
    final idx = int.tryParse(parts[1]) ?? 0;
    if (idx < 2) return 'Known Spells';
    final clses = _spellClasses();
    final clsIdx = idx - 2;
    if (clsIdx >= clses.length) return 'Spellbook';
    return '${clses[clsIdx].key} Spellbook';
  }

  /// Count of spells in spellbook [spellbook] for class [classGlobalIdx] at [level].
  /// Book N-2 belongs to spell-class N-2 (by index in _spellClasses()).
  int _countSpellsInBook(int classGlobalIdx, int spellbook, int level) {
    if (spellbook < 2) return 0; // book 0/1 not used for prepared spells here
    final sc = _spellClsByIdx(classGlobalIdx);
    if (sc == null) return 0;
    // Check that this class owns this spellbook index.
    final clses = _spellClasses();
    final ownIdx = clses.indexOf(sc);
    if (ownIdx < 0 || spellbook != ownIdx + 2) return 0;
    // Domain spells for Cleric-type classes
    final domainAtLevel = _pc.getDomainSpells()
        .where((d) => d['level'] == level).toList();
    if (domainAtLevel.isNotEmpty && sc.spellType.toLowerCase().contains('divine')) {
      return domainAtLevel.length;
    }
    // TODO: return prepared wizard spells from character data when implemented.
    return 0;
  }

  /// Spell at position [spellIdx] in book [spellbook] for class [classGlobalIdx] at [level].
  Map<String, String> _spellMemData(int classGlobalIdx, int spellbook, int level, int spellIdx) {
    final sc = _spellClsByIdx(classGlobalIdx);
    if (sc == null) return const {};
    final clses = _spellClasses();
    final ownIdx = clses.indexOf(sc);
    if (ownIdx < 0 || spellbook != ownIdx + 2) return const {};
    // Domain spells
    final domainAtLevel = _pc.getDomainSpells()
        .where((d) => d['level'] == level).toList();
    if (spellIdx < domainAtLevel.length && sc.spellType.toLowerCase().contains('divine')) {
      final d = domainAtLevel[spellIdx];
      final spellName = d['spell'] as String? ?? '';
      final dc = _pc.getSpellSaveDC(level, sc.key);
      return {
        'NAME':        spellName,
        'DC':          dc.toString(),
        'TIMES':       '1',
        'TIMEUNIT':    'Day',
        'SAVEINFO':    'None',
        'RANGE':       'Varies',
        'CASTINGTIME': '1 Standard Action',
        'DURATION':    'Varies',
        'COMPONENTS':  'V, S',
        'SR':          'Yes',
        'SCHOOL':      '',
        'EFFECT':      '',
        'SOURCESHORT': '',
        'SOURCEPAGE':  '',
        'TARGET':      '',
        'CASTERLEVEL': '${sc.effectiveLevel}',
        'BONUSSPELL':  '*',  // domain/specialty spell marker
      };
    }
    return const {};
  }

  // ─── SPELL token dispatcher ────────────────────────────────────────────────

  String _spell(List<String> parts) {
    // SPELLMEM.class.spellbook.level.spell.FIELD
    if (parts.length < 6) return '';
    final classIdx   = int.tryParse(parts[1]) ?? 0;
    final spellbook  = int.tryParse(parts[2]) ?? 0;
    final level      = int.tryParse(parts[3]) ?? 0;
    final spellIdx   = int.tryParse(parts[4]) ?? 0;
    final field      = parts[5].toUpperCase();
    final data = _spellMemData(classIdx, spellbook, level, spellIdx);
    return data[field] ?? '';
  }

  // Extend COUNT[...] to handle spell book counts.
  int _countSpellsinBook(String inner) {
    // COUNT[SPELLSINBOOK.class.spellbook.level]
    // or COUNT[SPELLSINBOOK0.spellbook.level] (legacy form with class=0 embedded)
    final s = inner.substring(12); // after 'SPELLSINBOOK'
    final parts = s.split('.');
    if (parts.length < 3) return 0;
    int? classIdx;
    int? spellbook;
    int? level;
    // Handle both SPELLSINBOOK.c.b.l and SPELLSINBOOK0.b.l
    if (parts[0].isEmpty) {
      // SPELLSINBOOK.c.b.l
      classIdx  = int.tryParse(parts[1]);
      spellbook = int.tryParse(parts[2]);
      level     = parts.length > 3 ? int.tryParse(parts[3]) : 0;
    } else {
      // SPELLSINBOOK0.b.l — class baked into name
      classIdx  = int.tryParse(parts[0]) ?? 0;
      spellbook = int.tryParse(parts[1]);
      level     = int.tryParse(parts[2]);
    }
    if (classIdx == null || spellbook == null || level == null) return 0;
    return _countSpellsInBook(classIdx, spellbook, level ?? 0);
  }

  // ─── Equipment tokens ─────────────────────────────────────────────────────

  // ─── Equipment / armor / EQ tokens ───────────────────────────────────────

  // EQ.Not.Coin.NOT.Gem.N.* — all non-coin non-gem gear
  String _equipItem(List<String> parts) {
    // Detect format: EQUIP.N.FIELD  or  EQ.Not.Coin.NOT.Gem.N.FIELD
    // We normalise both to gear[idx].field
    final gear = (_data('gear') as List? ?? []).whereType<Map>().toList();
    int? idx;
    String field = '';
    if (parts.length >= 3 && int.tryParse(parts[1]) != null) {
      idx   = int.tryParse(parts[1]);
      field = parts.length > 2 ? parts[2] : 'NAME';
    } else {
      // EQ.Not.Coin.NOT.Gem.N.FIELD — find the numeric part
      for (int i = 1; i < parts.length; i++) {
        final n = int.tryParse(parts[i]);
        if (n != null) {
          idx   = n;
          field = parts.length > i + 1 ? parts[i + 1] : 'NAME';
          break;
        }
      }
    }
    if (idx == null || idx >= gear.length) return '';
    final item = gear[idx];
    return _gearField(item, field);
  }

  // ARMOR.N.* and ARMOR.EQUIPPED.N.* both use the equipped armor list.
  // The template checks ARMOR.N.NAME to see if slot N is filled, then
  // reads ARMOR.EQUIPPED.N.* for the actual values — both must use the
  // same list or empty slots appear incorrectly as filled.
  String _armorEquipped(List<String> parts) {
    if (parts.length < 2) return '';
    final equipped = _equippedArmor();
    int? idx;
    String field = 'NAME';
    if (parts[1].toUpperCase() == 'EQUIPPED') {
      idx   = parts.length > 2 ? int.tryParse(parts[2]) : null;
      field = parts.length > 3 ? parts[3] : 'NAME';
    } else {
      idx   = int.tryParse(parts[1]);
      field = parts.length > 2 ? parts[2] : 'NAME';
    }
    if (idx == null || idx >= equipped.length) return '';
    return _gearField(equipped[idx], field);
  }

  List<Map> _equippedArmor() {
    final equippedSlots = _data('equippedSlots') as Map? ?? {};
    final armorSlot = equippedSlots['Armor'] as String?;
    final shieldSlot = equippedSlots['Off Hand'] as String?;
    final gear = (_data('gear') as List? ?? []).whereType<Map>().toList();
    final result = <Map>[];
    for (final item in gear) {
      final key = item['key'] as String? ?? item['name'] as String? ?? '';
      if (key == armorSlot || key == shieldSlot) result.add(item);
    }
    return result;
  }

  String _gearField(Map item, String field) {
    switch (field.toUpperCase()) {
      case 'NAME':      return item['name'] as String? ?? '';
      case 'WT':
      case 'WEIGHT':    return (item['weight'] as num?)?.toString() ?? '0';
      case 'QTY':       return (item['qty'] as num?)?.toString() ?? '1';
      case 'COST':      return (item['cost'] as num?)?.toString() ?? '0';
      case 'CARRIED':   return '1';
      case 'LOCATION': {
        final key = item['key'] as String? ?? '';
        if (key.isNotEmpty) {
          final slots = _data('equippedSlots') as Map? ?? {};
          for (final entry in slots.entries) {
            if (entry.value == key) return entry.key as String? ?? 'Equipped';
          }
        }
        return 'Carried';
      }
      case 'CHARGES':    return (item['charges'] as num?)?.toString() ?? '0';
      case 'CHECKBOXES': return '0';
      case 'NOTE':      return item['note'] as String? ?? '';
      case 'QUALITY':   return item['quality'] as String? ?? '';
      case 'SPROP':     return item['sprop'] as String? ?? '';
      // Armor-specific fields — look up Equipment domain object for accurate values
      case 'TOTALAC': {
        final eq = _findEquipmentObj(item);
        if (eq != null) {
          try {
            final stored = item['acBonus'] as num?;
            if (stored != null) return stored.toString();
          } catch (_) {}
        }
        return _pc.getArmorBonus().toString();
      }
      case 'MAXDEX': {
        final eq = _findEquipmentObj(item);
        if (eq != null) {
          try {
            final md = (eq as dynamic).getMaxDex() as int?;
            if (md != null) return '+$md';
          } catch (_) {}
        }
        return '';
      }
      case 'ACCHECK': {
        final eq = _findEquipmentObj(item);
        if (eq != null) {
          try { return ((eq as dynamic).getAcCheck() as int? ?? 0).toString(); } catch (_) {}
        }
        return '0';
      }
      case 'SPELLFAIL':
      case 'SPELLFAILURE':
      case 'ARCANE': {
        final eq = _findEquipmentObj(item);
        if (eq != null) {
          try { return ((eq as dynamic).getSpellFailure() as int? ?? 0).toString(); } catch (_) {}
        }
        return '0';
      }
      case 'TYPE': {
        final eq = _findEquipmentObj(item);
        if (eq != null) {
          try { return (eq as dynamic).getArmorType() as String? ?? ''; } catch (_) {}
        }
        return item['type'] as String? ?? '';
      }
      case 'PLUS':
      case 'ENHANCEMENT': return (item['plus'] as num?)?.toString() ?? '0';
      case 'MAGIC':       return ((item['plus'] as num?)?.toInt() ?? 0) > 0 ? '1' : '0';
      case 'CONTENTS':    return '0'; // no container contents tracking yet
      case 'CANEQUIP':    return '1';
      case 'EQMOD':       return item['eqmod'] as String? ?? '';
      case 'REACH':       return '5';
      case 'RANGE':       return item['range'] as String? ?? '0';
      case 'SIZE':        return item['size'] as String? ?? 'M';
      case 'LONGNAME':    return item['name'] as String? ?? '';
    }
    return _stub('GEAR field: $field');
  }

  // ─── Primary-hand weapon (WEAPONH) ───────────────────────────────────────

  String _weaponH(List<String> parts) {
    final field = parts.length > 1 ? parts[1].toUpperCase() : 'NAME';
    final weapons = _equippedWeapons();
    if (weapons.isEmpty) return '';
    final w = weapons.first;
    switch (field) {
      case 'NAME':      return w['name'] as String? ?? '';
      case 'TOTALHIT':
      case 'BASEHIT':   return w['tohit'] as String? ?? '';
      case 'BASICDAMAGE':
      case 'DAMAGE':    return w['damage'] as String? ?? '';
      case 'CRIT':      return w['crit'] as String? ?? '';
      case 'MULT': {
        // Extract from crit string e.g. '20/×2'
        final crit = w['crit'] as String? ?? '20/×2';
        final slash = crit.lastIndexOf('/');
        return slash >= 0 ? crit.substring(slash + 1) : '×2';
      }
      case 'TYPE':      return w['type'] as String? ?? '';
      case 'HAND':      return 'Primary';
      case 'REACH': {
        final types = (w['typeList'] as List?)?.cast<String>() ?? [];
        return types.any((t) => t.toLowerCase() == 'reach') ? '10' : '5';
      }
      case 'SPROP':     return w['sprop'] as String? ?? '';
      case 'ISRANGED':  return (w['isRanged'] as bool? ?? false) ? '1' : '0';
      case 'CATEGORY':  return (w['isRanged'] as bool? ?? false) ? 'Ranged' : 'Melee';
    }
    return _stub('WEAPONH field: ${parts.join(".")}');
  }

  // ─── Color / length / move / pool tokens ─────────────────────────────────

  String _color(List<String> parts) {
    if (parts.length < 2) return '';
    switch (parts[1]) {
      case 'EYE':  return _pc.getEyeColor();
      case 'HAIR': return _pc.getHairColor();
      case 'SKIN': return _pc.getSkinColor();
    }
    return '';
  }

  String _length(List<String> parts) {
    if (parts.length < 2) return '';
    switch (parts[1]) {
      case 'HAIR': return _data('hairStyle') as String? ?? '';
    }
    return _stub('LENGTH field: ${parts.join(".")}');
  }

  String _move(List<String> parts) {
    // MOVE.N.NAME / MOVE.N.RATE
    if (parts.length < 3) return '';
    final idx = int.tryParse(parts[1]) ?? 0;
    final speeds = (_data('moveSpeeds') as Map? ?? {});
    final keys = speeds.keys.toList();
    if (idx >= keys.length) return '';
    final key = keys[idx];
    switch (parts[2]) {
      case 'NAME': return key.toString();
      case 'RATE': return speeds[key].toString();
    }
    return _stub('MOVE field: ${parts.join(".")}');
  }

  /// MOVEMENT — full movement summary string e.g. "Walk 30 ft., Fly 60 ft."
  String _movementSummary() {
    final speeds = _data('moveSpeeds') as Map? ?? {};
    if (speeds.isEmpty) return '30 ft.';
    return speeds.entries
        .map((e) => speeds.length == 1 ? '${e.value} ft.' : '${e.key} ${e.value} ft.')
        .join(', ');
  }

  /// FAVOREDLIST — comma-separated list of favored classes.
  /// In 3.5e this is the highest-level class; in PF it can be multiple.
  String _favoredClassList() {
    // Check character data first (stored from PCG FAVOREDCLASS: tag)
    final stored = _data('favoredClass') as String? ?? '';
    if (stored.isNotEmpty) return stored;
    // Fallback: derive from class levels — highest-level class is favored
    final classLevels = _data('classLevels') as List? ?? [];
    final counts = <String, int>{};
    for (final l in classLevels) {
      if (l is Map) {
        final k = l['classKey'] as String? ?? '';
        if (k.isNotEmpty) counts[k] = (counts[k] ?? 0) + 1;
      }
    }
    if (counts.isEmpty) return '';
    // Return the class with the most levels (or first if tied)
    final top = counts.entries.reduce((a, b) => a.value >= b.value ? a : b);
    return top.key;
  }

  String _pool(List<String> parts) {
    if (parts.length < 2) return '';
    switch (parts[1]) {
      case 'COST': return _pc.getStatBuyCost().toString();
    }
    return _stub('POOL field: ${parts.join(".")}');
  }

  String _sizeToLong(String abbr) {
    const map = {
      'F': 'Fine', 'D': 'Diminutive', 'T': 'Tiny', 'S': 'Small',
      'M': 'Medium', 'L': 'Large', 'H': 'Huge', 'G': 'Gargantuan', 'C': 'Colossal',
    };
    return map[abbr.toUpperCase()] ?? abbr;
  }

  // ─── COUNT[...] ────────────────────────────────────────────────────────────

  int _count(String what) {
    final w = what.toUpperCase().trim();
    if (w == 'CLASSES' || w == 'CLASS') {
      final classLevels = _data('classLevels') as List? ?? [];
      final seen = <String>{};
      for (final l in classLevels) {
        if (l is Map) seen.add(l['classKey'] as String? ?? '');
      }
      return seen.length;
    }
    if (w == 'STATS') {
      try { return (_dataset?.stats as List?)?.length ?? _statOrder.length; }
      catch (_) { return _statOrder.length; }
    }
    if (w == 'SKILLS') {
      try { return (_dataset?.skills as List?)?.length ?? 0; } catch(_) { return 0; }
    }
    if (w == 'VISION') {
      return (_data('vision') as String? ?? '').isNotEmpty ? 1 : 0;
    }
    if (w == 'MOVE') {
      return (_data('moveSpeeds') as Map? ?? {}).length;
    }
    if (w.startsWith('ABILITY.FEAT') || w == 'FEATS') {
      return _abilitiesForCat('FEAT').length;
    }
    if (w.startsWith('ABILITY.')) {
      final cat = what.split('.').skip(1).first;
      return _abilitiesForCat(cat).length;
    }
    if (w.startsWith('ABILITIES.')) {
      final cat = what.split('.').skip(1).first;
      return _abilitiesForCat(cat).length;
    }
    if (w == 'CHECKS' || w == 'SAVES') return _saveNames.length;
    if (w == 'SA') return _abilitiesForCat('Special Ability').length;
    if (w == 'TEMPBONUSNAMES' || w == 'TEMPBONUS') {
      return (_data('tempBonuses') as List? ?? []).length;
    }
    if (w == 'NOTES') return (_pc.getNotes().isNotEmpty) ? 1 : 0;
    if (w == 'FOLLOWERS' || w.startsWith('FOLLOWERTYPE.')) return 0;
    if (w == 'WEAPONS') return _equippedWeapons().length;
    if (w.startsWith('EQTYPE.')) {
      final type = what.substring(7).toLowerCase();
      if (type == 'weapon') return _equippedWeapons().length;
      // For other types: count gear matching the type
      final gear = (_data('gear') as List? ?? []).whereType<Map>();
      return gear.where((g) =>
          (g['type'] as String? ?? '').toLowerCase().contains(type)).length;
    }
    if (w == 'DOMAINS') return _pc.getSelectedDomainKeys().length;
    if (w == 'TEMPLATES') return _pc.getAppliedTemplateKeys().length;
    if (w == 'GEAR' || w == 'EQUIP') {
      return (_data('gear') as List? ?? []).length;
    }
    if (w.startsWith('EQUIPMENT.')) return (_data('gear') as List? ?? []).length;
    if (w == 'WEAPONPROFS') return _pc.getWeaponProficiencies().length;
    if (w == 'SAVES') return _saveNames.length;
    if (w == 'SPELLBOOKS') return _countSpellbooks();
    if (w == 'SPELLRACE')  return 0;
    if (w.startsWith('SPELLSINBOOK')) return _countSpellsinBook(what);
    if (w.startsWith('SPELLLISTCAST.')) {
      // COUNT[SPELLLISTCAST.class.level] — used for rendering spell slot boxes (☐)
      final parts = what.split('.');
      if (parts.length >= 3) {
        final slots = int.tryParse(_spellListCast(parts)) ?? 0;
        return slots;
      }
      return 0;
    }
    // COUNT[A]+COUNT[B] compound expressions
    final plusIdx = what.indexOf('+');
    if (plusIdx > 0) {
      return _count(what.substring(0, plusIdx).trim()) +
             _count(what.substring(plusIdx + 1).trim());
    }
    // COUNT[expr]-N arithmetic — e.g. COUNT[STATS]-1
    final dashIdx = what.indexOf('-');
    if (dashIdx > 0) {
      final base = _count(what.substring(0, dashIdx));
      final sub  = int.tryParse(what.substring(dashIdx + 1).trim()) ?? 0;
      return base - sub;
    }
    return 0;
  }

  // ─── Export / meta tokens ──────────────────────────────────────────────────

  String _export(List<String> parts) {
    if (parts.length < 2) return '';
    final now = DateTime.now();
    switch (parts[1]) {
      case 'DATE':    return '${now.year}-${_pad(now.month)}-${_pad(now.day)}';
      case 'TIME':    return '${_pad(now.hour)}:${_pad(now.minute)}';
      case 'VERSION': return '7.0.0-alpha';
    }
    return '';
  }

  String _paperinfo(List<String> parts) {
    if (parts.length < 2) return '';
    switch (parts[1]) {
      case 'NAME':         return 'Letter';
      case 'HEIGHT':       return '11in';
      case 'WIDTH':        return '8.5in';
      case 'MARGINTOP':    return '0.5in';
      case 'MARGINBOTTOM': return '0.5in';
      case 'MARGINLEFT':   return '0.5in';
      case 'MARGINRIGHT':  return '0.5in';
    }
    return '';
  }

  String _unitset(List<String> parts) {
    if (parts.length < 2) return 'Imperial';
    switch (parts[1]) {
      case 'HEIGHTUNIT':   return 'in';
      case 'DISTANCEUNIT': return 'ft';
      case 'WEIGHTUNIT':   return 'lbs';
    }
    return '';
  }

  // ─── Biographical / misc tokens ───────────────────────────────────────────

  String _weightToken(List<String> parts) {
    final sub = parts.length > 1 ? parts[1].toUpperCase() : '';
    // Encumbrance limits: approximate from STR score (d20 table: STR×3.33/6.67/10 lbs)
    final strScore = _pc.getStatModByAbb('STR') * 2 + 10;
    if (sub == 'LIGHT')  return (strScore * 3.33).floor().toString();
    if (sub == 'MEDIUM') return (strScore * 6.67).floor().toString();
    if (sub == 'HEAVY')  return (strScore * 10).toString();
    return _pc.getWeight().toString();
  }

  String _goldToken(List<String> parts) {
    final sub = parts.length > 1 ? parts[1].toUpperCase() : '';
    if (sub == 'TRUNC') return _pc.getFunds().floor().toString();
    return _pc.getFunds().toStringAsFixed(2);
  }

  String _note(List<String> parts) {
    // NOTE.N.NAME or NOTE.N.VALUE — character notes stored in _data['notes']
    // We store one blob of notes text; expose it as a single entry.
    if (parts.length < 3) return '';
    final idx = int.tryParse(parts[1]) ?? 0;
    if (idx != 0) return '';
    switch (parts[2].toUpperCase()) {
      case 'NAME':  return 'Notes';
      case 'VALUE': return _pc.getNotes();
    }
    return '';
  }

  String _tempBonus(List<String> parts) {
    // TEMPBONUS.N — name of the Nth active temp bonus
    if (parts.length < 2) return '';
    final idx = int.tryParse(parts[1]) ?? -1;
    final bonuses = _data('tempBonuses') as List? ?? [];
    if (idx < 0 || idx >= bonuses.length) return '';
    final b = bonuses[idx];
    if (b is Map) return b['source'] as String? ?? '';
    return '';
  }

  String _specialAbility(List<String> parts) {
    // SPECIALABILITY.N — Nth special ability name from selectedAbilities['Special Ability']
    if (parts.length < 2) return '';
    final idx = int.tryParse(parts[1]) ?? -1;
    final sas = _abilitiesForCat('Special Ability');
    if (idx < 0 || idx >= sas.length) return '';
    return _displayName(sas[idx]);
  }

  String _specialList() {
    // SPECIALLIST — comma-separated list of all special abilities
    final sas = _abilitiesForCat('Special Ability');
    return sas.map(_displayName).join(', ');
  }

  String _prohibitedList() {
    // PROHIBITEDLIST — comma-separated list of prohibited spell schools from classes
    final classLevels = _data('classLevels') as List? ?? [];
    final prohibited = <String>{};
    final dataset = _dataset;
    if (dataset != null) {
      try {
        final counts = <String>{};
        for (final l in classLevels) {
          if (l is Map) {
            final k = l['classKey'] as String? ?? '';
            if (k.isNotEmpty) counts.add(k);
          }
        }
        for (final cls in (dataset as dynamic).classes as List) {
          final key = (cls as dynamic).getKeyName() as String? ?? '';
          if (!counts.contains(key)) continue;
          final proList = (cls as dynamic).getSafeListFor(
              ListKey.getConstant<String>('PROHIBITED_SPELLS')) as List?;
          if (proList != null) {
            for (final p in proList) { if (p is String) prohibited.add(p); }
          }
        }
      } catch (_) {}
    }
    return prohibited.join(', ');
  }

  String _abilityList(List<String> parts) {
    // ABILITYLIST.CategoryName — comma-separated list of abilities in that category
    if (parts.length < 2) return '';
    final cat = parts.sublist(1).join('.');
    final abilities = _abilitiesForCat(cat);
    return abilities.map(_displayName).join(', ');
  }

  String _followerType(List<String> parts) {
    // FOLLOWERTYPE.TYPE.N.FIELD — stats for companion of TYPE at index N
    // e.g. FOLLOWERTYPE.ANIMAL COMPANION.0.NAME
    // We serve from _data('companions') list filtered by type.
    if (parts.length < 4) return '';
    // parts[1..N-2] are the type words, then idx, then field
    // Find the numeric index
    int? idx;
    int fieldStart = parts.length - 1;
    for (int i = 2; i < parts.length; i++) {
      if (int.tryParse(parts[i]) != null) {
        idx = int.tryParse(parts[i]);
        fieldStart = i + 1;
        break;
      }
    }
    if (idx == null) return '';
    final typeName = parts.sublist(1, fieldStart - 1).join(' ').toUpperCase();
    final field = parts.sublist(fieldStart).join('.').toUpperCase();
    final companions = (_data('companions') as List? ?? [])
        .whereType<Map>()
        .where((c) => (c['type'] as String? ?? '').toUpperCase() == typeName)
        .toList();
    if (idx >= companions.length) return '';
    final c = companions[idx];
    switch (field) {
      case 'NAME':         return c['name'] as String? ?? '';
      case 'RACE':         return c['race'] as String? ?? '';
      case 'HP':           return (c['hp'] as num?)?.toString() ?? '0';
      case 'INITIATIVEMOD':return (c['initiative'] as num?)?.toString() ?? '+0';
      case 'SPECIALLIST':  return c['specialList'] as String? ?? '';
      case 'CHECK.2.TOTAL':
      case 'CHECK.FORTITUDE.TOTAL': return (c['fortSave'] as num?)?.toString() ?? '+0';
      case 'CHECK.REFLEX.TOTAL':    return (c['refSave'] as num?)?.toString() ?? '+0';
      default: return '';
    }
  }

  String _eqType(List<String> parts) {
    // EQTYPE.TypeName.N.FIELD — gear filtered by type
    // e.g. EQTYPE.LightSource.ADD.Light Source.0.NAME
    //      EQTYPE.Gem.%.QTY
    if (parts.length < 2) return '';
    final typeName = parts[1].toLowerCase();
    final gear = (_data('gear') as List? ?? []).whereType<Map>().toList();
    // Filter gear by type matching
    final filtered = gear.where((g) {
      final t = (g['type'] as String? ?? '').toLowerCase();
      return t.contains(typeName);
    }).toList();
    // Find numeric index
    int? idx;
    int fieldStart = parts.length - 1;
    for (int i = 2; i < parts.length; i++) {
      if (int.tryParse(parts[i]) != null) {
        idx = int.tryParse(parts[i]);
        fieldStart = i + 1;
        break;
      }
    }
    if (idx == null || idx >= filtered.length) return '';
    final item = filtered[idx];
    final field = parts.sublist(fieldStart).join('.').toUpperCase();
    return _gearField(item, field);
  }

  /// Looks up the Equipment domain object for a gear Map entry.
  /// Returns null if the dataset or item can't be found.
  dynamic _findEquipmentObj(Map item) {
    try {
      final dataset = _dataset;
      if (dataset == null) return null;
      final equipment = (dataset as dynamic).equipment as List? ?? [];
      final key = item['key'] as String? ?? item['name'] as String? ?? '';
      for (final eq in equipment) {
        if ((eq as dynamic).getKeyName() == key) return eq;
      }
    } catch (_) {}
    return null;
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  String _raceName() {
    try { return (_pc.getRaceRef().get() as dynamic)?.getDisplayName() as String? ?? _pc.getRaceKey(); }
    catch (_) { return _pc.getRaceKey(); }
  }

  dynamic _data(String key) => (_pc.toJson())[key];

  String _signed(int n) => n >= 0 ? '+$n' : '$n';

  String _pad(int n) => n.toString().padLeft(2, '0');

  String _displayName(String stored) {
    final sep = stored.indexOf('|');
    return sep >= 0 ? stored.substring(0, sep) : stored;
  }

  /// Log a stub call and return ''. Use for tokens that should eventually
  /// produce real output so we can see which ones fire at runtime.
  String _stub(String context) {
    // ignore: avoid_print
    print('PCGen STUB: $context');
    return '';
  }

  /// Apply VAR format suffixes starting at [suffixIdx] in [parts].
  /// Handles: INTVAL (truncate), SIGN (prefix +), NOZERO (hide zero).
  String _applyVarSuffixes(List<String> parts, int suffixIdx, double val) {
    // Collect all suffix words
    final suffixes = parts.length > suffixIdx
        ? parts.sublist(suffixIdx).map((s) => s.toUpperCase()).toSet()
        : const <String>{};
    if (suffixes.contains('NOZERO') && val == 0) return '';
    final intVal = val.toInt();
    final numStr = suffixes.contains('INTVAL') ? '$intVal' : val.toString();
    if (suffixes.contains('SIGN')) {
      final n = suffixes.contains('INTVAL') ? intVal : val.round();
      return n >= 0 ? '+$n' : '$n';
    }
    // Plain INTVAL without SIGN
    if (suffixes.contains('INTVAL')) return '$intVal';
    return numStr;
  }
}

// ─── Spell class descriptor ────────────────────────────────────────────────────

class _SpellCls {
  final String  key;
  final dynamic cls;           // PCClass domain object
  final int     effectiveLevel; // caster level (including prestige bonuses)
  final String  spellStat;     // INT, WIS, CHA
  final String  spellType;     // Arcane, Divine, Psionic
  final bool    memorizes;     // true = prepared, false = spontaneous
  const _SpellCls(this.key, this.cls, this.effectiveLevel,
      this.spellStat, this.spellType, this.memorizes);
}
