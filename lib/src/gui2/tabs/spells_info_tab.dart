// Translation of pcgen.gui2.tabs.SpellsInfoTab

import 'package:flutter/material.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/string_key.dart';
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
    final allSpells = dataset?.spells ?? const [];
    final query = _search.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? allSpells
        : allSpells
            .where((s) => s.getDisplayName().toLowerCase().contains(query))
            .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _search,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search spells…',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 8),
              if (character != null)
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text('Add Manually'),
                  onPressed: () => _showAddSpellDialog(character),
                ),
            ],
          ),
        ),
        if (allSpells.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('${filtered.length} of ${allSpells.length} spells',
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ),
          ),
        Expanded(
          child: allSpells.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_stories, size: 48, color: Colors.grey),
                      const SizedBox(height: 8),
                      const Text('No spells loaded.',
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
                )
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final spell = filtered[i];
                    String school = '';
                    String classes = '';
                    try { school = spell.getString(StringKey.genre) ?? ''; } catch (_) {}
                    try {
                      final raw = spell.getString(StringKey.campaignSetting) ?? '';
                      if (raw.isNotEmpty) {
                        final parts = raw.split('|').take(3).map((s) {
                          final eq = s.indexOf('=');
                          return eq > 0
                              ? '${s.substring(0, eq)} ${s.substring(eq + 1)}'
                              : s;
                        });
                        classes = parts.join(', ');
                      }
                    } catch (_) {}
                    return ListTile(
                      dense: true,
                      title: Text(spell.getDisplayName(),
                          style: const TextStyle(fontSize: 12)),
                      subtitle: (school.isNotEmpty || classes.isNotEmpty)
                          ? Text(
                              [if (school.isNotEmpty) school,
                               if (classes.isNotEmpty) classes].join(' • '),
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                              maxLines: 1, overflow: TextOverflow.ellipsis)
                          : null,
                      trailing: character == null
                          ? null
                          : TextButton(
                              child: const Text('Add to Known',
                                  style: TextStyle(fontSize: 11)),
                              onPressed: () {
                                _addToList(character, 'knownSpells', {
                                  'name': spell.getDisplayName(),
                                  'key': spell.getKeyName(),
                                  'level': 0,
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Added ${spell.getDisplayName()}'),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                    );
                  },
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
