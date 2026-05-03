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
                Expanded(child: _buildDetail(character)),
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

  Widget _buildDetail(dynamic character) {
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
    List<String> types = [];
    List<String> moveSpeeds = [];
    final statMods = <String, int>{}; // e.g. {'STR': 2, 'INT': -2}

    try {
      desc = race.getString(StringKey.description) ?? '';
      sourceShort = race.getString(StringKey.sourceShort) ??
                    race.getString(StringKey.sourceLong) ?? '';
      // SIZE stored as CDOMObjectKey 'RACE_SIZE'
      size = race.getSafeObject(CDOMObjectKey.getConstant<String>('RACE_SIZE')) ?? '';
      // Fallback: legacy sizeformula key
      if (size.isEmpty) size = race.getString(StringKey.sizeformula) ?? '';
      cr = race.getString(StringKey.subregion) ?? '';

      final typeList = race.getSafeListFor(ListKey.getConstant<String>('TYPE'));
      types = typeList.cast<String>()
          .where((t) => !t.startsWith('RACETYPE:') && !t.startsWith('RACESUBTYPE:'))
          .toList();

      // MOVE stored as ListKey 'MOVE_SPEEDS' entries 'Type:speed'
      final speeds = race.getSafeListFor(ListKey.getConstant<String>('MOVE_SPEEDS'));
      moveSpeeds = speeds.cast<String>();
      // Fallback: legacy tempvalue
      if (moveSpeeds.isEmpty) {
        final raw = race.getString(StringKey.tempvalue) ?? '';
        if (raw.isNotEmpty) {
          final parts = raw.split(',');
          for (int i = 0; i + 1 < parts.length; i += 2) {
            moveSpeeds.add('${parts[i].trim()}:${parts[i+1].trim()}');
          }
        }
      }

      // Ability mods from BONUS:STAT entries in PARSED_BONUS
      final bonuses = race.getSafeListFor(ListKey.getConstant<ParsedBonus>('PARSED_BONUS'));
      for (final b in bonuses) {
        if (b is ParsedBonus && b.category == 'STAT') {
          final intVal = int.tryParse(b.formula);
          if (intVal != null) {
            for (final tgt in b.targets) {
              statMods[tgt.toUpperCase()] = (statMods[tgt.toUpperCase()] ?? 0) + intVal;
            }
          }
        }
      }
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

          // Ability score mods — most important info shown first
          if (statMods.isNotEmpty) ...[
            Text('Ability Score Modifiers',
                style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: statMods.entries.map((e) {
                final sign = e.value >= 0 ? '+' : '';
                final color = e.value > 0 ? Colors.blue.shade700 : Colors.red.shade700;
                return Chip(
                  label: Text('${e.key} $sign${e.value}',
                      style: TextStyle(fontSize: 12, color: color,
                          fontWeight: FontWeight.bold)),
                  backgroundColor: e.value > 0
                      ? Colors.blue.shade50 : Colors.red.shade50,
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

          if (size.isNotEmpty) _row('Size', size),
          if (moveSpeeds.isNotEmpty)
            _row('Speed', moveSpeeds.map((s) {
              final colon = s.indexOf(':');
              if (colon > 0) return '${s.substring(0, colon)} ${s.substring(colon+1)} ft.';
              return s;
            }).join(', ')),
          if (cr.isNotEmpty) _row('CR', cr),
          if (sourceShort.isNotEmpty) _row('Source', sourceShort),
          if (types.isNotEmpty) _row('Types', types.join(', ')),
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
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: [
          SizedBox(
              width: 80,
              child: Text('$label:',
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ]),
      );
}
