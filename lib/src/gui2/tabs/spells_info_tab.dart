// Translation of pcgen.gui2.tabs.SpellsInfoTab

import 'package:flutter/material.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/string_key.dart';
import 'package:flutter_pcgen/src/core/data_set.dart';
import 'package:flutter_pcgen/src/core/pc_class.dart';
import 'package:flutter_pcgen/src/core/spell/spell.dart';
import 'package:flutter_pcgen/src/gui2/app_state.dart';

class SpellsInfoTab extends StatefulWidget {
  const SpellsInfoTab({super.key});

  @override
  State<SpellsInfoTab> createState() => SpellsInfoTabState();
}

class SpellsInfoTabState extends State<SpellsInfoTab>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _search = TextEditingController();
  String? _classFilter; // null = all classes

  void setCharacter(dynamic character) => setState(() {});

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
            return Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Known'),
                    Tab(text: 'Prepared'),
                    Tab(text: 'All Spells'),
                    Tab(text: 'Innate'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildKnownTab(character, dataset),
                      _buildPreparedTab(character),
                      _buildAllSpellsTab(character, dataset),
                      _buildInnateTab(character),
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

  // ---- Known tab -----------------------------------------------------------

  Widget _buildKnownTab(dynamic character, DataSet? dataset) {
    if (character == null) {
      return const Center(child: Text('No character selected.'));
    }
    final known = _getSpellList(character, 'knownSpells');

    return Column(
      children: [
        // Spell slots summary panel
        _buildSlotSummary(character, dataset),
        const Divider(height: 1),
        if (known.isEmpty)
          const Expanded(
            child: Center(
              child: Text(
                'No known spells.\nAdd spells from the All Spells tab.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ),
          )
        else
          Expanded(
            child: _buildSpellListView(character, known, 'knownSpells',
                removable: true),
          ),
      ],
    );
  }

  // ---- Spell slots summary -------------------------------------------------

  Widget _buildSlotSummary(dynamic character, DataSet? dataset) {
    final slotData = _computeSlotSummary(character, dataset);
    if (slotData.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8),
        child: Text('No spellcasting classes found.',
            style: TextStyle(color: Colors.grey, fontSize: 12)),
      );
    }

    return ExpansionTile(
      initiallyExpanded: true,
      title: const Text('Spell Slots Per Day',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      tilePadding: const EdgeInsets.symmetric(horizontal: 12),
      childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      children: slotData.map((entry) => _buildSlotRow(entry)).toList(),
    );
  }

  Widget _buildSlotRow(_ClassSlotEntry entry) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${entry.className} (${entry.spellStat})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 2),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (int sl = 0; sl < entry.slots.length; sl++)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Column(
                      children: [
                        Text('SL$sl',
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey)),
                        Container(
                          width: 28,
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(3),
                            color: entry.slots[sl] > 0
                                ? Colors.blue.shade50
                                : null,
                          ),
                          child: Text(
                            '${entry.slots[sl]}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: entry.slots[sl] > 0
                                  ? Colors.blue.shade700
                                  : Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<_ClassSlotEntry> _computeSlotSummary(
      dynamic character, DataSet? dataset) {
    if (character == null || dataset == null) return [];

    Map<String, dynamic> data = {};
    try { data = (character as dynamic).toJson() as Map<String, dynamic>; } catch (_) {}
    final classLevels = data['classLevels'] as List? ?? [];
    final statScores = data['statScores'] as Map? ?? {};

    // Count levels per class
    final counts = <String, int>{};
    for (final l in classLevels) {
      if (l is Map) {
        final k = l['classKey'] as String? ?? '';
        counts[k] = (counts[k] ?? 0) + 1;
      }
    }

    final result = <_ClassSlotEntry>[];
    for (final cls in dataset.classes) {
      final lvl = counts[cls.getKeyName()] ?? 0;
      if (lvl == 0) continue;
      if (!cls.hasSpells) continue;

      final baseSlots = cls.getSpellsPerDayAt(lvl);
      if (baseSlots.isEmpty) continue;

      // Bonus slots from spellcasting stat modifier
      final spellStat = cls.getSpellStat();
      final statScore = (statScores[spellStat] as num?)?.toInt() ?? 10;
      final statMod = ((statScore - 10) / 2).floor().clamp(0, 10);

      // 3.5e bonus slots: +1 slot per level up to the modifier
      final totalSlots = List<int>.from(baseSlots);
      for (int sl = 1; sl <= statMod && sl < totalSlots.length; sl++) {
        if (totalSlots[sl] > 0) totalSlots[sl]++;
      }

      result.add(_ClassSlotEntry(
        className: cls.getDisplayName(),
        spellStat: spellStat.isEmpty ? 'None' : spellStat,
        slots: totalSlots,
      ));
    }
    return result;
  }

  // ---- Prepared tab --------------------------------------------------------

  Widget _buildPreparedTab(dynamic character) {
    if (character == null) {
      return const Center(child: Text('No character selected.'));
    }
    final prepared = _getSpellList(character, 'preparedSpells');
    final known = _getSpellList(character, 'knownSpells');
    if (known.isEmpty) {
      return const Center(
        child: Text('Add spells to Known first.',
            style: TextStyle(color: Colors.grey)),
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text('Mark spells from your known list as prepared:',
              style: Theme.of(context).textTheme.bodySmall),
        ),
        Expanded(
          child: _buildSpellListView(character, known, 'preparedSpells',
              prepared: prepared, preparable: true),
        ),
      ],
    );
  }

  // ---- All Spells tab ------------------------------------------------------

  Widget _buildAllSpellsTab(dynamic character, DataSet? dataset) {
    final allSpells = dataset?.spells ?? const [];

    // Build list of character's spellcasting class names for filter
    final charClasses = _getCharacterSpellcastingClassNames(character, dataset);

    final query = _search.text.trim().toLowerCase();
    final filtered = allSpells.where((s) {
      // Text filter
      if (query.isNotEmpty &&
          !s.getDisplayName().toLowerCase().contains(query)) return false;
      // Class filter
      if (_classFilter != null && _classFilter!.isNotEmpty) {
        final classMap = _parseSpellClasses(s);
        if (!classMap.containsKey(_classFilter)) return false;
      }
      return true;
    }).toList();

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
              if (charClasses.isNotEmpty) ...[
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _classFilter,
                  hint: const Text('Class', style: TextStyle(fontSize: 12)),
                  isDense: true,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All')),
                    ...charClasses.map((c) =>
                        DropdownMenuItem(value: c, child: Text(c))),
                  ],
                  onChanged: (v) => setState(() => _classFilter = v),
                ),
              ],
              const SizedBox(width: 8),
              if (character != null)
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text('Manual'),
                  onPressed: () => _showAddSpellDialog(character),
                ),
            ],
          ),
        ),
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
                    final school = spell.getString(StringKey.genre) ?? '';
                    final classMap = _parseSpellClasses(spell);
                    // Show level for the filtered class, or lowest level
                    final displayLevel = _classFilter != null &&
                            classMap.containsKey(_classFilter)
                        ? classMap[_classFilter]!
                        : (classMap.values.isNotEmpty
                            ? (classMap.values.reduce((a, b) => a < b ? a : b))
                            : 0);
                    final classStr = classMap.entries
                        .map((e) => '${e.key} ${e.value}')
                        .take(4)
                        .join(', ');

                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.blue.shade100,
                        child: Text('$displayLevel',
                            style: const TextStyle(fontSize: 10)),
                      ),
                      title: Text(spell.getDisplayName(),
                          style: const TextStyle(fontSize: 12)),
                      subtitle: (school.isNotEmpty || classStr.isNotEmpty)
                          ? Text(
                              [
                                if (school.isNotEmpty) school,
                                if (classStr.isNotEmpty) classStr,
                              ].join(' • '),
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.grey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis)
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
                                  'level': displayLevel,
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Added ${spell.getDisplayName()}'),
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

  // ---- Helpers -------------------------------------------------------------

  /// Parse the CLASSES: token value into a map of className→spellLevel.
  Map<String, int> _parseSpellClasses(Spell spell) {
    String raw = '';
    try { raw = spell.getString(StringKey.campaignSetting) ?? ''; } catch (_) {}
    if (raw.isEmpty) return {};
    final result = <String, int>{};
    for (final part in raw.split('|')) {
      final eq = part.indexOf('=');
      if (eq > 0) {
        final cls = part.substring(0, eq).trim();
        final lvl = int.tryParse(part.substring(eq + 1).trim()) ?? 0;
        if (cls.isNotEmpty) result[cls] = lvl;
      }
    }
    return result;
  }

  List<String> _getCharacterSpellcastingClassNames(
      dynamic character, DataSet? dataset) {
    if (character == null || dataset == null) return [];
    Map<String, dynamic> data = {};
    try { data = (character as dynamic).toJson() as Map<String, dynamic>; } catch (_) {}
    final classLevels = data['classLevels'] as List? ?? [];
    final charClassKeys = <String>{};
    for (final l in classLevels) {
      if (l is Map) charClassKeys.add(l['classKey'] as String? ?? '');
    }
    return dataset.classes
        .where((c) =>
            charClassKeys.contains(c.getKeyName()) && c.hasSpells)
        .map((c) => c.getDisplayName())
        .toList();
  }

  Widget _buildSpellListView(
    dynamic character,
    List<Map<String, dynamic>> spells,
    String listKey, {
    List<Map<String, dynamic>>? prepared,
    bool removable = false,
    bool preparable = false,
  }) {
    return ListView.builder(
      itemCount: spells.length,
      itemBuilder: (context, i) {
        final spell = spells[i];
        final name = spell['name'] as String? ?? 'Unknown';
        final level = spell['level'] as int? ?? 0;
        final isPrepared = prepared?.any((p) => p['name'] == name) ?? false;

        // Compute spell DC for known spells
        int dc = 0;
        try {
          dc = (character as dynamic).getSpellSaveDC(level) as int? ?? 0;
        } catch (_) {}

        return ListTile(
          dense: true,
          leading: CircleAvatar(
            radius: 12,
            child: Text('$level', style: const TextStyle(fontSize: 10)),
          ),
          title: Text(name, style: const TextStyle(fontSize: 12)),
          subtitle: dc > 0
              ? Text('DC $dc', style: const TextStyle(fontSize: 10, color: Colors.grey))
              : null,
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
                  icon: const Icon(Icons.remove_circle_outline,
                      size: 16, color: Colors.red),
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

  void _addToList(
      dynamic character, String key, Map<String, dynamic> spell) {
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
          title: const Text('Add Spell Manually'),
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
                  items: List.generate(10,
                      (i) => DropdownMenuItem(value: i, child: Text('$i'))),
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

  // ---- Innate spells tab ---------------------------------------------------

  Widget _buildInnateTab(dynamic character) {
    final entries = <_InnateEntry>[];
    try {
      final raw = (character as dynamic).getInnateSpells() as List<String>? ?? [];
      for (final line in raw) {
        final parts = line.split('|');
        if (parts.isEmpty) continue;
        // parts[0] = list name (e.g. "Innate")
        // remaining: TIMES=N, CASTERLEVEL=N, SpellName,DC, ...
        String times = '—';
        String cl = '—';
        final spells = <String>[];
        for (int i = 1; i < parts.length; i++) {
          final p = parts[i].trim();
          if (p.startsWith('TIMES=')) {
            times = p.substring(6);
          } else if (p.startsWith('CASTERLEVEL=')) {
            cl = p.substring(12);
          } else if (p.isNotEmpty) {
            // SpellName,DC  — strip DC
            final spellName = p.split(',').first.trim();
            if (spellName.isNotEmpty) spells.add(spellName);
          }
        }
        for (final spell in spells) {
          entries.add(_InnateEntry(spell: spell, timesPerDay: times, cl: cl));
        }
      }
    } catch (_) {}

    if (character == null) {
      return const Center(child: Text('No character selected.'));
    }
    if (entries.isEmpty) {
      return const Center(child: Text('No innate spells.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: entries.length,
      itemBuilder: (context, i) {
        final e = entries[i];
        return ListTile(
          dense: true,
          title: Text(e.spell, style: const TextStyle(fontSize: 13)),
          subtitle: Text('${e.timesPerDay}/day   CL ${e.cl}',
              style: const TextStyle(fontSize: 11)),
          leading: const Icon(Icons.auto_fix_high, size: 16),
        );
      },
    );
  }
}

class _InnateEntry {
  final String spell, timesPerDay, cl;
  const _InnateEntry({required this.spell, required this.timesPerDay, required this.cl});
}

// ---------------------------------------------------------------------------

class _ClassSlotEntry {
  final String className;
  final String spellStat;
  final List<int> slots;
  const _ClassSlotEntry(
      {required this.className, required this.spellStat, required this.slots});
}
