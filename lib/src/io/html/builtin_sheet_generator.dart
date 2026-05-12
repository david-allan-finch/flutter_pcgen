// Built-in HTML character sheet generator.
// Uses only elements that flutter_html v3 actually renders:
// <h2>, <h3>, <p>, <b>, <i>, <br>, <hr>, <ul>, <li>, <span>.
// No <table> — flutter_html v3 does not render tables.

import 'package:flutter_pcgen/src/gui2/facade/character_facade_impl.dart';

class BuiltinSheetGenerator {
  final CharacterFacadeImpl _pc;
  final dynamic _dataset;

  static const _statOrder = ['STR', 'DEX', 'CON', 'INT', 'WIS', 'CHA'];
  static const _saveNames = ['Fortitude', 'Reflex', 'Will'];

  BuiltinSheetGenerator(this._pc, this._dataset);

  // ─── Public entry point ────────────────────────────────────────────────────

  String generate() {
    final buf = StringBuffer();
    buf.write(_headerSection());
    buf.write(_statsSection());
    buf.write(_savesSection());
    buf.write(_combatSection());
    buf.write(_skillsSection());
    buf.write(_featsSection());
    buf.write(_weaponsSection());
    buf.write(_armorSection());
    buf.write(_gearSection());
    buf.write(_bioSection());
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

  String _sec(String title) => '<h3>— $title —</h3>\n';
  String _kv(String label, String value) => '<p><b>${_esc(label)}:</b> ${_esc(value)}</p>\n';
  String _row(List<String> pairs) {
    final parts = <String>[];
    for (var i = 0; i < pairs.length; i += 2) {
      parts.add('<b>${_esc(pairs[i])}:</b> ${_esc(pairs[i + 1])}');
    }
    return '<p>${parts.join(' &nbsp;&nbsp; ')}</p>\n';
  }

  // ─── Sections ─────────────────────────────────────────────────────────────

  String _headerSection() {
    final classes = _classBreakdown()
        .map((c) => '${c['name']} ${c['level']}').join(' / ');
    final buf = StringBuffer();
    buf.write('<h2>${_esc(_pc.getName())}</h2>\n');
    buf.write(_row(['Player', _pc.getPlayersName(), 'Race', _raceName()]));
    buf.write(_row(['Class', '$classes (${_pc.getTotalCharacterLevel()})', 'Alignment', _pc.getAlignmentKey()]));
    buf.write(_row(['Size', _pc.getRaceSize(), 'Gender', _pc.getGender(), 'Age', '${_pc.getAge()}']));
    buf.write(_row(['HP', '${_pc.getHP()} / ${_pc.getMaxHP()} max', 'XP', '${_pc.getXP()}']));
    if (_pc.getDeityKey().isNotEmpty) buf.write(_kv('Deity', _pc.getDeityKey()));
    buf.write('<hr/>\n');
    return buf.toString();
  }

  String _statsSection() {
    final buf = StringBuffer();
    buf.write(_sec('Ability Scores'));
    final parts = <String>[];
    for (final abb in _statOrder) {
      parts.add('<b>$abb</b> ${_score(abb)} (${_signed(_mod(abb))})');
    }
    buf.write('<p>${parts.join(' &nbsp;&nbsp; ')}</p>\n');
    return buf.toString();
  }

  String _savesSection() {
    final saves = [_pc.getFortSave(), _pc.getRefSave(), _pc.getWillSave()];
    final buf = StringBuffer();
    buf.write(_sec('Saving Throws'));
    final parts = <String>[];
    for (var i = 0; i < 3; i++) {
      parts.add('<b>${_saveNames[i]}:</b> ${_signed(saves[i])}');
    }
    buf.write('<p>${parts.join(' &nbsp;&nbsp; ')}</p>\n');
    return buf.toString();
  }

  String _combatSection() {
    final buf = StringBuffer();
    buf.write(_sec('Combat'));
    buf.write(_row(['BAB', _pc.getBAB(), 'AC', '${_pc.getAC()}',
                    'Touch', '${_pc.getTouchAC()}', 'Flat-Footed', '${_pc.getFlatFootedAC()}']));
    buf.write(_row(['Initiative', _signed(_pc.getInitiative()),
                    'Max HP', '${_pc.getMaxHP()}', 'Speed', '30 ft.']));
    return buf.toString();
  }

  String _skillsSection() {
    final skills = _skills();
    if (skills.isEmpty) return '';
    final buf = StringBuffer();
    buf.write(_sec('Skills (with ranks)'));
    buf.write('<ul>\n');
    for (final sk in skills) {
      final total = sk['total'] as num? ?? 0;
      final ranks = sk['ranks'] as num? ?? 0;
      buf.write('<li><b>${_esc(sk['name'] as String)}:</b> '
          '${_signed(total.toInt())} ($ranks ranks)</li>\n');
    }
    buf.write('</ul>\n');
    return buf.toString();
  }

  String _featsSection() {
    final selected = _data['selectedAbilities'] as Map? ?? {};
    final feats = (selected['FEAT'] as List?)?.cast<String>() ?? [];
    if (feats.isEmpty) return '';
    final buf = StringBuffer();
    buf.write(_sec('Feats'));
    buf.write('<ul>\n');
    for (final f in feats) {
      final name = f.contains('|') ? f.substring(0, f.indexOf('|')) : f;
      buf.write('<li>${_esc(name)}</li>\n');
    }
    buf.write('</ul>\n');
    return buf.toString();
  }

  String _weaponsSection() {
    final ws = _equippedItems(weapons: true);
    if (ws.isEmpty) return '';
    final bab = _pc.getBABAsInt();
    final buf = StringBuffer();
    buf.write(_sec('Weapons'));
    buf.write('<ul>\n');
    for (final item in ws) {
      final isRanged = item['isRanged'] as bool? ?? false;
      final bonus = isRanged ? _pc.getTohitBonusRanged() : _pc.getTohitBonusMelee();
      final eqTohit = item['eqTohit'] as int? ?? 0;
      final total = bab + bonus + eqTohit;
      final attacks = <String>[];
      var cur = total;
      do { attacks.add(_signed(cur)); cur -= 5; } while (cur > total - 20 && attacks.length < 5);
      final dmg  = item['damage'] as String? ?? '1d6';
      final crit = item['crit'] as String? ?? '20/×2';
      final type = isRanged ? 'ranged' : 'melee';
      buf.write('<li><b>${_esc(item['name'] as String? ?? '')}</b> '
          '${attacks.join('/')} — $dmg (crit $crit) $type</li>\n');
    }
    buf.write('</ul>\n');
    return buf.toString();
  }

  String _armorSection() {
    final armor = _equippedItems(weapons: false);
    if (armor.isEmpty) return '';
    final buf = StringBuffer();
    buf.write(_sec('Armor &amp; Shields'));
    buf.write('<ul>\n');
    for (final item in armor) {
      final name    = _esc(item['name'] as String? ?? '');
      final acBonus = item['acBonus'] as num?;
      final maxDex  = item['maxDex'] as num?;
      buf.write('<li><b>$name</b>');
      if (acBonus != null) buf.write(' +$acBonus AC');
      if (maxDex  != null) buf.write(' (max DEX +$maxDex)');
      buf.write('</li>\n');
    }
    buf.write('</ul>\n');
    return buf.toString();
  }

  String _gearSection() {
    final gear = (_data['gear'] as List? ?? []).whereType<Map>().toList();
    if (gear.isEmpty) return '';
    final buf = StringBuffer();
    buf.write(_sec('Gear'));
    buf.write('<ul>\n');
    for (final item in gear) {
      final name   = _esc(item['name'] as String? ?? '');
      final qty    = (item['qty'] as num?)?.toInt() ?? 1;
      final weight = (item['weight'] as num?)?.toStringAsFixed(1);
      buf.write('<li>$name');
      if (qty > 1) buf.write(' ×$qty');
      if (weight != null) buf.write(' ($weight lb)');
      buf.write('</li>\n');
    }
    buf.write('</ul>\n');
    buf.write('<p><b>Gold:</b> ${_pc.getFunds().toStringAsFixed(2)} gp</p>\n');
    return buf.toString();
  }

  String _bioSection() {
    final bio   = _pc.getBiography();
    final notes = _pc.getNotes();
    if (bio.isEmpty && notes.isEmpty) return '';
    final buf = StringBuffer();
    if (bio.isNotEmpty) {
      buf.write(_sec('Biography'));
      buf.write('<p>${_esc(bio).replaceAll('\n', '<br/>')}</p>\n');
    }
    if (notes.isNotEmpty) {
      buf.write(_sec('Notes'));
      buf.write('<p>${_esc(notes).replaceAll('\n', '<br/>')}</p>\n');
    }
    return buf.toString();
  }
}
