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

  Widget _buildList(List<Race> races) {
    final query = _search.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? races
        : races.where((r) => r.getDisplayName().toLowerCase().contains(query)).toList();

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
            child: Text('${filtered.length} races',
                style: Theme.of(context).textTheme.bodySmall),
          ),
        ),
        Expanded(
          child: races.isEmpty
              ? const Center(child: Text('No races loaded.'))
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final race = filtered[i];
                    final isSelected = _selected == race;
                    return ListTile(
                      dense: true,
                      selected: isSelected,
                      title: Text(race.getDisplayName()),
                      onTap: () => setState(() => _selected = race),
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
    List<String> types = [];
    try {
      desc = race.getString(StringKey.description) ?? '';
      sourceShort = race.getString(StringKey.sourceShort) ??
                    race.getString(StringKey.sourceLong) ?? '';
      final typeList = race.getSafeListFor(ListKey.getConstant<String>('TYPE'));
      types = typeList.cast<String>();
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
