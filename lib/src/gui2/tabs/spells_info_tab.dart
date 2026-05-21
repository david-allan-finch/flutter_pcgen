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
  bool _myClassOnly = false; // filter All Spells to character's class lists

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

    // Group known spells by class then level.
    // First determine the character's spellcasting classes in level order.
    final charSpellClasses = _getCharacterSpellcastingClassNames(character, dataset);

    // Build: Map<className, Map<level, List<Map>>>
    final byClassLevel = <String, Map<int, List<Map<String, dynamic>>>>{};

    for (final sp in known) {
      final name  = sp['name'] as String? ?? '';
      final level = (sp['level'] as num?)?.toInt() ?? 0;

      // Find which of the character's classes knows this spell
      String spellClass = 'Other';
      if (dataset != null) {
        final dsSpell = dataset.spells
            .cast<dynamic>()
            .where((s) => (s.getDisplayName() as String).toLowerCase() == name.toLowerCase())
            .firstOrNull;
        if (dsSpell != null) {
          final classMap = _parseSpellClasses(dsSpell as Spell);
          // Prefer a class the character actually has
          for (final cls in charSpellClasses) {
            if (classMap.containsKey(cls)) { spellClass = cls; break; }
          }
          // Fall back to any class in the map
          if (spellClass == 'Other' && classMap.isNotEmpty) {
            spellClass = classMap.keys.first;
          }
        }
      }

      ((byClassLevel[spellClass] ??= {})[level] ??= []).add(sp);
    }

    // Sort classes: character's classes first, then others alphabetically
    final sortedClasses = [
      ...charSpellClasses.where(byClassLevel.containsKey),
      ...byClassLevel.keys
          .where((k) => !charSpellClasses.contains(k))
          .toList()..sort(),
    ];

    return Column(
      children: [
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
            child: ListView(
              children: [
                for (final cls in sortedClasses) ...[
                  _buildKnownClassNode(character, dataset, cls, byClassLevel[cls]!),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildKnownClassNode(
    dynamic character,
    DataSet? dataset,
    String className,
    Map<int, List<Map<String, dynamic>>> byLevel,
  ) {
    final totalCount = byLevel.values.fold(0, (s, l) => s + l.length);
    final levels = byLevel.keys.toList()..sort();

    return ExpansionTile(
      initiallyExpanded: true,
      tilePadding: const EdgeInsets.symmetric(horizontal: 12),
      title: Row(children: [
        Icon(Icons.auto_stories, size: 14, color: Colors.blue.shade700),
        const SizedBox(width: 6),
        Text(className,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(width: 8),
        Text('($totalCount)',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
      ]),
      children: [
        for (final lvl in levels)
          _buildKnownLevelNode(character, dataset, className, lvl, byLevel[lvl]!),
      ],
    );
  }

  Widget _buildKnownLevelNode(
    dynamic character,
    DataSet? dataset,
    String className,
    int level,
    List<Map<String, dynamic>> spells,
  ) {
    final levelLabel = level == 0 ? 'Cantrips / Orisons' : 'Level $level';
    return ExpansionTile(
      initiallyExpanded: true,
      tilePadding: const EdgeInsets.only(left: 28, right: 12),
      title: Text(levelLabel,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade800)),
      children: spells.map((sp) {
        final name = sp['name'] as String? ?? '';
        int dc = 0;
        try { dc = (character as dynamic).getSpellSaveDC(level) as int? ?? 0; } catch (_) {}
        final dsSpell = dataset?.spells
            .cast<dynamic>()
            .where((s) => (s.getDisplayName() as String).toLowerCase() == name.toLowerCase())
            .firstOrNull;
        return ListTile(
          dense: true,
          contentPadding: const EdgeInsets.only(left: 48, right: 8),
          leading: CircleAvatar(
            radius: 10,
            backgroundColor: Colors.blue.shade100,
            child: Text('$level', style: const TextStyle(fontSize: 9)),
          ),
          title: Text(name, style: const TextStyle(fontSize: 12)),
          subtitle: dc > 0
              ? Text('DC $dc',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600))
              : null,
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            if (dsSpell != null)
              IconButton(
                icon: Icon(Icons.info_outline,
                    size: 16, color: Colors.blue.shade400),
                tooltip: 'Spell details',
                onPressed: () => _showSpellDetail(context, dsSpell),
              ),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline,
                  size: 16, color: Colors.red),
              tooltip: 'Remove',
              onPressed: () =>
                  _removeFromList(character, 'knownSpells', name),
            ),
          ]),
          onTap: dsSpell != null
              ? () => _showSpellDetail(context, dsSpell)
              : null,
        );
      }).toList(),
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
          Row(children: [
            Text('${entry.className} (${entry.spellStat})',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(width: 12),
            Text('CL ${entry.casterLevel}',
                style: TextStyle(fontSize: 11, color: Colors.blue.shade700)),
            const SizedBox(width: 8),
            Text('DC ${entry.baseDc}+SL',
                style: TextStyle(fontSize: 11, color: Colors.purple.shade700)),
          ]),
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

      // Effective caster level (class level + any BONUS:CASTERLEVEL bonuses)
      int cl = lvl;
      try {
        final bonusCl = (character as dynamic).getCasterLevel(cls.getDisplayName()) as int?;
        if (bonusCl != null && bonusCl > 0) cl = bonusCl;
      } catch (_) {}

      // Base spell save DC = 10 + spellStat mod (spell level added at display time)
      final baseDc = 10 + statMod;

      result.add(_ClassSlotEntry(
        className: cls.getDisplayName(),
        spellStat: spellStat.isEmpty ? 'None' : spellStat,
        slots: totalSlots,
        casterLevel: cl,
        baseDc: baseDc,
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

  // ---- All Spells tab (tree: class → level → spell) ------------------------

  Widget _buildAllSpellsTab(dynamic character, DataSet? dataset) {
    final allSpells = dataset?.spells ?? const [];
    final charClasses = _getCharacterSpellcastingClassNames(character, dataset);
    final myClassNames = charClasses.map((c) => c.toLowerCase()).toSet();
    final query = _search.text.trim().toLowerCase();
    final knownNames = character != null
        ? _getSpellList(character, 'knownSpells')
            .map((s) => (s['name'] as String? ?? '').toLowerCase())
            .toSet()
        : const <String>{};

    if (allSpells.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.auto_stories, size: 48, color: Colors.grey),
          const SizedBox(height: 8),
          const Text('No spells loaded.', style: TextStyle(color: Colors.grey)),
          if (character != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Spell Manually'),
              onPressed: () => _showAddSpellDialog(character),
            ),
          ],
        ]),
      );
    }

    // Build tree: Map<className, Map<level, List<Spell>>>
    // Apply class + search filters while building
    final tree = <String, Map<int, List<Spell>>>{};
    int totalMatches = 0;

    for (final spell in allSpells) {
      final name = spell.getDisplayName();
      if (query.isNotEmpty && !name.toLowerCase().contains(query)) continue;

      final classMap = _parseSpellClasses(spell);
      if (classMap.isEmpty) continue;

      for (final entry in classMap.entries) {
        final cls = entry.key;
        final lvl = entry.value;

        // "My classes" filter
        if (_myClassOnly && myClassNames.isNotEmpty &&
            !myClassNames.contains(cls.toLowerCase())) continue;

        ((tree[cls] ??= {})[lvl] ??= []).add(spell);
      }
      totalMatches++;
    }

    // Sort class names: character's spellcasting classes first, then alpha
    final sortedClasses = [
      ...charClasses.where(tree.containsKey),
      ...tree.keys
          .where((k) => !charClasses.contains(k))
          .toList()..sort(),
    ];

    return Column(
      children: [
        // Search + filters toolbar
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
          child: Row(children: [
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
              Row(mainAxisSize: MainAxisSize.min, children: [
                Checkbox(
                  value: _myClassOnly,
                  onChanged: (v) => setState(() => _myClassOnly = v ?? false),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                const Text('My classes', style: TextStyle(fontSize: 11)),
              ]),
            ],
            if (character != null) ...[
              const SizedBox(width: 4),
              TextButton.icon(
                icon: const Icon(Icons.add, size: 14),
                label: const Text('Manual'),
                onPressed: () => _showAddSpellDialog(character),
              ),
            ],
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '$totalMatches spells across ${sortedClasses.length} classes',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
        ),
        // Tree
        Expanded(
          child: tree.isEmpty
              ? const Center(
                  child: Text('No spells match.',
                      style: TextStyle(color: Colors.grey)))
              : ListView(
                  children: [
                    for (final cls in sortedClasses)
                      _buildClassNode(
                          character, cls, tree[cls]!, knownNames, myClassNames),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildClassNode(
    dynamic character,
    String className,
    Map<int, List<Spell>> byLevel,
    Set<String> knownNames,
    Set<String> myClassNames,
  ) {
    final isMyClass = myClassNames.contains(className.toLowerCase());
    final totalCount = byLevel.values.fold(0, (s, l) => s + l.length);
    final levels = byLevel.keys.toList()..sort();

    return ExpansionTile(
      initiallyExpanded: isMyClass,
      tilePadding: const EdgeInsets.symmetric(horizontal: 12),
      title: Row(children: [
        Icon(isMyClass ? Icons.school : Icons.menu_book,
            size: 14,
            color: isMyClass ? Colors.blue.shade700 : Colors.grey.shade600),
        const SizedBox(width: 6),
        Text(className,
            style: TextStyle(
                fontWeight:
                    isMyClass ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
                color: isMyClass ? null : Colors.grey.shade800)),
        const SizedBox(width: 8),
        Text('($totalCount)',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
      ]),
      children: [
        for (final lvl in levels)
          _buildLevelNode(
              character, className, lvl, byLevel[lvl]!, knownNames),
      ],
    );
  }

  Widget _buildLevelNode(
    dynamic character,
    String className,
    int level,
    List<Spell> spells,
    Set<String> knownNames,
  ) {
    final label = level == 0 ? 'Cantrips / Orisons' : 'Level $level';
    // Sort spells alphabetically within each level
    final sorted = List<Spell>.from(spells)
      ..sort((a, b) => a.getDisplayName().compareTo(b.getDisplayName()));

    return ExpansionTile(
      initiallyExpanded: level == 0,
      tilePadding: const EdgeInsets.only(left: 32, right: 12),
      title: Text('$label  (${spells.length})',
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.blue.shade700)),
      children: sorted.map((spell) {
        final name     = spell.getDisplayName();
        final school   = spell.getString(StringKey.genre) ?? '';
        final isKnown  = knownNames.contains(name.toLowerCase());
        final classMap = _parseSpellClasses(spell);
        // Build compact class list excluding the current class
        final otherClasses = classMap.entries
            .where((e) => e.key != className)
            .map((e) => '${e.key} ${e.value}')
            .take(3)
            .join(', ');

        return ListTile(
          dense: true,
          contentPadding: const EdgeInsets.only(left: 56, right: 8),
          leading: CircleAvatar(
            radius: 10,
            backgroundColor:
                isKnown ? Colors.green.shade100 : Colors.blue.shade50,
            child: Text('$level',
                style: TextStyle(
                    fontSize: 9,
                    color: isKnown
                        ? Colors.green.shade800
                        : Colors.blue.shade800)),
          ),
          title: Text(name,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      isKnown ? FontWeight.w600 : FontWeight.normal)),
          subtitle: (school.isNotEmpty || otherClasses.isNotEmpty)
              ? Text(
                  [
                    if (school.isNotEmpty) school,
                    if (otherClasses.isNotEmpty) otherClasses,
                  ].join(' • '),
                  style:
                      const TextStyle(fontSize: 10, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
          trailing: character == null
              ? null
              : isKnown
                  ? Icon(Icons.check_circle,
                      size: 16, color: Colors.green.shade600)
                  : TextButton(
                      style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 0),
                          minimumSize: Size.zero,
                          tapTargetSize:
                              MaterialTapTargetSize.shrinkWrap),
                      child: const Text('Add',
                          style: TextStyle(fontSize: 11)),
                      onPressed: () {
                        _addToList(character, 'knownSpells', {
                          'name':  name,
                          'key':   spell.getKeyName(),
                          'level': level,
                          'class': className,
                        });
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Added $name'),
                          duration: const Duration(seconds: 1),
                        ));
                      },
                    ),
          onTap: () => _showSpellDetail(context, spell),
        );
      }).toList(),
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

  // ---- Spell detail --------------------------------------------------------

  void _showSpellDetail(BuildContext context, dynamic spell) {
    String _s(StringKey k) {
      try { return (spell as dynamic).getString(k) as String? ?? ''; } catch (_) { return ''; }
    }

    final name       = (spell as dynamic).getDisplayName() as String? ?? '';
    final school     = _s(StringKey.genre);
    final subSchool  = _s(StringKey.setting);
    final descriptor = _s(StringKey.dataFormat);
    final components = _s(StringKey.spellComponents);
    final castTime   = _s(StringKey.duration);    // CASTTIME stored in duration key
    final duration   = _s(StringKey.help);        // DURATION stored in help key
    final range      = _s(StringKey.spellRange);
    final target     = _s(StringKey.targetArea);
    final saveInfo   = _s(StringKey.convertName);
    final desc       = _s(StringKey.description);
    final classesRaw = _s(StringKey.campaignSetting); // "ClassName=N|..."

    // Parse class levels
    final classEntries = <String>[];
    for (final part in classesRaw.split('|')) {
      final eq = part.indexOf('=');
      if (eq > 0) classEntries.add('${part.substring(0, eq)} ${part.substring(eq + 1)}');
    }

    final schoolLine = [school, if (subSchool.isNotEmpty) '($subSchool)',
        if (descriptor.isNotEmpty) '[$descriptor]'].join(' ');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Center(
              child: Container(width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 12),
            Text(name,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            if (schoolLine.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(schoolLine,
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic,
                        color: Colors.grey.shade700)),
              ),
            const Divider(height: 20),
            _spellRow('Classes',    classEntries.take(6).join(', ')),
            _spellRow('Components', components),
            _spellRow('Cast Time',  castTime),
            _spellRow('Range',      range),
            _spellRow('Target',     target),
            _spellRow('Duration',   duration),
            _spellRow('Save',       saveInfo),
            if (desc.isNotEmpty) ...[
              const Divider(height: 20),
              Text('Description',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700)),
              const SizedBox(height: 6),
              Text(desc, style: const TextStyle(fontSize: 13)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _spellRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 90,
          child: Text('$label:',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
      ]),
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
  final int casterLevel;
  final int baseDc;
  const _ClassSlotEntry({
    required this.className,
    required this.spellStat,
    required this.slots,
    this.casterLevel = 0,
    this.baseDc = 10,
  });
}
