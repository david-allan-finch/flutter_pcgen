// Translation of pcgen.gui2.tabs.RaceInfoTab

import 'package:flutter/material.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/string_key.dart';
import 'package:flutter_pcgen/src/core/data_set.dart';
import 'package:flutter_pcgen/src/core/race.dart';
import 'package:flutter_pcgen/src/gui2/app_state.dart';

/// Tab for browsing and selecting a character's race.
class RaceInfoTab extends StatefulWidget {
  const RaceInfoTab({super.key});

  @override
  State<RaceInfoTab> createState() => RaceInfoTabState();
}

class RaceInfoTabState extends State<RaceInfoTab> {
  dynamic _character;
  Race? _selected;
  final TextEditingController _search = TextEditingController();

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

  Widget _buildList(List<Race> races) {
    final query = _search.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? races
        : races.where((r) => r.getDisplayName().toLowerCase().contains(query)).toList();

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
    final race = _selected;
    if (race == null) {
      return const Center(child: Text('Select a race to see details.'));
    }

    bool isCurrentRace = false;
    if (character != null) {
      try {
        final raceRef = (character as dynamic).getRaceRef();
        final currentRace = raceRef?.get();
        isCurrentRace = currentRace != null && currentRace == race;
      } catch (_) {}
    }

    // Pull extra fields stored during token parsing.
    String desc = '';
    String sourceShort = '';
    String size = '';
    String move = '';
    String cr = '';
    List<String> types = [];
    try {
      desc = race.getString(StringKey.description) ?? '';
      sourceShort = race.getString(StringKey.sourceShort) ??
                    race.getString(StringKey.sourceLong) ?? '';
      size = race.getString(StringKey.sizeformula) ?? '';
      move = race.getString(StringKey.tempvalue) ?? '';
      cr   = race.getString(StringKey.subregion) ?? '';
      final typeList = race.getSafeListFor(ListKey.getConstant<String>('TYPE'));
      types = typeList.cast<String>()
          .where((t) => !t.startsWith('RACETYPE:') && !t.startsWith('RACESUBTYPE:'))
          .toList();
    } catch (_) {}

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(race.getDisplayName(),
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              if (isCurrentRace)
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          _row('Key', race.getKeyName()),
          if (size.isNotEmpty) _row('Size', size),
          if (move.isNotEmpty) _row('Speed', _formatMove(move)),
          if (cr.isNotEmpty) _row('CR', cr),
          if (sourceShort.isNotEmpty) _row('Source', sourceShort),
          if (types.isNotEmpty) _row('Types', types.join(', ')),
          if (desc.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(desc, style: Theme.of(context).textTheme.bodySmall),
          ],
          const SizedBox(height: 16),
          if (character != null)
            ElevatedButton.icon(
              icon: isCurrentRace
                  ? const Icon(Icons.check)
                  : const Icon(Icons.person),
              label: Text(isCurrentRace ? 'Selected Race' : 'Select for Character'),
              style: isCurrentRace
                  ? ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade100,
                    )
                  : null,
              onPressed: isCurrentRace
                  ? null
                  : () {
                      try {
                        (character as dynamic).setRace(race);
                        currentCharacter.notifyListeners();
                        setState(() {});
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error setting race: $e')),
                        );
                      }
                    },
            )
          else
            const Text(
              'Create a character to assign a race.',
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  String _formatMove(String raw) {
    // MOVE:Walk,30 → "Walk 30 ft."
    final parts = raw.split(',');
    if (parts.length == 2) return '${parts[0]} ${parts[1]} ft.';
    return raw;
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
