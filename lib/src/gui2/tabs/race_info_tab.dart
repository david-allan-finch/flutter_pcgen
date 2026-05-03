// Translation of pcgen.gui2.tabs.RaceInfoTab

import 'package:flutter/material.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/object_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/string_key.dart';
import 'package:flutter_pcgen/src/core/data_set.dart';
import 'package:flutter_pcgen/src/core/race.dart';
import 'package:flutter_pcgen/src/gui2/app_state.dart';
import 'package:flutter_pcgen/src/rules/parsed_bonus.dart';

/// Tab for browsing and selecting a character's race.
class RaceInfoTab extends StatefulWidget {
  const RaceInfoTab({super.key});

  @override
  State<RaceInfoTab> createState() => RaceInfoTabState();
}

class RaceInfoTabState extends State<RaceInfoTab> {
  dynamic _character;
  Race? _selected;
  bool _playerOnly = true;
  final TextEditingController _search = TextEditingController();

  static const _pcRaceTypes = {
    'Humanoid', 'Fey', 'Monstrous Humanoid', 'Giant',
  };

  void setCharacter(dynamic character) => setState(() => _character = character);

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DataSet?>(
      valueListenable: loadedDataSet,
      builder: (context, dataset, _) {
        final races = dataset?.races ?? const [];
        return ValueListenableBuilder(
          valueListenable: currentCharacter,
          builder: (context, character, _) {
            return Row(
              children: [
                Expanded(child: _buildList(races)),
                const VerticalDivider(width: 1),
                Expanded(child: _buildDetail(character, dataset)),
              ],
            );
          },
        );
      },
    );
  }

  String _raceType(Race race) {
    try {
      final tl = race.getSafeListFor(ListKey.getConstant<String>('TYPE'));
      final raceType = tl.cast<String>()
          .firstWhere((t) => t.startsWith('RACETYPE:'), orElse: () => '');
      if (raceType.isNotEmpty) return raceType.substring(9);
      // Fallback: use first non-meta type
      final plain = tl.cast<String>()
          .firstWhere((t) => !t.startsWith('RACESUBTYPE:'), orElse: () => '');
      if (plain.isNotEmpty) return plain;
    } catch (_) {}
    return 'Other';
  }

  bool _isPlayerRace(Race race) {
    try {
      final tl = race.getSafeListFor(ListKey.getConstant<String>('TYPE'));
      final raceType = tl.cast<String>()
          .firstWhere((t) => t.startsWith('RACETYPE:'), orElse: () => '');
      if (raceType.isNotEmpty) {
        final typeName = raceType.substring(9);
        return _pcRaceTypes.contains(typeName);
      }
    } catch (_) {}
    return false;
  }

  Widget _buildList(List<Race> races) {
    final query = _search.text.trim().toLowerCase();
    var filtered = _playerOnly ? races.where(_isPlayerRace).toList() : races;
    if (query.isNotEmpty) {
      filtered = filtered.where((r) => r.getDisplayName().toLowerCase().contains(query)).toList();
    }

    // Group by RACETYPE
    final grouped = <String, List<Race>>{};
    for (final race in filtered) {
      grouped.putIfAbsent(_raceType(race), () => []).add(race);
    }
    final categories = grouped.keys.toList()..sort();
    for (final cat in categories) {
      grouped[cat]!.sort((a, b) =>
          a.getDisplayName().toLowerCase().compareTo(b.getDisplayName().toLowerCase()));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _search,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Filter races…',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 6),
            FilterChip(
              label: const Text('PC Races', style: TextStyle(fontSize: 11)),
              selected: _playerOnly,
              onSelected: (v) => setState(() => _playerOnly = v),
              visualDensity: VisualDensity.compact,
              tooltip: 'Show only player-character races',
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('${filtered.length} races in ${categories.length} types',
                style: Theme.of(context).textTheme.bodySmall),
          ),
        ),
        Expanded(
          child: races.isEmpty
              ? const Center(child: Text('No races loaded.'))
              : ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, ci) {
                    final cat = categories[ci];
                    final items = grouped[cat]!;
                    return ExpansionTile(
                      key: PageStorageKey('race_$cat'),
                      initiallyExpanded: query.isNotEmpty || categories.length <= 4,
                      tilePadding: const EdgeInsets.symmetric(horizontal: 8),
                      title: Text(cat,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                      trailing: Text('${items.length}',
                          style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      children: items.map((race) => ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.only(left: 28, right: 8),
                        selected: _selected == race,
                        selectedTileColor: Theme.of(context)
                            .colorScheme.primaryContainer.withAlpha(80),
                        title: Text(race.getDisplayName(),
                            style: const TextStyle(fontSize: 12)),
                        onTap: () => setState(() => _selected = race),
                      )).toList(),
                    );
                  },
                ),
        ),
      ],
    );
  }

  /// Walk obj + its full AUTO_ABILITIES chain, collecting all race info fields.
  void _collectRaceInfo(_RaceInfo info, dynamic obj, DataSet? dataset, Set<String> seen) {
    if (obj == null) return;
    try {
      // BONUS:STAT
      final bonuses = (obj as dynamic).getSafeListFor(ListKey.getConstant<ParsedBonus>('PARSED_BONUS')) as List;
      for (final b in bonuses) {
        if (b is! ParsedBonus) continue;
        if (b.category == 'STAT') {
          final v = int.tryParse(b.formula);
          if (v != null) {
            for (final t in b.targets) {
              final k = t.toUpperCase();
              info.statMods[k] = (info.statMods[k] ?? 0) + v;
            }
          }
        } else if (b.category == 'SKILL') {
          final v = int.tryParse(b.formula);
          if (v != null && v != 0) {
            for (final t in b.targets) {
              final sign = v > 0 ? '+' : '';
              info.skillBonuses.add('$t $sign$v');
            }
          }
        }
      }
      // SAB (special ability text)
      final sabs = (obj as dynamic).getSafeListFor(ListKey.getConstant<String>('SAB_LIST')) as List;
      for (final s in sabs) { if (s is String && s.isNotEmpty) info.specialAbilities.add(s); }
      // Vision
      final vis = (obj as dynamic).getSafeListFor(ListKey.getConstant<String>('VISION_TYPES')) as List;
      for (final v in vis) { if (v is String && v.isNotEmpty) info.vision.add(v); }
      // Languages
      final langs = (obj as dynamic).getSafeListFor(ListKey.getConstant<String>('AUTO_LANG')) as List;
      for (final l in langs) { if (l is String && l.isNotEmpty) info.autoLang.add(l); }
      final bonus = (obj as dynamic).getSafeListFor(ListKey.getConstant<String>('LANG_BONUS')) as List;
      for (final l in bonus) { if (l is String && l.isNotEmpty) info.bonusLang.add(l); }
      // Natural attacks
      final nat = (obj as dynamic).getSafeListFor(ListKey.getConstant<String>('NATURAL_ATTACKS')) as List;
      for (final a in nat) { if (a is String && a.isNotEmpty) info.naturalAttacks.add(a); }
      // Weapon profs
      final wp = (obj as dynamic).getSafeListFor(ListKey.getConstant<String>('AUTO_WEAPONPROF')) as List;
      for (final p in wp) { if (p is String && p.isNotEmpty) info.weaponProfs.add(p); }
    } catch (_) {}
    // Recurse into AUTO_ABILITIES
    try {
      final auto = (obj as dynamic).getSafeListFor(ListKey.getConstant<String>('AUTO_ABILITIES')) as List;
      for (final name in auto) {
        if (name is String && seen.add(name) && dataset != null) {
          final ability = dataset.findAbilityByName(name);
          if (ability != null) _collectRaceInfo(info, ability, dataset, seen);
        }
      }
    } catch (_) {}
  }

  // Keep for backward compat with _collectStatMods call sites
  void _collectStatMods(dynamic obj, DataSet? dataset, Map<String, int> out, Set<String> seen) {
    final info = _RaceInfo();
    _collectRaceInfo(info, obj, dataset, seen);
    out.addAll(info.statMods);
  }

  Widget _buildDetail(dynamic character, DataSet? dataset) {
    // Default to the character's current race if nothing is explicitly selected.
    Race? race = _selected;
    if (race == null && character != null) {
      try {
        final obj = (character as dynamic).getRaceRef()?.get();
        if (obj is Race) race = obj;
      } catch (_) {}
    }

    if (race == null) {
      return const Center(child: Text('Select a race from the list to see details.'));
    }

    bool isCurrentRace = false;
    if (character != null) {
      try {
        final currentRace = (character as dynamic).getRaceRef()?.get();
        isCurrentRace = currentRace != null && currentRace == race;
      } catch (_) {}
    }

    // ---- Read LST fields ----
    String desc = '';
    String sourceShort = '';
    String size = '';
    String cr = '';
    String favoredClass = '';
    int levelAdj = 0;
    int reach = 5;
    List<String> types = [];
    List<String> moveSpeeds = [];
    final info = _RaceInfo();

    try {
      desc = race.getString(StringKey.description) ?? '';
      sourceShort = race.getString(StringKey.sourceShort) ??
                    race.getString(StringKey.sourceLong) ?? '';
      size = race.getSafeObject(CDOMObjectKey.getConstant<String>('RACE_SIZE')) ?? '';
      if (size.isEmpty) size = race.getString(StringKey.sizeformula) ?? '';
      cr   = race.getString(StringKey.subregion) ?? '';
      favoredClass = race.getString(StringKey.abbreviation) ?? '';
      levelAdj = (race.getSafeObject(CDOMObjectKey.getConstant<int>('LEVEL_ADJUSTMENT')) as int?) ?? 0;
      reach    = (race.getSafeObject(CDOMObjectKey.getConstant<int>('REACH')) as int?) ?? 5;

      final typeList = race.getSafeListFor(ListKey.getConstant<String>('TYPE'));
      types = typeList.cast<String>()
          .where((t) => !t.startsWith('RACETYPE:') && !t.startsWith('RACESUBTYPE:'))
          .toList();

      final speeds = race.getSafeListFor(ListKey.getConstant<String>('MOVE_SPEEDS'));
      moveSpeeds = speeds.cast<String>();
      if (moveSpeeds.isEmpty) {
        final raw = race.getString(StringKey.tempvalue) ?? '';
        if (raw.isNotEmpty) {
          final parts = raw.split(',');
          for (int i = 0; i + 1 < parts.length; i += 2) {
            moveSpeeds.add('${parts[i].trim()}:${parts[i+1].trim()}');
          }
        }
      }

      // Vision on race object itself
      final vis = race.getSafeListFor(ListKey.getConstant<String>('VISION_TYPES'));
      for (final v in vis) { if (v is String) info.vision.add(v); }

      // Natural attacks on race object
      final nat = race.getSafeListFor(ListKey.getConstant<String>('NATURAL_ATTACKS'));
      for (final a in nat) { if (a is String) info.naturalAttacks.add(a); }

      // Walk full AUTO_ABILITIES chain for everything else
      _collectRaceInfo(info, race, dataset, {});
    } catch (_) {}

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + current-race badge
          Row(children: [
            Expanded(child: Text(race.getDisplayName(),
                style: Theme.of(context).textTheme.titleMedium)),
            if (isCurrentRace)
              Chip(
                label: const Text('Current Race', style: TextStyle(fontSize: 11)),
                backgroundColor: Colors.green.shade100,
                padding: EdgeInsets.zero,
              ),
          ]),
          const SizedBox(height: 8),

          // Ability score mods
          if (info.statMods.isNotEmpty) ...[
            Text('Ability Score Modifiers',
                style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8, runSpacing: 4,
              children: info.statMods.entries.map((e) {
                final sign = e.value >= 0 ? '+' : '';
                final pos  = e.value > 0;
                return Chip(
                  label: Text('${e.key} $sign${e.value}',
                      style: TextStyle(fontSize: 12,
                          color: pos ? Colors.blue.shade700 : Colors.red.shade700,
                          fontWeight: FontWeight.bold)),
                  backgroundColor: pos ? Colors.blue.shade50 : Colors.red.shade50,
                  padding: EdgeInsets.zero,
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
          ] else ...[
            Text('No ability score modifiers.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic)),
            const SizedBox(height: 8),
          ],

          // Core stats
          if (size.isNotEmpty) _row('Size', size),
          if (moveSpeeds.isNotEmpty)
            _row('Speed', moveSpeeds.map((s) {
              final c = s.indexOf(':');
              return c > 0 ? '${s.substring(0, c)} ${s.substring(c+1)} ft.' : s;
            }).join(', ')),
          if (reach != 5) _row('Reach', '$reach ft.'),
          if (cr.isNotEmpty)      _row('CR', cr),
          if (levelAdj != 0)      _row('LA', '+$levelAdj'),
          if (favoredClass.isNotEmpty) _row('Favored Class', favoredClass),
          if (sourceShort.isNotEmpty)  _row('Source', sourceShort),
          if (types.isNotEmpty)        _row('Types', types.join(', ')),

          // Vision
          if (info.vision.isNotEmpty) ...[
            const SizedBox(height: 6),
            _sectionLabel(context, 'Senses'),
            _bullet(info.vision.toSet().join(', ')),
          ],

          // Natural attacks
          if (info.naturalAttacks.isNotEmpty) ...[
            const SizedBox(height: 6),
            _sectionLabel(context, 'Natural Attacks'),
            ...info.naturalAttacks.toSet().map((a) {
              final parts = a.split(':');
              if (parts.length >= 3) {
                return _bullet('${parts[0]} ×${parts[1]} (${parts[2]})');
              }
              return _bullet(a);
            }),
          ],

          // Languages
          if (info.autoLang.isNotEmpty || info.bonusLang.isNotEmpty) ...[
            const SizedBox(height: 6),
            _sectionLabel(context, 'Languages'),
            if (info.autoLang.isNotEmpty)
              _bullet('Automatic: ${info.autoLang.toSet().join(', ')}'),
            if (info.bonusLang.isNotEmpty)
              _bullet('Bonus: ${info.bonusLang.toSet().join(', ')}'),
          ],

          // Weapon proficiencies
          if (info.weaponProfs.isNotEmpty) ...[
            const SizedBox(height: 6),
            _sectionLabel(context, 'Weapon Proficiencies'),
            _bullet(info.weaponProfs.toSet().join(', ')),
          ],

          // Skill bonuses
          if (info.skillBonuses.isNotEmpty) ...[
            const SizedBox(height: 6),
            _sectionLabel(context, 'Racial Skill Bonuses'),
            ...info.skillBonuses.toSet().map(_bullet),
          ],

          // Special abilities
          if (info.specialAbilities.isNotEmpty) ...[
            const SizedBox(height: 6),
            _sectionLabel(context, 'Special Qualities'),
            ...info.specialAbilities.toSet().map((s) => _bullet(s)),
          ],

          // Description
          if (desc.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(desc, style: Theme.of(context).textTheme.bodySmall),
          ],
          const SizedBox(height: 16),

          // Select / already-selected button
          if (character != null)
            ElevatedButton.icon(
              icon: isCurrentRace ? const Icon(Icons.check) : const Icon(Icons.person),
              label: Text(isCurrentRace ? 'Current Race' : 'Select for Character'),
              style: isCurrentRace
                  ? ElevatedButton.styleFrom(backgroundColor: Colors.green.shade100)
                  : null,
              onPressed: isCurrentRace ? null : () {
                try {
                  (character as dynamic).setRace(race!);
                  currentCharacter.notifyListeners();
                  setState(() {});
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error setting race: $e')));
                }
              },
            )
          else
            const Text('Create a character to assign a race.',
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
              width: 110,
              child: Text('$label:',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
        ]),
      );

  Widget _sectionLabel(BuildContext context, String label) => Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Text(label, style: Theme.of(context).textTheme.labelMedium),
      );

  Widget _bullet(String text) => Padding(
        padding: const EdgeInsets.only(left: 8, bottom: 2),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('• ', style: TextStyle(fontSize: 12)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
        ]),
      );
}

/// Accumulated race information collected from the race + its ability chain.
class _RaceInfo {
  final statMods      = <String, int>{};
  final vision        = <String>[];
  final autoLang      = <String>[];
  final bonusLang     = <String>[];
  final naturalAttacks = <String>[];
  final weaponProfs   = <String>[];
  final skillBonuses  = <String>[];
  final specialAbilities = <String>[];
}
