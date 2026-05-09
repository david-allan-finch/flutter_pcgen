// Built-in HTML character sheet generator.
// Produces a standalone HTML file styled like the PCGen standard 3.5e sheet.
// Works with CharacterFacadeImpl; no external FTL templates required.

import 'package:flutter_pcgen/src/gui2/facade/character_facade_impl.dart';

class BuiltinSheetGenerator {
  final CharacterFacadeImpl _pc;
  final dynamic _dataset;

  static const _statOrder = ['STR', 'DEX', 'CON', 'INT', 'WIS', 'CHA'];
  static const _saveNames  = ['Fortitude', 'Reflex', 'Will'];

  BuiltinSheetGenerator(this._pc, this._dataset);

  String generate() {
    final buf = StringBuffer();
    buf.write(_head());
    buf.write('<body>\n');
    buf.write('<div class="sheet">\n');
    buf.write(_headerSection());
    buf.write(_statsSection());
    buf.write(_combatSection());
    buf.write(_skillsSection());
    buf.write(_featsSection());
    buf.write(_weaponsSection());
    buf.write(_armorSection());
    buf.write(_gearSection());
    buf.write(_spellsSection());
    buf.write(_bioSection());
    buf.write('</div>\n</body>\n</html>');
    return buf.toString();
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  Map<String, dynamic> get _data => _pc.toJson();

  String _raceName() {
    try { return _pc.getRaceRef().get()?.getDisplayName() as String? ?? _pc.getRaceKey(); }
    catch (_) { return _pc.getRaceKey(); }
  }

  int _score(String abb) {
    if (_dataset != null) {
      try {
        final stat = (_dataset.stats as List).firstWhere((s) => s.getKeyName() == abb);
        return _pc.getEffectiveScore(stat);
      } catch (_) {}
    }
    return (_data['statScores']?[abb] as num?)?.toInt() ?? 10;
  }

  int _mod(String abb) => ((_score(abb) - 10) / 2).floor();

  String _signed(int n) => n >= 0 ? '+$n' : '$n';

  String _h(String text) => '<h3 class="section-head">$text</h3>';

  String _td(String text, {String cls = ''}) {
    final c = cls.isNotEmpty ? ' class="$cls"' : '';
    return '<td$c>$text</td>';
  }

  String _th(String text, {String cls = ''}) {
    final c = cls.isNotEmpty ? ' class="$cls"' : '';
    return '<th$c>$text</th>';
  }

  List<Map<String, dynamic>> _classBreakdown() {
    final classLevels = _data['classLevels'] as List? ?? [];
    final seen = <String>[];
    final counts = <String, int>{};
    for (final l in classLevels) {
      if (l is Map) {
        final k = l['classKey'] as String? ?? '';
        if (!seen.contains(k)) seen.add(k);
        counts[k] = (counts[k] ?? 0) + 1;
      }
    }
    return seen.map((k) => {'name': k, 'level': counts[k] ?? 0}).toList();
  }

  List<Map<String, dynamic>> _weapons() {
    final gear = (_data['gear'] as List? ?? []).whereType<Map>().toList();
    final equipSets = _data['equipSets'] as List? ?? [];
    Map<String, dynamic>? activeSet;
    for (final es in equipSets) {
      if (es is Map && es['active'] == true) { activeSet = Map.from(es as Map); break; }
    }
    activeSet ??= equipSets.isNotEmpty ? Map.from(equipSets.first as Map) : {};
    final slots = activeSet['slots'] as Map? ?? {};

    final weaponSlots = {'primary', 'secondary', 'both', 'primarydouble',
      'natural-primary', 'natural-secondary', 'naturalprimary', 'naturalsecondary'};

    final result = <Map<String, dynamic>>[];
    for (final entry in slots.entries) {
      if (!weaponSlots.contains(entry.key.toString().toLowerCase())) continue;
      final gearKey = entry.value;
      if (gearKey == null) continue;
      final item = gear.where((g) => g['key'] == gearKey || g['name'] == gearKey).firstOrNull;
      if (item == null) continue;
      final isRanged = item['isRanged'] as bool? ?? false;
      final bab = _pc.getBABAsInt();
      final tohitBonus = isRanged ? _pc.getTohitBonusRanged() : _pc.getTohitBonusMelee();
      // EQMOD bonuses from sheet data
      final eqTohit = item['eqTohit'] as int? ?? 0;
      final totalTohit = bab + tohitBonus + eqTohit;
      final attacks = <String>[];
      var cur = totalTohit;
      while (attacks.isEmpty || (cur > 0 && totalTohit - cur < 20)) {
        attacks.add(_signed(cur)); cur -= 5;
      }
      result.add({
        'name': item['name'] ?? '',
        'tohit': attacks.join('/'),
        'damage': item['damage'] ?? '1d6',
        'crit': item['crit'] ?? '20/×2',
        'isRanged': isRanged,
        'slot': entry.key,
      });
    }
    return result;
  }

  List<Map<String, dynamic>> _armorItems() {
    final gear = (_data['gear'] as List? ?? []).whereType<Map>().toList();
    final equipSets = _data['equipSets'] as List? ?? [];
    Map<String, dynamic>? activeSet;
    for (final es in equipSets) {
      if (es is Map && es['active'] == true) { activeSet = Map.from(es as Map); break; }
    }
    activeSet ??= equipSets.isNotEmpty ? Map.from(equipSets.first as Map) : {};
    final slots = activeSet['slots'] as Map? ?? {};

    final armorSlots = {'armor', 'shield'};
    final result = <Map<String, dynamic>>[];
    for (final entry in slots.entries) {
      if (!armorSlots.contains(entry.key.toString().toLowerCase())) continue;
      final gearKey = entry.value;
      final item = gear.where((g) => g['key'] == gearKey || g['name'] == gearKey).firstOrNull;
      if (item != null) result.add(Map.from(item as Map));
    }
    return result;
  }

  List<Map<String, dynamic>> _skills() {
    if (_dataset == null) return [];
    try {
      return (_dataset.skills as List).map<Map<String, dynamic>>((s) {
        final name = s.getDisplayName() ?? s.getKeyName();
        final key  = s.getKeyName() as String;
        final total = _pc.getSkillBonus(name as String, key);
        final ranks = _pc.getSkillRanks(s);
        return {'name': name, 'key': key, 'total': total, 'ranks': ranks};
      }).where((m) => (m['ranks'] as num? ?? 0) > 0).toList()
        ..sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
    } catch (_) { return []; }
  }

  // ─── HTML sections ──────────────────────────────────────────────────────────

  String _head() => '''<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>${_esc(_pc.getName())} — PCGen Character Sheet</title>
<style>
  body { font-family: 'Times New Roman', Times, serif; font-size: 10pt; margin: 0; padding: 0; background: #fff; color: #000; }
  .sheet { max-width: 800px; margin: 0 auto; padding: 10px; }
  h1.charname { font-size: 18pt; font-weight: bold; margin: 0; border-bottom: 2px solid #000; }
  h3.section-head { font-size: 10pt; font-weight: bold; background: #333; color: #fff; padding: 2px 6px; margin: 8px 0 2px 0; }
  table { border-collapse: collapse; width: 100%; margin-bottom: 4px; }
  td, th { border: 1px solid #aaa; padding: 2px 5px; font-size: 9pt; vertical-align: middle; }
  th { background: #ddd; font-weight: bold; text-align: center; }
  .label { font-weight: bold; background: #eee; width: 120px; }
  .val { text-align: center; }
  .big { font-size: 13pt; font-weight: bold; text-align: center; }
  .hdr-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 4px; margin-bottom: 6px; }
  .hdr-cell { border: 1px solid #aaa; padding: 2px 6px; }
  .hdr-label { font-size: 7pt; color: #666; }
  .hdr-value { font-size: 11pt; font-weight: bold; }
  .two-col { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; }
  .stat-box { text-align: center; border: 2px solid #000; padding: 4px; }
  .stat-name { font-size: 7pt; font-weight: bold; }
  .stat-score { font-size: 18pt; font-weight: bold; line-height: 1; }
  .stat-mod { font-size: 11pt; }
  .stat-grid { display: grid; grid-template-columns: repeat(6, 1fr); gap: 4px; margin-bottom: 6px; }
  .save-row td { text-align: center; }
  @media print {
    body { font-size: 9pt; }
    .sheet { max-width: 100%; }
    h3.section-head { background: #333 !important; -webkit-print-color-adjust: exact; }
  }
</style>
</head>
''';

  String _headerSection() {
    final classes = _classBreakdown();
    final classStr = classes.map((c) => '${c['name']} ${c['level']}').join(' / ');
    final level = _pc.getTotalCharacterLevel();
    final align = _pc.getAlignmentKey();
    final deity = _pc.getDeityKey();
    final race  = _raceName();
    final size  = _pc.getRaceSize();
    final xp    = _pc.getXP();
    final gender = _pc.getGender();
    final age   = _pc.getAge();

    return '''
<h1 class="charname">${_esc(_pc.getName())}</h1>
<div class="hdr-grid">
  <div class="hdr-cell"><div class="hdr-label">Player</div><div class="hdr-value">${_esc(_pc.getPlayersName())}</div></div>
  <div class="hdr-cell"><div class="hdr-label">Race</div><div class="hdr-value">${_esc(race)}</div></div>
  <div class="hdr-cell"><div class="hdr-label">Classes / Level</div><div class="hdr-value">${_esc(classStr)} (${level})</div></div>
  <div class="hdr-cell"><div class="hdr-label">Alignment</div><div class="hdr-value">${_esc(align)}</div></div>
  <div class="hdr-cell"><div class="hdr-label">Deity</div><div class="hdr-value">${_esc(deity)}</div></div>
  <div class="hdr-cell"><div class="hdr-label">Size / Gender / Age</div><div class="hdr-value">${_esc(size)} / ${_esc(gender)} / $age</div></div>
  <div class="hdr-cell"><div class="hdr-label">XP</div><div class="hdr-value">$xp</div></div>
  <div class="hdr-cell"><div class="hdr-label">HP (current / max)</div><div class="hdr-value">${_pc.getHP()} / ${_pc.getMaxHP()}</div></div>
</div>
''';
  }

  String _statsSection() {
    final buf = StringBuffer();
    buf.write(_h('Ability Scores'));
    buf.write('<div class="stat-grid">\n');
    for (final abb in _statOrder) {
      final score = _score(abb);
      final mod   = _mod(abb);
      final modStr = mod >= 0 ? '+$mod' : '$mod';
      buf.write('''<div class="stat-box">
  <div class="stat-name">$abb</div>
  <div class="stat-score">$score</div>
  <div class="stat-mod">$modStr</div>
</div>\n''');
    }
    buf.write('</div>\n');

    // Saves
    buf.write(_h('Saving Throws'));
    buf.write('<table><tr>');
    buf.write(_th('Save')); buf.write(_th('Total')); buf.write(_th('Base')); buf.write(_th('Ability'));
    buf.write('</tr>\n');
    final saves = [_pc.getFortSave(), _pc.getRefSave(), _pc.getWillSave()];
    final saveStats = ['CON', 'DEX', 'WIS'];
    for (var i = 0; i < 3; i++) {
      buf.write('<tr>');
      buf.write(_td(_saveNames[i], cls: 'label'));
      buf.write(_td(_signed(saves[i]), cls: 'val big'));
      buf.write(_td('—', cls: 'val'));
      buf.write(_td(_signed(_mod(saveStats[i])), cls: 'val'));
      buf.write('</tr>\n');
    }
    buf.write('</table>\n');

    return buf.toString();
  }

  String _combatSection() {
    final buf = StringBuffer();
    buf.write(_h('Combat'));
    buf.write('<table><tr>');
    buf.write(_th('BAB')); buf.write(_th('AC')); buf.write(_th('Touch AC'));
    buf.write(_th('Flat-Footed')); buf.write(_th('Initiative'));
    buf.write(_th('SR')); buf.write(_th('DR'));
    buf.write('</tr><tr>');
    buf.write(_td(_pc.getBAB(), cls: 'val big'));
    buf.write(_td(_pc.getAC().toString(), cls: 'val big'));
    buf.write(_td(_pc.getTouchAC().toString(), cls: 'val'));
    buf.write(_td(_pc.getFlatFootedAC().toString(), cls: 'val'));
    buf.write(_td(_signed(_pc.getInitiative()), cls: 'val'));
    buf.write(_td(_pc.getSR().toString(), cls: 'val'));
    buf.write(_td(_data['dr'] as String? ?? '—', cls: 'val'));
    buf.write('</tr></table>\n');
    return buf.toString();
  }

  String _skillsSection() {
    final skills = _skills();
    if (skills.isEmpty) return '';
    final buf = StringBuffer();
    buf.write(_h('Skills (with ranks)'));
    buf.write('<table><tr>');
    buf.write(_th('Skill')); buf.write(_th('Total')); buf.write(_th('Ranks'));
    buf.write('</tr>\n');
    for (final sk in skills) {
      buf.write('<tr>');
      buf.write(_td(_esc(sk['name'] as String), cls: 'label'));
      buf.write(_td((sk['total'] as num? ?? 0).toString(), cls: 'val'));
      buf.write(_td((sk['ranks'] as num? ?? 0).toString(), cls: 'val'));
      buf.write('</tr>\n');
    }
    buf.write('</table>\n');
    return buf.toString();
  }

  String _featsSection() {
    final selected = _data['selectedAbilities'] as Map? ?? {};
    final feats = (selected['FEAT'] as List?)?.cast<String>() ?? [];
    if (feats.isEmpty) return '';
    final buf = StringBuffer();
    buf.write(_h('Feats &amp; Special Abilities'));
    buf.write('<ul style="column-count:2; margin:0; padding-left:18px;">\n');
    for (final f in feats) {
      final sep = f.indexOf('|');
      final name = sep >= 0 ? f.substring(0, sep) : f;
      final sub  = sep >= 0 ? ' (${f.substring(sep + 1)})' : '';
      buf.write('<li>${_esc(name)}${_esc(sub)}</li>\n');
    }
    // Other categories (traits, class features, etc.)
    for (final entry in selected.entries) {
      if (entry.key == 'FEAT') continue;
      final items = (entry.value as List?)?.cast<String>() ?? [];
      if (items.isEmpty) continue;
      buf.write('<li><b>${_esc(entry.key.toString())}:</b> ${_esc(items.map((s) { final sep=s.indexOf('|'); return sep>=0?s.substring(0,sep):s; }).join(', '))}</li>\n');
    }
    buf.write('</ul>\n');
    return buf.toString();
  }

  String _weaponsSection() {
    final ws = _weapons();
    if (ws.isEmpty) return '';
    final buf = StringBuffer();
    buf.write(_h('Attacks'));
    buf.write('<table><tr>');
    buf.write(_th('Weapon')); buf.write(_th('Attack')); buf.write(_th('Damage'));
    buf.write(_th('Crit')); buf.write(_th('Type'));
    buf.write('</tr>\n');
    for (final w in ws) {
      buf.write('<tr>');
      buf.write(_td(_esc(w['name'] as String), cls: 'label'));
      buf.write(_td(_esc(w['tohit'] as String), cls: 'val'));
      buf.write(_td(_esc(w['damage'] as String? ?? '—'), cls: 'val'));
      buf.write(_td(_esc(w['crit'] as String? ?? '20/×2'), cls: 'val'));
      buf.write(_td(w['isRanged'] == true ? 'R' : 'M', cls: 'val'));
      buf.write('</tr>\n');
    }
    buf.write('</table>\n');
    return buf.toString();
  }

  String _armorSection() {
    final armor = _armorItems();
    if (armor.isEmpty) return '';
    final buf = StringBuffer();
    buf.write(_h('Armor &amp; Protective Equipment'));
    buf.write('<table><tr>');
    buf.write(_th('Item')); buf.write(_th('AC Bonus')); buf.write(_th('Max Dex'));
    buf.write(_th('Check Penalty')); buf.write(_th('Spell Fail'));
    buf.write('</tr>\n');
    for (final item in armor) {
      buf.write('<tr>');
      buf.write(_td(_esc(item['name'] as String? ?? ''), cls: 'label'));
      buf.write(_td((item['acBonus'] as num?)?.toString() ?? '—', cls: 'val'));
      buf.write(_td((item['maxDex'] as num?)?.toString() ?? '—', cls: 'val'));
      buf.write(_td((item['checkPenalty'] as num?)?.toString() ?? '—', cls: 'val'));
      buf.write(_td((item['spellFail'] as num?)?.toString() ?? '—', cls: 'val'));
      buf.write('</tr>\n');
    }
    buf.write('</table>\n');
    return buf.toString();
  }

  String _gearSection() {
    final gear = (_data['gear'] as List? ?? []).whereType<Map>().toList();
    if (gear.isEmpty) return '';
    final buf = StringBuffer();
    buf.write(_h('Gear &amp; Equipment'));
    buf.write('<table><tr>');
    buf.write(_th('Item')); buf.write(_th('Qty')); buf.write(_th('Weight'));
    buf.write('</tr>\n');
    for (final item in gear) {
      buf.write('<tr>');
      buf.write(_td(_esc(item['name'] as String? ?? ''), cls: 'label'));
      buf.write(_td((item['qty'] as num?)?.toString() ?? '1', cls: 'val'));
      buf.write(_td((item['weight'] as num?)?.toStringAsFixed(1) ?? '—', cls: 'val'));
      buf.write('</tr>\n');
    }
    buf.write('</table>\n');
    final funds = _pc.getFunds();
    buf.write('<p style="margin:2px 0;"><b>Funds:</b> ${funds.toStringAsFixed(2)} gp</p>\n');
    return buf.toString();
  }

  String _spellsSection() {
    // Placeholder — spell data is not yet fully modelled
    return '';
  }

  String _bioSection() {
    final bio = _pc.getBiography();
    final notes = _pc.getNotes();
    if (bio.isEmpty && notes.isEmpty) return '';
    final buf = StringBuffer();
    if (bio.isNotEmpty) {
      buf.write(_h('Biography'));
      buf.write('<p style="margin:2px 0;">${_esc(bio).replaceAll('\n', '<br>')}</p>\n');
    }
    if (notes.isNotEmpty) {
      buf.write(_h('Notes'));
      buf.write('<p style="margin:2px 0;">${_esc(notes).replaceAll('\n', '<br>')}</p>\n');
    }
    return buf.toString();
  }

  String _esc(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');
}
