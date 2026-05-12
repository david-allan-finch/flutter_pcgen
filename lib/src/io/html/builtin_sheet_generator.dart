// Built-in HTML character sheet generator.
// Produces HTML using only inline styles and <table> layouts so it renders
// correctly inside flutter_html (which ignores <style> blocks and CSS grids).

import 'package:flutter_pcgen/src/gui2/facade/character_facade_impl.dart';

class BuiltinSheetGenerator {
  final CharacterFacadeImpl _pc;
  final dynamic _dataset;

  static const _statOrder = ['STR', 'DEX', 'CON', 'INT', 'WIS', 'CHA'];
  static const _saveNames  = ['Fortitude', 'Reflex', 'Will'];
  static const _saveStats  = ['CON', 'DEX', 'WIS'];

  BuiltinSheetGenerator(this._pc, this._dataset);

  // ─── Inline style constants ───────────────────────────────────────────────

  static const _styleTable  = 'border-collapse:collapse;width:100%;margin-bottom:6px;';
  static const _styleTd     = 'border:1px solid #aaa;padding:3px 6px;font-size:9pt;vertical-align:middle;';
  static const _styleTh     = 'border:1px solid #888;padding:3px 6px;font-size:8pt;font-weight:bold;background:#ddd;text-align:center;';
  static const _styleLabel  = 'border:1px solid #aaa;padding:3px 6px;font-size:9pt;font-weight:bold;background:#f0f0f0;width:140px;';
  static const _styleVal    = 'border:1px solid #aaa;padding:3px 6px;font-size:9pt;text-align:center;';
  static const _styleBigVal = 'border:1px solid #aaa;padding:3px 6px;font-size:12pt;font-weight:bold;text-align:center;';
  // Section header rendered as a full-width table row (td bg renders in flutter_html)
  static const _styleSecHdrTd = 'background-color:#444;color:#fff;font-size:10pt;font-weight:bold;'
                                 'padding:4px 8px;';
  static const _styleHdrLabel = 'font-size:8pt;color:#555;padding:0;';
  static const _styleHdrVal   = 'font-size:10pt;font-weight:bold;padding:0;';

  // ─── Public entry point ────────────────────────────────────────────────────

  String generate() {
    final buf = StringBuffer();
    buf.writeln('<div style="font-family:sans-serif;font-size:10pt;padding:6px;">');
    buf.write(_headerSection());
    buf.write(_statsSection());
    buf.write(_combatSection());
    buf.write(_skillsSection());
    buf.write(_featsSection());
    buf.write(_weaponsSection());
    buf.write(_armorSection());
    buf.write(_gearSection());
    buf.write(_bioSection());
    buf.writeln('</div>');
    return buf.toString();
  }

  // ─── Data helpers ──────────────────────────────────────────────────────────

  Map<String, dynamic> get _data => _pc.toJson();

  String _raceName() {
    try { return (_pc.getRaceRef().get() as dynamic)?.getDisplayName() as String? ?? _pc.getRaceKey(); }
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
  String _esc(String s) => s
      .replaceAll('&', '&amp;').replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;').replaceAll('"', '&quot;');

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

  // equippedSlots is flat Map<slotName, itemKey> (fixed from equipSets bug)
  List<Map<String, dynamic>> _equippedItems({required bool weapons}) {
    final gear = (_data['gear'] as List? ?? []).whereType<Map>().toList();
    final slots = _data['equippedSlots'] as Map? ?? {};
    final result = <Map<String, dynamic>>[];
    for (final entry in slots.entries) {
      final sl = entry.key.toString().toLowerCase();
      final isWeapon = sl.contains('primary') || sl.contains('secondary') ||
          sl.contains('off hand') || sl.startsWith('both') || sl.startsWith('natural');
      final isArmor  = sl == 'armor' || sl == 'shield';
      if (weapons && !isWeapon) continue;
      if (!weapons && !isArmor) continue;
      final gearKey = entry.value;
      final item = gear.where((g) => g['key'] == gearKey || g['name'] == gearKey).firstOrNull;
      if (item != null) result.add(Map<String, dynamic>.from(item));
    }
    return result;
  }

  List<Map<String, dynamic>> _skills() {
    if (_dataset == null) return [];
    try {
      return (_dataset.skills as List).map<Map<String, dynamic>>((s) {
        final name  = (s.getDisplayName() ?? s.getKeyName()) as String;
        final key   = s.getKeyName() as String;
        final total = _pc.getSkillBonus(name, key);
        final ranks = _pc.getSkillRanks(s);
        return {'name': name, 'key': key, 'total': total, 'ranks': ranks};
      }).where((m) => (m['ranks'] as num? ?? 0) > 0).toList()
        ..sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
    } catch (_) { return []; }
  }

  // ─── HTML helpers ──────────────────────────────────────────────────────────

  // Renders as a 1-row table so background-color works in flutter_html
  String _sectionHeader(String text) =>
      '<table style="width:100%;margin:8px 0 2px 0;border-collapse:collapse;">'
      '<tr><td style="$_styleSecHdrTd">${_esc(text)}</td></tr>'
      '</table>\n';

  String _td(String text, {String style = _styleTd}) =>
      '<td style="$style">$text</td>';

  String _th(String text) => '<td style="$_styleTh">$text</td>';

  String _tableOpen() => '<table style="$_styleTable">\n';
  String get _tableClose => '</table>\n';

  // ─── Sections ─────────────────────────────────────────────────────────────

  String _headerSection() {
    final classes = _classBreakdown();
    final classStr = classes.map((c) => '${_esc(c['name'] as String)} ${c['level']}').join(' / ');
    final maxHp = _pc.getMaxHP();
    final hp    = _pc.getHP();

    // 4-column, 2-row info table
    final cells = [
      ['Player',          _esc(_pc.getPlayersName())],
      ['Class / Level',   '$classStr (${_pc.getTotalCharacterLevel()})'],
      ['Race',            _esc(_raceName())],
      ['Alignment',       _esc(_pc.getAlignmentKey())],
      ['Deity',           _esc(_pc.getDeityKey())],
      ['Size',            _esc(_pc.getRaceSize())],
      ['Gender / Age',    '${_esc(_pc.getGender())} / ${_pc.getAge()}'],
      ['HP (cur / max)',  '$hp / $maxHp'],
      ['XP',              '${_pc.getXP()}'],
      ['Next Level',      '${_pc.getXPForNextLevel()}'],
    ];

    final buf = StringBuffer();
    buf.writeln('<h2>${_esc(_pc.getName())}</h2>');
    buf.writeln(_tableOpen());
    for (var i = 0; i < cells.length; i += 2) {
      buf.write('<tr>');
      for (var j = i; j < i + 2 && j < cells.length; j++) {
        buf.write('<td style="border:1px solid #aaa;padding:3px 6px;">'
            '<span style="$_styleHdrLabel">${cells[j][0]}: </span>'
            '<span style="$_styleHdrVal">${cells[j][1]}</span>'
            '</td>');
      }
      buf.writeln('</tr>');
    }
    buf.writeln(_tableClose);
    return buf.toString();
  }

  String _statsSection() {
    final buf = StringBuffer();
    buf.writeln(_sectionHeader('Ability Scores'));

    // Stats: one row, 6 columns
    buf.writeln(_tableOpen());
    buf.write('<tr>');
    for (final abb in _statOrder) {
      buf.write(_th(abb));
    }
    buf.writeln('</tr>');
    // Score row
    buf.write('<tr>');
    for (final abb in _statOrder) {
      buf.write(_td('${_score(abb)}', style: _styleBigVal));
    }
    buf.writeln('</tr>');
    // Modifier row
    buf.write('<tr>');
    for (final abb in _statOrder) {
      buf.write(_td(_signed(_mod(abb)), style: _styleVal));
    }
    buf.writeln('</tr>');
    buf.writeln(_tableClose);

    // Saves
    buf.writeln(_sectionHeader('Saving Throws'));
    buf.writeln(_tableOpen());
    buf.write('<tr>${_th('Save')}${_th('Total')}${_th('Base')}${_th('Ability Mod')}</tr>\n');
    final saves = [_pc.getFortSave(), _pc.getRefSave(), _pc.getWillSave()];
    for (var i = 0; i < 3; i++) {
      buf.write('<tr>');
      buf.write(_td(_saveNames[i], style: _styleLabel));
      buf.write(_td(_signed(saves[i]), style: _styleBigVal));
      buf.write(_td('—', style: _styleVal));
      buf.write(_td(_signed(_mod(_saveStats[i])), style: _styleVal));
      buf.writeln('</tr>');
    }
    buf.writeln(_tableClose);
    return buf.toString();
  }

  String _combatSection() {
    final buf = StringBuffer();
    buf.writeln(_sectionHeader('Combat'));
    buf.writeln(_tableOpen());
    buf.write('<tr>');
    for (final h in ['BAB', 'AC', 'Touch AC', 'Flat-Footed', 'Initiative', 'HP Max']) {
      buf.write(_th(h));
    }
    buf.writeln('</tr><tr>');
    buf.write(_td(_pc.getBAB(), style: _styleVal));
    buf.write(_td(_pc.getAC().toString(), style: _styleBigVal));
    buf.write(_td(_pc.getTouchAC().toString(), style: _styleVal));
    buf.write(_td(_pc.getFlatFootedAC().toString(), style: _styleVal));
    buf.write(_td(_signed(_pc.getInitiative()), style: _styleVal));
    buf.write(_td(_pc.getMaxHP().toString(), style: _styleBigVal));
    buf.writeln('</tr>');
    buf.writeln(_tableClose);
    return buf.toString();
  }

  String _skillsSection() {
    final skills = _skills();
    if (skills.isEmpty) return '';
    final buf = StringBuffer();
    buf.writeln(_sectionHeader('Skills (with ranks)'));

    // Two-column table of skills (each column: name | total | ranks)
    final mid = (skills.length / 2).ceil();
    final left  = skills.sublist(0, mid);
    final right = skills.sublist(mid);

    buf.writeln(_tableOpen());
    buf.write('<tr>');
    buf.write(_th('Skill')); buf.write(_th('Tot')); buf.write(_th('Rnk'));
    buf.write(_th('Skill')); buf.write(_th('Tot')); buf.write(_th('Rnk'));
    buf.writeln('</tr>');
    for (var i = 0; i < left.length; i++) {
      final l = left[i];
      final r = i < right.length ? right[i] : null;
      buf.write('<tr>');
      buf.write(_td(_esc(l['name'] as String), style: _styleLabel));
      buf.write(_td((l['total'] as num? ?? 0).toString(), style: _styleVal));
      buf.write(_td((l['ranks'] as num? ?? 0).toString(), style: _styleVal));
      if (r != null) {
        buf.write(_td(_esc(r['name'] as String), style: _styleLabel));
        buf.write(_td((r['total'] as num? ?? 0).toString(), style: _styleVal));
        buf.write(_td((r['ranks'] as num? ?? 0).toString(), style: _styleVal));
      } else {
        buf.write('<td style="$_styleTd" colspan="3"></td>');
      }
      buf.writeln('</tr>');
    }
    buf.writeln(_tableClose);
    return buf.toString();
  }

  String _featsSection() {
    final selected = _data['selectedAbilities'] as Map? ?? {};
    final feats = (selected['FEAT'] as List?)?.cast<String>() ?? [];
    if (feats.isEmpty) return '';
    final buf = StringBuffer();
    buf.writeln(_sectionHeader('Feats &amp; Abilities'));
    buf.writeln(_tableOpen());
    final mid = (feats.length / 2).ceil();
    for (var i = 0; i < mid; i++) {
      final l = feats[i];
      final lName = _esc(l.contains('|') ? l.substring(0, l.indexOf('|')) : l);
      buf.write('<tr><td style="$_styleTd;width:50%">$lName</td>');
      if (i + mid < feats.length) {
        final r = feats[i + mid];
        final rName = _esc(r.contains('|') ? r.substring(0, r.indexOf('|')) : r);
        buf.write('<td style="$_styleTd">$rName</td>');
      } else {
        buf.write('<td style="$_styleTd"></td>');
      }
      buf.writeln('</tr>');
    }
    buf.writeln(_tableClose);
    return buf.toString();
  }

  String _weaponsSection() {
    final ws = _equippedItems(weapons: true);
    if (ws.isEmpty) return '';
    final buf = StringBuffer();
    buf.writeln(_sectionHeader('Weapons'));
    buf.writeln(_tableOpen());
    buf.write('<tr>${_th('Weapon')}${_th('Attack')}${_th('Damage')}${_th('Crit')}${_th('Type')}</tr>\n');
    for (final item in ws) {
      final isRanged = item['isRanged'] as bool? ?? false;
      final bab = _pc.getBABAsInt();
      final bonus = isRanged ? _pc.getTohitBonusRanged() : _pc.getTohitBonusMelee();
      final eqTohit = item['eqTohit'] as int? ?? 0;
      final total = bab + bonus + eqTohit;
      final attacks = <String>[];
      var cur = total;
      do { attacks.add(_signed(cur)); cur -= 5; } while (cur > total - 20 && attacks.length < 5);
      buf.write('<tr>');
      buf.write(_td(_esc(item['name'] as String? ?? ''), style: _styleLabel));
      buf.write(_td(_esc(attacks.join('/')), style: _styleVal));
      buf.write(_td(_esc(item['damage'] as String? ?? '1d6'), style: _styleVal));
      buf.write(_td(_esc(item['crit'] as String? ?? '20/×2'), style: _styleVal));
      buf.write(_td(isRanged ? 'Ranged' : 'Melee', style: _styleVal));
      buf.writeln('</tr>');
    }
    buf.writeln(_tableClose);
    return buf.toString();
  }

  String _armorSection() {
    final armor = _equippedItems(weapons: false);
    if (armor.isEmpty) return '';
    final buf = StringBuffer();
    buf.writeln(_sectionHeader('Armor &amp; Shields'));
    buf.writeln(_tableOpen());
    buf.write('<tr>${_th('Item')}${_th('AC Bonus')}${_th('Max Dex')}${_th('Check Pen')}${_th('Spell Fail')}</tr>\n');
    for (final item in armor) {
      buf.write('<tr>');
      buf.write(_td(_esc(item['name'] as String? ?? ''), style: _styleLabel));
      buf.write(_td((item['acBonus'] as num?)?.toString() ?? '—', style: _styleVal));
      buf.write(_td((item['maxDex'] as num?)?.toString() ?? '—', style: _styleVal));
      buf.write(_td((item['checkPenalty'] as num?)?.toString() ?? '—', style: _styleVal));
      buf.write(_td((item['spellFail'] as num?)?.toString() ?? '—', style: _styleVal));
      buf.writeln('</tr>');
    }
    buf.writeln(_tableClose);
    return buf.toString();
  }

  String _gearSection() {
    final gear = (_data['gear'] as List? ?? []).whereType<Map>().toList();
    if (gear.isEmpty) return '';
    final buf = StringBuffer();
    buf.writeln(_sectionHeader('Gear'));
    buf.writeln(_tableOpen());
    buf.write('<tr>${_th('Item')}${_th('Qty')}${_th('Weight (lbs)')}</tr>\n');
    for (final item in gear) {
      buf.write('<tr>');
      buf.write(_td(_esc(item['name'] as String? ?? ''), style: _styleLabel));
      buf.write(_td((item['qty'] as num?)?.toString() ?? '1', style: _styleVal));
      buf.write(_td((item['weight'] as num?)?.toStringAsFixed(1) ?? '—', style: _styleVal));
      buf.writeln('</tr>');
    }
    buf.writeln(_tableClose);
    buf.writeln('<p style="font-size:9pt;margin:2px 0;"><b>Gold:</b> ${_pc.getFunds().toStringAsFixed(2)} gp</p>');
    return buf.toString();
  }

  String _bioSection() {
    final bio   = _pc.getBiography();
    final notes = _pc.getNotes();
    if (bio.isEmpty && notes.isEmpty) return '';
    final buf = StringBuffer();
    if (bio.isNotEmpty) {
      buf.writeln(_sectionHeader('Biography'));
      buf.writeln('<p style="font-size:9pt;margin:2px 0;">${_esc(bio).replaceAll('\n', '<br>')}</p>');
    }
    if (notes.isNotEmpty) {
      buf.writeln(_sectionHeader('Notes'));
      buf.writeln('<p style="font-size:9pt;margin:2px 0;">${_esc(notes).replaceAll('\n', '<br>')}</p>');
    }
    return buf.toString();
  }
}
