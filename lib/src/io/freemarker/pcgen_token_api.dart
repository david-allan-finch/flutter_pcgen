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
    try {
      return _resolve(token.trim());
    } catch (_) {
      return '';
    }
  }

  @override
  double pcvar(String token) {
    try {
      final v = _resolve(token.trim());
      return double.tryParse(v) ?? 0.0;
    } catch (_) {
      return 0.0;
    }
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
    // COUNT[...] tokens
    if (token.startsWith('COUNT[') && token.endsWith(']')) {
      return _count(token.substring(6, token.length - 1)).toString();
    }

    // VAR.name tokens
    if (token.startsWith('VAR.')) {
      final parts = token.split('.');
      final varName = parts[1];
      final fmt = parts.length > 2 ? parts[2] : '';
      final val = _pc.getVariable(varName);
      if (fmt == 'INTVAL') return val.toInt().toString();
      return val.toString();
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
      case 'WEIGHT':      return _pc.getWeight().toString();
      case 'EYES':
      case 'EYE':         return _pc.getEyeColor();
      case 'HAIR':        return _pc.getHairColor();
      case 'SKIN':        return _pc.getSkinColor();
      case 'BIO':
      case 'BIOGRAPHY':   return _pc.getBiography();
      case 'APPEARANCE':  return _pc.getAppearance();
      case 'NOTES':       return _pc.getNotes();
      case 'HP':          return _pc.getHP().toString();
      case 'MAXHP':       return _pc.getMaxHP().toString();
      case 'XP':          return _pc.getXP().toString();
      case 'XPNEXT':      return _pc.getXPForNextLevel().toString();
      case 'TOTALLEVELS': return _pc.getTotalCharacterLevel().toString();
      case 'CR':          return _pc.getTotalCharacterLevel().toString();
      case 'SIZE':        return _pc.getRaceSize();
      case 'GAMEMODE':    return _pc.getGameMode();

      case 'STAT':        return _stat(parts);
      case 'BASESAVE':
      case 'SAVE':        return _save(parts);
      case 'CHECKS':      return _save(parts);

      case 'AC':          return _ac(parts);
      case 'INITIATIVEMOD':
      case 'INITIATIVE':  return _signed(_pc.getInitiative());
      case 'BAB':         return _pc.getBAB();

      case 'CLASS':       return _cls(parts);
      case 'CLASSLIST':   return _pc.getClassLevelSummary();

      case 'SKILL':       return _skill(parts);

      case 'WEAPON':      return _weapon(parts);
      case 'WEAPONPROF':  return _weaponProfs(parts);

      case 'ABILITY':
      case 'ABILITYALL':  return _ability(parts);
      case 'FEAT':        return _feat(parts);

      case 'DOMAIN':      return _domain(parts);
      case 'TEMPLATE':    return _template(parts);

      case 'SPELLLISTCLASS': return _spellClass(parts);
      case 'SPELLLISTCLASSTYPE': return _spellClassType(parts);
      case 'SPELL':       return _spell(parts);

      case 'EQUIP':
      case 'ARMOR':       return _equip(parts);

      case 'FUNDS':
      case 'GOLD':        return _pc.getFunds().toStringAsFixed(2);
      case 'TOTALVALUE':  return _pc.getFunds().toStringAsFixed(2);

      case 'SR':          return _pc.getSR().toString();
      case 'DR':          return _data('dr') ?? '';

      case 'EXPORT':      return _export(parts);
      case 'PAPERINFO':   return _paperinfo(parts);
      case 'UNITSET':     return _unitset(parts);
      case 'INVALIDTEXT': return '';
      case 'DIR':         return '';

      default:            return '';
    }
  }

  // ─── Stat tokens: STAT.N.SCORE / .MOD / .NAME / .BASEMOD / .MISC ──────────

  String _stat(List<String> parts) {
    if (parts.length < 3) return '';
    final idx = int.tryParse(parts[1]);
    if (idx == null || idx >= _statOrder.length) return '';
    final abb = _statOrder[idx];
    final dataset = _dataset;
    switch (parts[2]) {
      case 'NAME':    return abb;
      case 'ABB':     return abb;
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
      case 'BASEMOD':
        if (dataset != null) {
          try {
            final stat = (dataset.stats as List).firstWhere((s) => s.getKeyName() == abb);
            return _signed(_pc.getModTotal(stat));
          } catch (_) {}
        }
        final score = (_data('statScores')?[abb] as num?)?.toInt() ?? 10;
        return _signed(((score - 10) / 2).floor());
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
        return '0'; // misc modifier (not commonly used)
    }
    return '';
  }

  // ─── Save tokens: SAVE.N.TOTAL / .BASE / .STAT ────────────────────────────

  String _save(List<String> parts) {
    if (parts.length < 3) return '';
    final idx = int.tryParse(parts[1]);
    if (idx == null || idx >= _saveNames.length) return '';
    switch (parts[2]) {
      case 'NAME':  return _saveNames[idx];
      case 'TOTAL':
        switch (idx) {
          case 0: return _signed(_pc.getFortSave());
          case 1: return _signed(_pc.getRefSave());
          case 2: return _signed(_pc.getWillSave());
        }
        return '0';
      case 'BASE':  return '0'; // TODO: separate base from stat
      case 'STAT':  return '0';
      case 'MAGIC': return '0';
      case 'MISC':  return '0';
    }
    return '';
  }

  // ─── AC tokens: AC.TOTAL / .FLAT / .TOUCH / .ARMOR / .SHIELD / .DEX ──────

  String _ac(List<String> parts) {
    if (parts.length == 1) return _pc.getAC().toString();
    switch (parts[1]) {
      case 'TOTAL':        return _pc.getAC().toString();
      case 'FLATFOOTED':   return _pc.getFlatFootedAC().toString();
      case 'TOUCH':        return _pc.getTouchAC().toString();
      case 'BASE':         return '10';
      case 'ARMOR':        return '0';
      case 'SHIELD':       return '0';
      case 'DEX':          return _signed(_pc.getStatModByAbb('DEX'));
      case 'DEFLECTION':   return '0';
      case 'DODGE':        return '0';
      case 'NATURAL':      return '0';
      case 'SIZE':         return '0';
      case 'MISC':         return '0';
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

    switch (parts[2]) {
      case 'NAME':  return key;
      case 'ABB':   return key.length > 3 ? key.substring(0, 3) : key;
      case 'LEVEL': return (counts[key] ?? 0).toString();
      case 'TYPE':  return _classType(key);
      case 'BAB':   return _pc.getBABAsInt().toString();
    }
    return '';
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
      case 'EXCLUSIVE':  return '0';
      case 'CLASSSK':    return '0';
    }
    return '';
  }

  List<Map<String, dynamic>> _allSkills() {
    try {
      final dataset = _dataset;
      if (dataset == null) return [];
      return (dataset.skills as List).map<Map<String, dynamic>>((s) => {
        'name': s.getDisplayName() ?? s.getKeyName(),
        'key': s.getKeyName(),
        'stat': s.get(null)?.toString() ?? '',
        'skill': s,
      }).toList();
    } catch (_) { return []; }
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
        // Multiple attacks string e.g. "+12/+7/+2"
        return w['tohit'] as String? ?? '+0';
    }
    return '';
  }

  List<Map<String, dynamic>> _equippedWeapons() {
    // Build weapon list from the sheet data the same way character_sheet_panel does
    final gear = _data('gear') as List? ?? [];
    final equipsets = _data('equipSets') as List? ?? [];
    final result = <Map<String, dynamic>>[];

    // Find active equip set
    Map<String, dynamic>? activeSet;
    for (final es in equipsets) {
      if (es is Map && es['active'] == true) { activeSet = Map.from(es as Map); break; }
    }
    activeSet ??= equipsets.isNotEmpty ? Map.from(equipsets.first as Map) : {};

    final slots = activeSet['slots'] as Map? ?? {};
    final weaponSlotKeys = ['primary', 'secondary', 'both', 'primarydouble',
      'naturalPrimary', 'naturalSecondary', 'Natural-Primary', 'Natural-Secondary'];

    for (final slotKey in slots.keys) {
      final slotLower = slotKey.toString().toLowerCase();
      final isWeaponSlot = weaponSlotKeys.any((k) => k.toLowerCase() == slotLower);
      if (!isWeaponSlot) continue;
      final gearKey = slots[slotKey];
      if (gearKey == null) continue;
      final item = gear.where((g) => g is Map && (g['key'] == gearKey || g['name'] == gearKey)).firstOrNull;
      if (item == null) continue;
      result.add(_weaponStats(item as Map, slotKey.toString()));
    }
    return result;
  }

  Map<String, dynamic> _weaponStats(Map item, String slot) {
    // Simplified — just return what we can
    final name = item['name'] as String? ?? '';
    final isRanged = item['isRanged'] as bool? ?? false;
    final bab = _pc.getBABAsInt();
    final bonus = isRanged ? _pc.getTohitBonusRanged() : _pc.getTohitBonusMelee();
    final tohit = bab + bonus;
    final attacks = <String>[];
    var cur = tohit;
    while (cur > 0 || attacks.isEmpty) { attacks.add(_signed(cur)); cur -= 5; if (cur <= tohit - 20) break; }
    return {
      'name': name,
      'tohit': attacks.join('/'),
      'damage': item['damage'] as String? ?? '1d6',
      'crit': item['crit'] as String? ?? '20/×2',
      'isRanged': isRanged,
      'range': isRanged ? '60 ft.' : 'melee',
      'type': '',
    };
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
    // ABILITY.FEAT.N.NAME or ABILITYALL.ANY.N.ASPECT=x.ASPECT.x
    if (parts.length < 4) return '';
    final cat = parts[1]; // FEAT, TRAIT, etc.
    final idx = int.tryParse(parts[2]);
    if (idx == null) return '';
    final catKey = cat == 'ANY' ? null : cat;
    final abilities = _abilitiesForCat(catKey);
    if (idx >= abilities.length) return '';
    final ab = abilities[idx];
    switch (parts[3]) {
      case 'NAME':        return _displayName(ab);
      case 'DESC':        return '';
      case 'BENEFIT':     return '';
      case 'TYPE':        return cat;
      default:            return _displayName(ab);
    }
  }

  List<String> _abilitiesForCat(String? cat) {
    final selected = _data('selectedAbilities') as Map? ?? {};
    if (cat == null) {
      // All categories
      return selected.values.expand((v) => (v as List?)?.cast<String>() ?? <String>[]).toList();
    }
    final v = selected[cat] ?? selected[cat.toUpperCase()];
    return (v as List?)?.cast<String>() ?? [];
  }

  String _feat(List<String> parts) {
    if (parts.length < 3) return '';
    final idx = int.tryParse(parts[1]);
    if (idx == null) return '';
    final feats = _abilitiesForCat('FEAT');
    if (idx >= feats.length) return '';
    switch (parts[2]) {
      case 'NAME': return _displayName(feats[idx]);
      case 'DESC': return '';
    }
    return _displayName(feats[idx]);
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

  // ─── Spell tokens (simplified) ─────────────────────────────────────────────

  String _spellClass(List<String> parts) {
    // Return class that can cast spells
    final classLevels = _data('classLevels') as List? ?? [];
    final seen = <String>[];
    for (final l in classLevels) {
      if (l is Map) {
        final k = l['classKey'] as String? ?? '';
        if (!seen.contains(k)) seen.add(k);
      }
    }
    if (parts.length < 2) return seen.firstOrNull ?? '';
    final idx = int.tryParse(parts[1]);
    if (idx == null || idx >= seen.length) return '';
    return seen[idx];
  }

  String _spellClassType(List<String> parts) => '';

  String _spell(List<String> parts) {
    // Spell tokens are complex — return empty for now
    return '';
  }

  // ─── Equipment tokens ─────────────────────────────────────────────────────

  String _equip(List<String> parts) {
    if (parts.length < 3) return '';
    final idx = int.tryParse(parts[1]);
    if (idx == null) return '';
    final gear = (_data('gear') as List? ?? []).whereType<Map>().toList();
    if (idx >= gear.length) return '';
    final item = gear[idx];
    switch (parts[2]) {
      case 'NAME':   return item['name'] as String? ?? '';
      case 'WT':
      case 'WEIGHT': return (item['weight'] as num?)?.toString() ?? '0';
      case 'QTY':    return (item['qty'] as num?)?.toString() ?? '1';
      case 'COST':   return (item['cost'] as num?)?.toString() ?? '0';
      case 'QUALITY':return '';
      case 'CARRIED':return '1';
    }
    return '';
  }

  // ─── COUNT[...] ────────────────────────────────────────────────────────────

  int _count(String what) {
    final w = what.toUpperCase();
    if (w == 'CLASSES' || w == 'CLASS') {
      final classLevels = _data('classLevels') as List? ?? [];
      final seen = <String>{};
      for (final l in classLevels) {
        if (l is Map) seen.add(l['classKey'] as String? ?? '');
      }
      return seen.length;
    }
    if (w == 'SKILLS') {
      try { return (_dataset?.skills as List?)?.length ?? 0; } catch(_) { return 0; }
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
    if (w == 'WEAPONS') return _equippedWeapons().length;
    if (w == 'DOMAINS') return _pc.getSelectedDomainKeys().length;
    if (w == 'TEMPLATES') return _pc.getAppliedTemplateKeys().length;
    if (w == 'GEAR' || w == 'EQUIP') {
      return (_data('gear') as List? ?? []).length;
    }
    if (w == 'WEAPONPROFS') return _pc.getWeaponProficiencies().length;
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

  // ─── Helpers ───────────────────────────────────────────────────────────────

  String _raceName() {
    try { return _pc.getRaceRef().get()?.getDisplayName() as String? ?? _pc.getRaceKey(); }
    catch (_) { return _pc.getRaceKey(); }
  }

  dynamic _data(String key) => (_pc.toJson())[key];

  String _signed(int n) => n >= 0 ? '+$n' : '$n';

  String _pad(int n) => n.toString().padLeft(2, '0');

  String _displayName(String stored) {
    final sep = stored.indexOf('|');
    return sep >= 0 ? stored.substring(0, sep) : stored;
  }
}
