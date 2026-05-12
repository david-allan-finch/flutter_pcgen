// Flutter-native character sheet renderer.
// Replaces the HTML/flutter_html approach with proper Flutter widgets.

import 'package:flutter/material.dart';
import 'package:flutter_pcgen/src/gui2/facade/character_facade_impl.dart';

class CharacterSheetWidget extends StatelessWidget {
  final CharacterFacadeImpl pc;
  final dynamic dataset;

  const CharacterSheetWidget({super.key, required this.pc, required this.dataset});

  static const _statOrder = ['STR', 'DEX', 'CON', 'INT', 'WIS', 'CHA'];
  static const _saveNames  = ['Fortitude', 'Reflex', 'Will'];

  // ─── Colours ────────────────────────────────────────────────────────────────

  static const _headerBg   = Color(0xFF37474F); // blue-grey 800
  static const _headerFg   = Colors.white;
  static const _labelBg    = Color(0xFFECEFF1); // blue-grey 50
  static const _borderCol  = Color(0xFFB0BEC5); // blue-grey 200
  static const _accentCol  = Color(0xFF1565C0); // blue 800

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(height: 8),
          _buildAbilityScores(),
          const SizedBox(height: 8),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: _buildSaves()),
            const SizedBox(width: 8),
            Expanded(child: _buildCombat()),
          ]),
          const SizedBox(height: 8),
          _buildSkills(),
          const SizedBox(height: 8),
          _buildFeats(),
          const SizedBox(height: 8),
          _buildWeapons(),
          const SizedBox(height: 8),
          _buildArmor(),
          const SizedBox(height: 8),
          _buildGear(),
          const SizedBox(height: 8),
          _buildBio(),
        ].where((w) => w is! SizedBox || true).toList(),
      ),
    );
  }

  // ─── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    final classes = _classBreakdown()
        .map((c) => '${c['name']} ${c['level']}').join(' / ');

    return Card(
      margin: EdgeInsets.zero,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          color: _headerBg,
          child: Text(pc.getName(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                  color: _headerFg)),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: _grid([
            'Player',    pc.getPlayersName(),
            'Classes',   '$classes  (level ${pc.getTotalCharacterLevel()})',
            'Race',      _raceName(),
            'Alignment', pc.getAlignmentKey(),
            'Deity',     pc.getDeityKey().isEmpty ? '—' : pc.getDeityKey(),
            'Size',      pc.getRaceSize(),
            'Gender',    pc.getGender(),
            'Age',       '${pc.getAge()}',
            'HP',        '${pc.getHP()} / ${pc.getMaxHP()} (max)',
            'XP',        '${pc.getXP()}  →  next: ${pc.getXPForNextLevel()}',
          ], columns: 2),
        ),
      ]),
    );
  }

  // ─── Ability scores ─────────────────────────────────────────────────────────

  Widget _buildAbilityScores() {
    return _section('Ability Scores', Row(
      children: _statOrder.map((abb) {
        final score = _score(abb);
        final mod   = _mod(abb);
        return Expanded(child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            border: Border.all(color: _borderCol),
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(children: [
            Text(abb, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold,
                color: _accentCol)),
            const SizedBox(height: 2),
            Text('$score', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(_signed(mod), style: TextStyle(fontSize: 12,
                color: mod >= 0 ? Colors.green.shade700 : Colors.red.shade700)),
          ]),
        ));
      }).toList(),
    ));
  }

  // ─── Saves ──────────────────────────────────────────────────────────────────

  Widget _buildSaves() {
    final totals = [pc.getFortSave(), pc.getRefSave(), pc.getWillSave()];
    return _section('Saving Throws', Column(
      children: List.generate(3, (i) => _statRow(
        _saveNames[i], _signed(totals[i]),
      )),
    ));
  }

  // ─── Combat ─────────────────────────────────────────────────────────────────

  Widget _buildCombat() {
    return _section('Combat', Column(children: [
      _statRow('BAB',          pc.getBAB()),
      _statRow('AC',           '${pc.getAC()}'),
      _statRow('Touch AC',     '${pc.getTouchAC()}'),
      _statRow('Flat-Footed',  '${pc.getFlatFootedAC()}'),
      _statRow('Initiative',   _signed(pc.getInitiative())),
      _statRow('Max HP',       '${pc.getMaxHP()}'),
    ]));
  }

  // ─── Skills ─────────────────────────────────────────────────────────────────

  Widget _buildSkills() {
    final skills = _skills();
    if (skills.isEmpty) return const SizedBox.shrink();
    final mid = (skills.length / 2).ceil();
    final left  = skills.sublist(0, mid);
    final right = skills.sublist(mid);

    return _section('Skills (with ranks)',
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Column(children: left.map(_skillRow).toList())),
        const SizedBox(width: 8),
        Expanded(child: Column(children: right.map(_skillRow).toList())),
      ]),
    );
  }

  Widget _skillRow(Map<String, dynamic> sk) {
    final total = (sk['total'] as num? ?? 0).toInt();
    final ranks = (sk['ranks'] as num? ?? 0).toInt();
    return _statRow(sk['name'] as String, '${_signed(total)}  ($ranks ranks)');
  }

  // ─── Feats ──────────────────────────────────────────────────────────────────

  Widget _buildFeats() {
    final selected = (pc.toJson()['selectedAbilities'] as Map? ?? {});
    final feats = (selected['FEAT'] as List?)?.cast<String>() ?? [];
    if (feats.isEmpty) return const SizedBox.shrink();
    final names = feats.map((f) => f.contains('|') ? f.substring(0, f.indexOf('|')) : f).toList()
      ..sort();
    return _section('Feats', Wrap(
      spacing: 6, runSpacing: 4,
      children: names.map((f) => Chip(
        label: Text(f, style: const TextStyle(fontSize: 11)),
        padding: EdgeInsets.zero,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      )).toList(),
    ));
  }

  // ─── Weapons ────────────────────────────────────────────────────────────────

  Widget _buildWeapons() {
    final ws = _equippedItems(weapons: true);
    if (ws.isEmpty) return const SizedBox.shrink();
    final bab = pc.getBABAsInt();
    return _section('Weapons', Column(
      children: ws.map((item) {
        final isRanged = item['isRanged'] as bool? ?? false;
        final bonus  = isRanged ? pc.getTohitBonusRanged() : pc.getTohitBonusMelee();
        final eqHit  = item['eqTohit'] as int? ?? 0;
        final total  = bab + bonus + eqHit;
        final attacks = <String>[];
        var cur = total;
        do { attacks.add(_signed(cur)); cur -= 5; } while (cur > total - 20 && attacks.length < 5);
        final dmg  = item['damage'] as String? ?? '1d6';
        final crit = item['crit']   as String? ?? '20/×2';
        final type = isRanged ? 'Ranged' : 'Melee';
        return _statRow(
          item['name'] as String? ?? '—',
          '${attacks.join('/')}   $dmg   crit $crit   $type',
        );
      }).toList(),
    ));
  }

  // ─── Armor ──────────────────────────────────────────────────────────────────

  Widget _buildArmor() {
    final armor = _equippedItems(weapons: false);
    if (armor.isEmpty) return const SizedBox.shrink();
    return _section('Armor & Shields', Column(
      children: armor.map((item) {
        final acBonus = item['acBonus'] as num?;
        final maxDex  = item['maxDex']  as num?;
        final parts = <String>[];
        if (acBonus != null) parts.add('+$acBonus AC');
        if (maxDex  != null) parts.add('max DEX +$maxDex');
        return _statRow(item['name'] as String? ?? '—',
            parts.isEmpty ? '—' : parts.join('   '));
      }).toList(),
    ));
  }

  // ─── Gear ───────────────────────────────────────────────────────────────────

  Widget _buildGear() {
    final gear = (pc.toJson()['gear'] as List? ?? []).whereType<Map>().toList();
    if (gear.isEmpty) return const SizedBox.shrink();
    return _section('Gear', Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...gear.map((item) {
          final name   = item['name'] as String? ?? '—';
          final qty    = (item['qty'] as num?)?.toInt() ?? 1;
          final weight = (item['weight'] as num?)?.toStringAsFixed(1);
          final detail = [
            if (qty > 1) '×$qty',
            if (weight != null) '$weight lb',
          ].join('   ');
          return _statRow(name, detail.isEmpty ? '' : detail);
        }),
        const Divider(height: 8),
        _statRow('Gold', '${pc.getFunds().toStringAsFixed(2)} gp'),
      ],
    ));
  }

  // ─── Bio ────────────────────────────────────────────────────────────────────

  Widget _buildBio() {
    final bio   = pc.getBiography();
    final notes = pc.getNotes();
    if (bio.isEmpty && notes.isEmpty) return const SizedBox.shrink();
    return _section('Biography & Notes', Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (bio.isNotEmpty) ...[
          const Text('Biography', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(bio, style: const TextStyle(fontSize: 12)),
        ],
        if (bio.isNotEmpty && notes.isNotEmpty) const SizedBox(height: 8),
        if (notes.isNotEmpty) ...[
          const Text('Notes', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(notes, style: const TextStyle(fontSize: 12)),
        ],
      ],
    ));
  }

  // ─── Shared layout helpers ───────────────────────────────────────────────────

  Widget _section(String title, Widget body) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          color: _headerBg,
          child: Text(title, style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.bold, color: _headerFg)),
        ),
        Padding(padding: const EdgeInsets.all(8), child: body),
      ]),
    );
  }

  // One labelled value row with alternating background
  Widget _statRow(String label, String value) {
    return IntrinsicHeight(child: Row(children: [
      Container(
        width: 150,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        color: _labelBg,
        child: Text(label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      ),
      Expanded(child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(value, style: const TextStyle(fontSize: 11)),
      )),
    ]));
  }

  // Key-value grid with N columns
  Widget _grid(List<String> pairs, {int columns = 2}) {
    final rows = <TableRow>[];
    for (var i = 0; i < pairs.length; i += columns * 2) {
      final cells = <Widget>[];
      for (var col = 0; col < columns; col++) {
        final idx = i + col * 2;
        if (idx + 1 < pairs.length) {
          cells.add(Padding(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
            child: RichText(text: TextSpan(
              style: const TextStyle(fontSize: 11, color: Colors.black),
              children: [
                TextSpan(text: '${pairs[idx]}: ',
                    style: const TextStyle(fontWeight: FontWeight.bold,
                        color: Color(0xFF546E7A))),
                TextSpan(text: pairs[idx + 1]),
              ],
            )),
          ));
        } else {
          cells.add(const SizedBox.shrink());
        }
      }
      rows.add(TableRow(children: cells));
    }
    return Table(children: rows);
  }

  // ─── Data helpers ────────────────────────────────────────────────────────────

  String _raceName() {
    try { return (_pc.getRaceRef().get() as dynamic)?.getDisplayName() as String? ?? _pc.getRaceKey(); }
    catch (_) { return _pc.getRaceKey(); }
  }
  CharacterFacadeImpl get _pc => pc;

  int _score(String abb) {
    if (dataset != null) {
      try {
        final stat = (dataset.stats as List).firstWhere((s) => s.getKeyName() == abb);
        return pc.getEffectiveScore(stat);
      } catch (_) {}
    }
    return (pc.toJson()['statScores']?[abb] as num?)?.toInt() ?? 10;
  }

  int _mod(String abb) => ((_score(abb) - 10) / 2).floor();
  String _signed(int n) => n >= 0 ? '+$n' : '$n';

  List<Map<String, dynamic>> _classBreakdown() {
    final classLevels = (pc.toJson()['classLevels'] as List? ?? []);
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
    final gear  = (pc.toJson()['gear'] as List? ?? []).whereType<Map>().toList();
    final slots = pc.toJson()['equippedSlots'] as Map? ?? {};
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
    if (dataset == null) return [];
    try {
      return (dataset.skills as List).map<Map<String, dynamic>>((s) {
        final name  = (s.getDisplayName() ?? s.getKeyName()) as String;
        final key   = s.getKeyName() as String;
        final total = pc.getSkillBonus(name, key);
        final ranks = pc.getSkillRanks(s);
        return {'name': name, 'key': key, 'total': total, 'ranks': ranks};
      }).where((m) => (m['ranks'] as num? ?? 0) > 0).toList()
        ..sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
    } catch (_) { return []; }
  }
}
