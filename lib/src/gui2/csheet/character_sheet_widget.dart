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
          _buildQualities(),
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
          _buildSpells(),
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
    final bab    = pc.getBABAsInt();
    final strMod = _mod('STR');
    final dexMod = _mod('DEX');
    final sizeMod = _sizeModCombat(pc.getRaceSize());
    final cmb = bab + strMod + sizeMod;
    final cmd = 10 + bab + strMod + dexMod + sizeMod;

    // Speed: base from race + any bonuses
    final baseSpeeds = pc.toJson()['raceSpeeds'] as Map? ?? {};
    final bonusSpeeds = pc.getMovementBonuses();
    final allSpeeds = <String, int>{};
    for (final e in baseSpeeds.entries) {
      allSpeeds[e.key as String] = (e.value as num).toInt();
    }
    for (final e in bonusSpeeds.entries) {
      allSpeeds[e.key] = (allSpeeds[e.key] ?? 0) + e.value;
    }
    final speedStr = allSpeeds.isEmpty ? '30 ft.'
        : allSpeeds.entries.map((e) => '${e.key} ${e.value} ft.').join(', ');

    final drList = pc.getDRList();
    final sr     = pc.getSR();

    return _section('Combat', Column(children: [
      _statRow('BAB',         pc.getBAB()),
      _statRow('AC',          '${pc.getAC()}  (touch ${pc.getTouchAC()}  flat-footed ${pc.getFlatFootedAC()})'),
      _statRow('Initiative',  _signed(pc.getInitiative())),
      _statRow('Max HP',      '${pc.getMaxHP()}'),
      _statRow('CMB / CMD',   '${_signed(cmb)} / ${cmd}'),
      _statRow('Speed',       speedStr),
      if (drList.isNotEmpty) _statRow('DR', drList.join('; ')),
      if (sr > 0)            _statRow('SR', '$sr'),
    ]));
  }

  static int _sizeModCombat(String size) {
    const mods = {'F': -8, 'D': -4, 'T': -2, 'S': -1, 'M': 0,
                  'L': 1, 'H': 2, 'G': 4, 'C': 8};
    return mods[size.toUpperCase()] ?? 0;
  }

  // ─── Qualities (vision, languages, proficiencies, domains, templates) ────────

  Widget _buildQualities() {
    final data      = pc.toJson();
    final visions   = pc.getVisionTypes();
    final languages = (data['languageKeys'] as List? ?? []).cast<String>();
    final profs     = pc.getWeaponProficiencies().toList()..sort();
    final domains   = pc.getSelectedDomainKeys();
    final templates = pc.getAppliedTemplateKeys();

    final rows = <Widget>[];
    if (visions.isNotEmpty)   rows.add(_statRow('Vision',      visions.join(', ')));
    if (languages.isNotEmpty) rows.add(_statRow('Languages',   languages.join(', ')));
    if (domains.isNotEmpty)   rows.add(_statRow('Domains',     domains.join(', ')));
    if (templates.isNotEmpty) rows.add(_statRow('Templates',   templates.join(', ')));
    if (profs.isNotEmpty)     rows.add(_statRow('Weapon Profs', profs.join(', ')));

    if (rows.isEmpty) return const SizedBox.shrink();
    return _section('Character Qualities', Column(children: rows));
  }

  // ─── Spells ──────────────────────────────────────────────────────────────────

  Widget _buildSpells() {
    final data     = pc.toJson();
    final prepared = (data['preparedSpells'] as List? ?? []).whereType<Map>().toList();
    final known    = (data['knownSpells']    as List? ?? []).whereType<Map>().toList();
    final slots    = (data['classSpellSlots'] as Map? ?? {});

    if (prepared.isEmpty && known.isEmpty && slots.isEmpty) return const SizedBox.shrink();

    final rows = <Widget>[];

    // Spell slots per class
    if (slots.isNotEmpty) {
      for (final entry in slots.entries) {
        final cls  = entry.key as String;
        final slotList = (entry.value as List?)?.cast<int>() ?? [];
        if (slotList.isEmpty) continue;
        final slotStr = slotList
            .asMap().entries.where((e) => e.value > 0)
            .map((e) => 'L${e.key}:${e.value}').join('  ');
        if (slotStr.isNotEmpty) rows.add(_statRow('$cls slots', slotStr));
      }
    }

    // Prepared spells grouped by level
    if (prepared.isNotEmpty) {
      rows.add(_subHeader('Prepared Spells'));
      final byLevel = <int, List<String>>{};
      for (final s in prepared) {
        final lvl  = (s['level'] as num?)?.toInt() ?? 0;
        final name = s['name'] as String? ?? '?';
        (byLevel[lvl] ??= []).add(name);
      }
      for (final lvl in byLevel.keys.toList()..sort()) {
        rows.add(_statRow('Level $lvl', byLevel[lvl]!.join(', ')));
      }
    }

    // Known spells grouped by level
    if (known.isNotEmpty) {
      rows.add(_subHeader('Known Spells'));
      final byLevel = <int, List<String>>{};
      for (final s in known) {
        final lvl  = (s['level'] as num?)?.toInt() ?? 0;
        final name = s['name'] as String? ?? '?';
        (byLevel[lvl] ??= []).add(name);
      }
      for (final lvl in byLevel.keys.toList()..sort()) {
        rows.add(_statRow('Level $lvl', byLevel[lvl]!.join(', ')));
      }
    }

    return _section('Spells', Column(children: rows));
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
    final total   = (sk['total']   as num? ?? 0).toInt();
    final ranks   = (sk['ranks']   as num? ?? 0).toInt();
    final statAbb = sk['statAbb']  as String? ?? '';
    final statMod = (sk['statMod'] as num? ?? 0).toInt();
    final detail  = statAbb.isNotEmpty
        ? '${_signed(total)}  ($ranks rnk + ${_signed(statMod)} $statAbb)'
        : '${_signed(total)}  ($ranks ranks)';
    return _statRow(sk['name'] as String, detail);
  }

  // ─── Feats & Abilities ──────────────────────────────────────────────────────

  // Category display order and labels
  static const _catOrder = ['FEAT', 'Special Ability', 'Trait', 'TRAIT', 'Internal'];
  static const _catLabels = {
    'FEAT': 'Feats',
    'Special Ability': 'Special Abilities',
    'Trait': 'Traits',
    'TRAIT': 'Traits',
    'Internal': 'Class Features',
  };

  Widget _buildFeats() {
    final data     = pc.toJson();
    final selected = (data['selectedAbilities'] as Map? ?? {});
    final types    = (data['abilityTypes']       as Map? ?? {});
    final descs    = (data['abilityDescs']        as Map? ?? {});

    if (selected.isEmpty) return const SizedBox.shrink();

    // Build ordered category list: known order first, then any extras
    final allCats = [
      ..._catOrder.where((c) => selected.containsKey(c)),
      ...selected.keys.where((k) => !_catOrder.contains(k)).cast<String>(),
    ];

    final sections = <Widget>[];
    final seenNames = <String>{}; // deduplicate across categories

    for (final cat in allCats) {
      final rawList = (selected[cat] as List?)?.cast<String>() ?? [];
      if (rawList.isEmpty) continue;

      // Strip APPLIEDTO suffix, deduplicate, sort
      final entries = rawList
          .map((s) {
            final pipeIdx = s.indexOf('|');
            final name    = pipeIdx >= 0 ? s.substring(0, pipeIdx) : s;
            final applied = pipeIdx >= 0 ? s.substring(pipeIdx + 1) : '';
            return (name: name, applied: applied);
          })
          .where((e) => seenNames.add(e.name))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));

      if (entries.isEmpty) continue;

      final label = _catLabels[cat] ?? cat;
      sections.add(_subHeader(label));

      for (final e in entries) {
        final type = types[e.name] as String? ?? '';
        final desc = descs[e.name] as String? ?? '';
        final sub  = [
          if (e.applied.isNotEmpty) 'Applied to: ${e.applied}',
          if (type.isNotEmpty) type,
        ].join(' · ');
        sections.add(_abilityRow(e.name, sub, desc));
      }
    }

    if (sections.isEmpty) return const SizedBox.shrink();
    return _section('Feats & Abilities', Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: sections,
    ));
  }

  Widget _subHeader(String text) => Padding(
    padding: const EdgeInsets.only(top: 6, bottom: 2),
    child: Text(text, style: TextStyle(
        fontSize: 11, fontWeight: FontWeight.bold, color: _accentCol)),
  );

  Widget _abilityRow(String name, String sub, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(name,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
          if (sub.isNotEmpty)
            Text(sub, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ]),
        if (desc.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 1),
            child: Text(desc, style: const TextStyle(fontSize: 10,
                color: Color(0xFF546E7A))),
          ),
      ]),
    );
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

    Widget gearRow(Map item) {
      final name   = item['name'] as String? ?? '—';
      final qty    = (item['qty'] as num?)?.toInt() ?? 1;
      final weight = (item['weight'] as num?)?.toStringAsFixed(1);
      final detail = [if (qty > 1) '×$qty', if (weight != null) '$weight lb'].join(' ');
      return _statRow(name, detail);
    }

    final mid   = (gear.length / 2).ceil();
    final left  = gear.sublist(0, mid);
    final right = gear.sublist(mid);

    return _section('Gear', Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Column(children: left.map(gearRow).toList())),
          const SizedBox(width: 8),
          Expanded(child: Column(children: right.map(gearRow).toList())),
        ]),
        const Divider(height: 10),
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
        final name    = (s.getDisplayName() ?? s.getKeyName()) as String;
        final key     = s.getKeyName() as String;
        final ranks   = pc.getSkillRanks(s);
        // Key stat abbreviation for this skill (STR, DEX, INT, etc.)
        String statAbb = '';
        try { statAbb = (s as dynamic).getKeyStatAbb() as String? ?? ''; } catch (_) {}
        final statMod = statAbb.isNotEmpty ? _mod(statAbb) : 0;
        final misc    = pc.getSkillBonus(name, key);
        final total   = ranks + statMod + misc;
        return {'name': name, 'key': key, 'total': total, 'ranks': ranks,
                'statAbb': statAbb, 'statMod': statMod};
      }).where((m) => (m['ranks'] as num? ?? 0) > 0).toList()
        ..sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
    } catch (_) { return []; }
  }
}
