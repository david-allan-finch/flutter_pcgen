// Translation of pcgen.gui2.tabs.SpellsInfoTab

import 'package:flutter/material.dart';
import 'package:flutter_pcgen/src/core/data_set.dart';
import 'package:flutter_pcgen/src/core/spell/spell.dart';
import 'package:flutter_pcgen/src/gui2/app_state.dart';

class SpellsInfoTab extends StatefulWidget {
  const SpellsInfoTab({super.key});

  @override
  State<SpellsInfoTab> createState() => SpellsInfoTabState();
}

class SpellsInfoTabState extends State<SpellsInfoTab>
    with SingleTickerProviderStateMixin {
  dynamic _character;
  late final TabController _tabController;
  Spell? _selected;
  final TextEditingController _search = TextEditingController();

  void setCharacter(dynamic character) => setState(() => _character = character);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DataSet?>(
      valueListenable: loadedDataSet,
      builder: (context, dataset, _) {
        return ValueListenableBuilder(
          valueListenable: currentCharacter,
          builder: (context, character, _) {
            // Spells come from the reference context via DataSet — for now
            // DataSet doesn't have a spells list, so we show a placeholder.
            // TODO: populate DataSet.spells from reference context once
            //       Spell is registered with getAllConstructed.
            return Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Known'),
                    Tab(text: 'Prepared'),
                    Tab(text: 'All Spells'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildKnownTab(character),
                      _buildPreparedTab(character),
                      _buildAllSpellsTab(character, dataset),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildKnownTab(dynamic character) {
    if (character == null) return const Center(child: Text('No character selected.'));
    final known = _getSpellList(character, 'knownSpells');
    if (known.isEmpty) {
      return const Center(
        child: Text('No known spells.\nAdd spells from the All Spells tab.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
      );
    }
    return _buildSpellListView(character, known, 'knownSpells', removable: true);
  }

  Widget _buildPreparedTab(dynamic character) {
    if (character == null) return const Center(child: Text('No character selected.'));
    final prepared = _getSpellList(character, 'preparedSpells');
    final known = _getSpellList(character, 'knownSpells');
    if (known.isEmpty) {
      return const Center(
          child: Text('Add spells to Known first.',
              style: TextStyle(color: Colors.grey)));
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text('Mark spells from your known list as prepared:',
              style: Theme.of(context).textTheme.bodySmall),
        ),
        Expanded(child: _buildSpellListView(character, known, 'preparedSpells',
            prepared: prepared, preparable: true)),
      ],
    );
  }

  Widget _buildAllSpellsTab(dynamic character, DataSet? dataset) {
    // We'll show a note that spell loading requires class selection.
    // If dataset has loaded spells, show them.
    final query = _search.text.trim().toLowerCase();
    // DataSet.spell list is not yet populated by SourceFileLoader for Spell type.
    // Show placeholder with search for future use.
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            controller: _search,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search spells… (select a class first)',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_stories, size: 48, color: Colors.grey),
                const SizedBox(height: 8),
                const Text('Spell list loading requires class levels.\n'
                    'Add a spellcasting class in the Class tab first.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                if (character != null)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Spell Manually'),
                    onPressed: () => _showAddSpellDialog(character),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpellListView(dynamic character, List<Map<String, dynamic>> spells,
      String listKey, {List<Map<String, dynamic>>? prepared, bool removable = false, bool preparable = false}) {
    return ListView.builder(
      itemCount: spells.length,
      itemBuilder: (context, i) {
        final spell = spells[i];
        final name = spell['name'] as String? ?? 'Unknown';
        final level = spell['level'] as int? ?? 0;
        final isPrepared = prepared?.any((p) => p['name'] == name) ?? false;

        return ListTile(
          dense: true,
          leading: CircleAvatar(
            radius: 12,
            child: Text('$level', style: const TextStyle(fontSize: 10)),
          ),
          title: Text(name, style: const TextStyle(fontSize: 12)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (preparable)
                Checkbox(
                  value: isPrepared,
                  onChanged: (v) {
                    if (v == true) {
                      _addToList(character, 'preparedSpells', spell);
                    } else {
                      _removeFromList(character, 'preparedSpells', name);
                    }
                  },
                ),
              if (removable)
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, size: 16, color: Colors.red),
                  onPressed: () => _removeFromList(character, listKey, name),
                ),
            ],
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _getSpellList(dynamic character, String key) {
    try {
      final data = (character as dynamic).toJson() as Map<String, dynamic>;
      final list = data[key];
      if (list is List) return list.cast<Map<String, dynamic>>();
    } catch (_) {}
    return [];
  }

  void _addToList(dynamic character, String key, Map<String, dynamic> spell) {
    try {
      final data = (character as dynamic).toJson() as Map<String, dynamic>;
      final list = (data[key] ??= <Map<String, dynamic>>[]) as List;
      if (!list.any((s) => s['name'] == spell['name'])) {
        list.add(spell);
        currentCharacter.notifyListeners();
        setState(() {});
      }
    } catch (_) {}
  }

  void _removeFromList(dynamic character, String key, String name) {
    try {
      final data = (character as dynamic).toJson() as Map<String, dynamic>;
      final list = data[key] as List?;
      if (list != null) {
        list.removeWhere((s) => s['name'] == name);
        currentCharacter.notifyListeners();
        setState(() {});
      }
    } catch (_) {}
  }

  void _showAddSpellDialog(dynamic character) {
    final nameController = TextEditingController();
    int level = 0;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setS) => AlertDialog(
          title: const Text('Add Spell'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Spell name',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              Row(children: [
                const Text('Level: '),
                DropdownButton<int>(
                  value: level,
                  items: List.generate(10, (i) =>
                      DropdownMenuItem(value: i, child: Text('$i'))),
                  onChanged: (v) => setS(() => level = v ?? 0),
                ),
              ]),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  _addToList(character, 'knownSpells',
                      {'name': nameController.text, 'level': level});
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
