// Translation of pcgen.gui2.tabs.SpellsInfoTab

import 'package:flutter/material.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/string_key.dart';
import 'package:flutter_pcgen/src/core/data_set.dart';
import 'package:flutter_pcgen/src/core/spell/spell.dart';
import 'package:flutter_pcgen/src/gui2/app_state.dart';

// ---------------------------------------------------------------------------
// Colours used to distinguish spell classes in the tree
// ---------------------------------------------------------------------------
const _kClassColors = [
  Colors.blue, Colors.purple, Colors.teal, Colors.orange,
  Colors.indigo, Colors.green, Colors.red, Colors.brown,
];

Color _classColor(int index) => _kClassColors[index % _kClassColors.length];

class SpellsInfoTab extends StatefulWidget {
  const SpellsInfoTab({super.key});

  @override
  State<SpellsInfoTab> createState() => SpellsInfoTabState();
}

class SpellsInfoTabState extends State<SpellsInfoTab>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _search = TextEditingController();
  bool _showOtherClasses = false;

  void setCharacter(dynamic character) => setState(() {});

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
            return Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Known'),
                    Tab(text: 'Available'),
                    Tab(text: 'Innate'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildKnownTab(character, dataset),
                      _buildAvailableTab(character, dataset),
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

  // ==========================================================================
  // Known tab — character's spells grouped by class then level
  // ==========================================================================

  Widget _buildKnownTab(dynamic character, DataSet? dataset) {
    if (character == null) {
      return const Center(child: Text('No character selected.'));
    }

    final charClasses = _charSpellclasses(character, dataset);
    final known = _getSpellList(character, 'knownSpells');

    // Build per-class spell map: className → level → spells
    // Use the 'class' field stored when the spell was added; fall back to
    // matching against the dataset spell class list.
    final byClass = <String, Map<int, List<Map<String, dynamic>>>>{};

    for (final sp in known) {
      final name  = sp['name'] as String? ?? '';
      final level = (sp['level'] as num?)?.toInt() ?? 0;
      String cls  = sp['class'] as String? ?? '';

      if (cls.isEmpty) {
        // Legacy entry without class field — match to first character class
        if (dataset != null) {
          final dsSpell = _findSpellInDataset(dataset, name);
          if (dsSpell != null) {
            final classMap = _parseSpellClasses(dsSpell);
            for (final cc in charClasses.map((c) => c.name)) {
              if (classMap.containsKey(cc)) { cls = cc; break; }
            }
          }
        }
        if (cls.isEmpty && charClasses.isNotEmpty) cls = charClasses.first.name;
        if (cls.isEmpty) cls = 'Other';
      }

      ((byClass[cls] ??= {})[level] ??= []).add(sp);
    }

    // Order: character's classes first (in class order), then others
    final ordered = <String>[
      ...charClasses.map((c) => c.name).where(byClass.containsKey),
      ...byClass.keys.where((k) => !charClasses.any((c) => c.name == k)).toList()..sort(),
    ];

    return Column(
      children: [
        _buildSlotSummary(character, dataset, charClasses),
        const Divider(height: 1),
        if (known.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_stories, size: 48, color: Colors.grey.shade300),
                  const SizedBox(height: 8),
                  const Text('No known spells.',
                      style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                  const SizedBox(height: 4),
                  const Text('Use the Available tab to add spells.',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView(
              children: [
                for (int ci = 0; ci < ordered.length; ci++)
                  _knownClassNode(
                    character, dataset, ordered[ci],
                    byClass[ordered[ci]]!,
                    _classColorFor(charClasses, ordered[ci], ci),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Color _classColorFor(List<_SpellClass> charClasses, String name, int fallbackIndex) {
    final idx = charClasses.indexWhere((c) => c.name == name);
    return idx >= 0 ? _classColor(idx) : Colors.grey;
  }

  Widget _knownClassNode(
    dynamic character,
    DataSet? dataset,
    String className,
    Map<int, List<Map<String, dynamic>>> byLevel,
    Color color,
  ) {
    final total = byLevel.values.fold(0, (s, l) => s + l.length);
    final levels = byLevel.keys.toList()..sort();

    return ExpansionTile(
      initiallyExpanded: true,
      tilePadding: const EdgeInsets.symmetric(horizontal: 12),
      title: Row(children: [
        Icon(Icons.auto_stories, size: 14, color: color),
        const SizedBox(width: 6),
        Text(className,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
        const SizedBox(width: 8),
        Text('($total spell${total == 1 ? '' : 's'})',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
      ]),
      children: [
        for (final lvl in levels)
          _knownLevelNode(character, dataset, className, lvl, byLevel[lvl]!, color),
      ],
    );
  }

  Widget _knownLevelNode(
    dynamic character,
    DataSet? dataset,
    String className,
    int level,
    List<Map<String, dynamic>> spells,
    Color color,
  ) {
    final label = level == 0 ? 'Cantrips / Orisons' : 'Level $level';
    return ExpansionTile(
      initiallyExpanded: true,
      tilePadding: const EdgeInsets.only(left: 32, right: 12),
      title: Text('$label  (${spells.length})',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
              color: color.withValues(alpha: 0.85))),
      children: spells.map((sp) {
        final name = sp['name'] as String? ?? '';
        int dc = 0;
        try { dc = (character as dynamic).getSpellSaveDC(level) as int? ?? 0; } catch (_) {}
        final dsSpell = _findSpellInDataset(dataset, name);
        return ListTile(
          dense: true,
          contentPadding: const EdgeInsets.only(left: 52, right: 8),
          leading: CircleAvatar(
            radius: 10,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Text('$level',
                style: TextStyle(fontSize: 9,
                    color: color, fontWeight: FontWeight.bold)),
          ),
          title: Text(name, style: const TextStyle(fontSize: 12)),
          subtitle: dc > 0
              ? Text('DC $dc',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600))
              : null,
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            if (dsSpell != null)
              IconButton(
                icon: Icon(Icons.info_outline, size: 16, color: color.withValues(alpha: 0.7)),
                tooltip: 'Spell details',
                onPressed: () => _showSpellDetail(context, dsSpell),
              ),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, size: 16, color: Colors.red),
              tooltip: 'Remove',
              onPressed: () => _removeFromList(character, 'knownSpells', name),
            ),
          ]),
          onTap: dsSpell != null ? () => _showSpellDetail(context, dsSpell) : null,
        );
      }).toList(),
    );
  }

  // ==========================================================================
  // Available tab — spells organised by the character's spellcasting classes
  // ==========================================================================

  Widget _buildAvailableTab(dynamic character, DataSet? dataset) {
    final allSpells = dataset?.spells ?? const [];
    final charClasses = _charSpellclasses(character, dataset);
    final query = _search.text.trim().toLowerCase();

    // Build per-class spell trees for the character's classes
    // Map<className, Map<level, List<Spell>>>
    final myTrees = <String, Map<int, List<Spell>>>{};
    // Remaining spells for other classes (only when _showOtherClasses)
    final otherTrees = <String, Map<int, List<Spell>>>{};

    final myClassNames = charClasses.map((c) => c.name).toSet();

    // Track which spells have already been placed into a char-class tree
    // so duplicates don't appear in 'other' classes
    final placedSpellKeys = <String>{};

    for (final spell in allSpells) {
      final spellName = spell.getDisplayName();
      if (query.isNotEmpty && !spellName.toLowerCase().contains(query)) continue;

      final classMap = _parseSpellClasses(spell);
      if (classMap.isEmpty) continue;

      bool placedInMine = false;
      for (final entry in classMap.entries) {
        final cls = entry.key;
        final lvl = entry.value;
        if (myClassNames.contains(cls)) {
          ((myTrees[cls] ??= {})[lvl] ??= []).add(spell);
          placedInMine = true;
          placedSpellKeys.add(spell.getKeyName());
        }
      }

      if (!placedInMine && _showOtherClasses) {
        for (final entry in classMap.entries) {
          ((otherTrees[entry.key] ??= {})[entry.value] ??= []).add(spell);
        }
      }
    }

    // Known spell names for checkmark display
    final knownNames = character != null
        ? <String, String>{}  // spellName → class it was added to
        : const <String, String>{};
    if (character != null) {
      for (final sp in _getSpellList(character, 'knownSpells')) {
        final n = (sp['name'] as String? ?? '').toLowerCase();
        final c = sp['class'] as String? ?? '';
        knownNames[n] = c;
      }
    }

    final otherClasses = otherTrees.keys.toList()..sort();

    if (allSpells.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.auto_stories, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 8),
          const Text('No spells loaded.', style: TextStyle(color: Colors.grey)),
          if (character != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Spell Manually'),
              onPressed: () => _showAddSpellDialog(character, charClasses),
            ),
          ],
        ]),
      );
    }

    return Column(
      children: [
        // Toolbar
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
            const SizedBox(width: 8),
            Row(mainAxisSize: MainAxisSize.min, children: [
              Checkbox(
                value: _showOtherClasses,
                onChanged: (v) => setState(() => _showOtherClasses = v ?? false),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
              const Text('Show all classes', style: TextStyle(fontSize: 11)),
            ]),
            if (character != null) ...[
              const SizedBox(width: 4),
              TextButton.icon(
                icon: const Icon(Icons.add, size: 14),
                label: const Text('Manual'),
                onPressed: () => _showAddSpellDialog(character, charClasses),
              ),
            ],
          ]),
        ),
        if (charClasses.isEmpty && character != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              'No spellcasting classes found for this character.',
              style: TextStyle(color: Colors.orange.shade700, fontSize: 12),
            ),
          ),
        // Tree
        Expanded(
          child: ListView(
            children: [
              // Character's classes — prominently shown
              for (int ci = 0; ci < charClasses.length; ci++)
                if (myTrees.containsKey(charClasses[ci].name))
                  _availableClassNode(
                    character, charClasses[ci].name, myTrees[charClasses[ci].name]!,
                    knownNames, _classColor(ci), isCharClass: true,
                  ),
              // Other classes — optional secondary section
              if (_showOtherClasses && otherTrees.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 4),
                  child: Text('Other Classes',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600)),
                ),
                for (final cls in otherClasses)
                  _availableClassNode(
                    character, cls, otherTrees[cls]!,
                    knownNames, Colors.grey, isCharClass: false,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _availableClassNode(
    dynamic character,
    String className,
    Map<int, List<Spell>> byLevel,
    Map<String, String> knownNames,
    Color color, {
    required bool isCharClass,
  }) {
    final total = byLevel.values.fold(0, (s, l) => s + l.length);
    final knownCount = byLevel.values.expand((l) => l)
        .where((s) => knownNames.containsKey(s.getDisplayName().toLowerCase()))
        .length;
    final levels = byLevel.keys.toList()..sort();

    return ExpansionTile(
      initiallyExpanded: isCharClass,
      tilePadding: const EdgeInsets.symmetric(horizontal: 12),
      title: Row(children: [
        Icon(isCharClass ? Icons.school : Icons.menu_book,
            size: 14, color: isCharClass ? color : Colors.grey.shade500),
        const SizedBox(width: 6),
        Text(className,
            style: TextStyle(
                fontWeight: isCharClass ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
                color: isCharClass ? color : Colors.grey.shade700)),
        const SizedBox(width: 8),
        Text('($total spells${knownCount > 0 ? ', $knownCount known' : ''})',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
      ]),
      children: [
        for (final lvl in levels)
          _availableLevelNode(character, className, lvl, byLevel[lvl]!,
              knownNames, color, isCharClass: isCharClass),
      ],
    );
  }

  Widget _availableLevelNode(
    dynamic character,
    String className,
    int level,
    List<Spell> spells,
    Map<String, String> knownNames,
    Color color, {
    required bool isCharClass,
  }) {
    final label = level == 0 ? 'Cantrips / Orisons' : 'Level $level';
    final known = spells.where((s) =>
        knownNames.containsKey(s.getDisplayName().toLowerCase())).length;
    final sorted = List<Spell>.from(spells)
      ..sort((a, b) => a.getDisplayName().compareTo(b.getDisplayName()));

    return ExpansionTile(
      initiallyExpanded: isCharClass && level <= 1,
      tilePadding: const EdgeInsets.only(left: 32, right: 12),
      title: Text(
        '$label  (${spells.length}${known > 0 ? ', $known known' : ''})',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
            color: isCharClass ? color.withValues(alpha: 0.85) : Colors.grey.shade600),
      ),
      children: sorted.map((spell) {
        final name       = spell.getDisplayName();
        final school     = spell.getString(StringKey.genre) ?? '';
        final lowerName  = name.toLowerCase();
        final isKnown    = knownNames.containsKey(lowerName);
        final knownClass = isKnown ? knownNames[lowerName] : null;
        final knownHere  = knownClass == className;

        return ListTile(
          dense: true,
          contentPadding: const EdgeInsets.only(left: 52, right: 8),
          leading: CircleAvatar(
            radius: 10,
            backgroundColor: isKnown
                ? (knownHere ? color.withValues(alpha: 0.2) : Colors.grey.shade200)
                : color.withValues(alpha: 0.08),
            child: Text('$level',
                style: TextStyle(
                    fontSize: 9,
                    color: isKnown ? (knownHere ? color : Colors.grey) : color,
                    fontWeight: FontWeight.bold)),
          ),
          title: Text(name,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: isKnown ? FontWeight.w600 : FontWeight.normal,
                  color: isKnown && !knownHere ? Colors.grey.shade500 : null)),
          subtitle: school.isNotEmpty
              ? Text(school,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                  maxLines: 1, overflow: TextOverflow.ellipsis)
              : null,
          trailing: character == null
              ? null
              : isKnown
                  ? Tooltip(
                      message: knownHere
                          ? 'Known as $className spell'
                          : 'Known as $knownClass spell',
                      child: Icon(Icons.check_circle,
                          size: 16,
                          color: knownHere ? color : Colors.grey.shade400),
                    )
                  : isCharClass
                      ? _addButton(character, className, spell, level, color)
                      : null,
          onTap: () => _showSpellDetail(context, spell),
        );
      }).toList(),
    );
  }

  Widget _addButton(
    dynamic character,
    String className,
    Spell spell,
    int level,
    Color color,
  ) {
    return TextButton(
      style: TextButton.styleFrom(
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap),
      child: const Text('+ Add', style: TextStyle(fontSize: 11)),
      onPressed: () {
        _addToList(character, 'knownSpells', {
          'name':  spell.getDisplayName(),
          'key':   spell.getKeyName(),
          'level': level,
          'class': className,
        });
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Added ${spell.getDisplayName()} to $className'),
          duration: const Duration(seconds: 1),
        ));
      },
    );
  }

  // ==========================================================================
  // Spell slots summary
  // ==========================================================================

  Widget _buildSlotSummary(
    dynamic character,
    DataSet? dataset,
    List<_SpellClass> charClasses,
  ) {
    if (charClasses.isEmpty) return const SizedBox.shrink();
    final slotData = _computeSlotSummary(character, dataset, charClasses);
    if (slotData.isEmpty) return const SizedBox.shrink();

    return ExpansionTile(
      initiallyExpanded: true,
      title: const Text('Spell Slots',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      tilePadding: const EdgeInsets.symmetric(horizontal: 12),
      childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      children: slotData.asMap().entries
          .map((e) => _buildSlotRow(e.value, _classColor(e.key)))
          .toList(),
    );
  }

  Widget _buildSlotRow(_ClassSlotEntry entry, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.auto_stories, size: 12, color: color),
          const SizedBox(width: 4),
          Text(entry.className,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: color)),
          const SizedBox(width: 8),
          Text('(${entry.spellStat})  CL ${entry.casterLevel}  base DC ${entry.baseDc}+SL',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        ]),
        const SizedBox(height: 2),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (int sl = 0; sl < entry.slots.length; sl++)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Column(children: [
                    Text('SL$sl',
                        style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    Container(
                      width: 26,
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: entry.slots[sl] > 0
                                  ? color.withValues(alpha: 0.4)
                                  : Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(3),
                          color: entry.slots[sl] > 0
                              ? color.withValues(alpha: 0.08)
                              : null),
                      child: Text('${entry.slots[sl]}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: entry.slots[sl] > 0
                                  ? color
                                  : Colors.grey.shade400)),
                    ),
                  ]),
                ),
            ],
          ),
        ),
      ]),
    );
  }

  List<_ClassSlotEntry> _computeSlotSummary(
    dynamic character,
    DataSet? dataset,
    List<_SpellClass> charClasses,
  ) {
    if (character == null || dataset == null) return [];
    Map<String, dynamic> data = {};
    try { data = (character as dynamic).toJson() as Map<String, dynamic>; } catch (_) {}
    final statScores = data['statScores'] as Map? ?? {};

    final result = <_ClassSlotEntry>[];
    for (final sc in charClasses) {
      final cls = dataset.classes.where((c) => c.getKeyName() == sc.key).firstOrNull;
      if (cls == null) continue;
      final baseSlots = cls.getSpellsPerDayAt(sc.level);
      if (baseSlots.isEmpty) continue;

      final spellStat = cls.getSpellStat();
      final statScore = (statScores[spellStat] as num?)?.toInt() ?? 10;
      final statMod   = ((statScore - 10) / 2).floor().clamp(0, 10);

      final totalSlots = List<int>.from(baseSlots);
      for (int sl = 1; sl <= statMod && sl < totalSlots.length; sl++) {
        if (totalSlots[sl] > 0) totalSlots[sl]++;
      }

      int cl = sc.level;
      try {
        final bonusCl = (character as dynamic).getCasterLevel(cls.getDisplayName()) as int?;
        if (bonusCl != null && bonusCl > 0) cl = bonusCl;
      } catch (_) {}

      result.add(_ClassSlotEntry(
        className:   cls.getDisplayName(),
        spellStat:   spellStat.isEmpty ? '—' : spellStat,
        slots:       totalSlots,
        casterLevel: cl,
        baseDc:      10 + statMod,
      ));
    }
    return result;
  }

  // ==========================================================================
  // Innate tab — racial / spell-like abilities
  // ==========================================================================

  Widget _buildInnateTab(dynamic character) {
    final entries = <_InnateEntry>[];
    try {
      final raw = (character as dynamic).getInnateSpells() as List<String>? ?? [];
      for (final line in raw) {
        final parts = line.split('|');
        if (parts.isEmpty) continue;
        String times = '—', cl = '—';
        final spells = <String>[];
        for (int i = 1; i < parts.length; i++) {
          final p = parts[i].trim();
          if (p.startsWith('TIMES=')) {
            times = p.substring(6);
          } else if (p.startsWith('CASTERLEVEL=')) {
            cl = p.substring(12);
          } else if (p.isNotEmpty) {
            final spellName = p.split(',').first.trim();
            if (spellName.isNotEmpty) spells.add(spellName);
          }
        }
        for (final spell in spells) {
          entries.add(_InnateEntry(spell: spell, timesPerDay: times, cl: cl));
        }
      }
    } catch (_) {}

    if (character == null) return const Center(child: Text('No character selected.'));
    if (entries.isEmpty) {
      return const Center(
        child: Text('No innate spells.',
            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: entries.length,
      itemBuilder: (context, i) {
        final e = entries[i];
        return ListTile(
          dense: true,
          leading: CircleAvatar(
            radius: 14,
            backgroundColor: Colors.purple.shade50,
            child: Icon(Icons.auto_fix_high, size: 14, color: Colors.purple.shade600),
          ),
          title: Text(e.spell, style: const TextStyle(fontSize: 13)),
          subtitle: Text('${e.timesPerDay}/day   CL ${e.cl}',
              style: const TextStyle(fontSize: 11)),
        );
      },
    );
  }

  // ==========================================================================
  // Helpers
  // ==========================================================================

  /// Returns the character's spellcasting classes with their levels and keys.
  List<_SpellClass> _charSpellclasses(dynamic character, DataSet? dataset) {
    if (character == null || dataset == null) return [];
    Map<String, dynamic> data = {};
    try { data = (character as dynamic).toJson() as Map<String, dynamic>; } catch (_) {}
    final classLevels = data['classLevels'] as List? ?? [];

    final counts = <String, int>{};
    for (final l in classLevels) {
      if (l is Map) {
        final k = l['classKey'] as String? ?? '';
        counts[k] = (counts[k] ?? 0) + 1;
      }
    }

    final result = <_SpellClass>[];
    for (final cls in dataset.classes) {
      final lvl = counts[cls.getKeyName()] ?? 0;
      if (lvl == 0 || !cls.hasSpells) continue;
      result.add(_SpellClass(
        key:   cls.getKeyName(),
        name:  cls.getDisplayName(),
        level: lvl,
      ));
    }
    return result;
  }

  Spell? _findSpellInDataset(DataSet? dataset, String name) {
    if (dataset == null) return null;
    final lower = name.toLowerCase();
    return dataset.spells
        .cast<Spell?>()
        .firstWhere(
            (s) => s?.getDisplayName().toLowerCase() == lower,
            orElse: () => null);
  }

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
      if (!list.any((s) => s['name'] == spell['name'] && s['class'] == spell['class'])) {
        list.add(spell);
        // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
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
        // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
        currentCharacter.notifyListeners();
        setState(() {});
      }
    } catch (_) {}
  }

  void _showAddSpellDialog(dynamic character, List<_SpellClass> charClasses) {
    final nameController = TextEditingController();
    int level = 0;
    String cls = charClasses.isNotEmpty ? charClasses.first.name : 'Other';
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
              if (charClasses.length > 1)
                DropdownButtonFormField<String>(
                  value: cls, // ignore: deprecated_member_use
                  decoration: const InputDecoration(
                      labelText: 'Class', border: OutlineInputBorder()),
                  items: charClasses
                      .map((c) => DropdownMenuItem(value: c.name, child: Text(c.name)))
                      .toList(),
                  onChanged: (v) => setS(() => cls = v ?? cls),
                ),
              const SizedBox(height: 12),
              Row(children: [
                const Text('Level: '),
                DropdownButton<int>(
                  value: level,
                  items: List.generate(
                      10, (i) => DropdownMenuItem(value: i, child: Text('$i'))),
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
                  _addToList(character, 'knownSpells', {
                    'name':  nameController.text.trim(),
                    'level': level,
                    'class': cls,
                  });
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

  // ==========================================================================
  // Spell detail bottom sheet
  // ==========================================================================

  void _showSpellDetail(BuildContext context, dynamic spell) {
    String strFor(StringKey k) {
      try { return (spell as dynamic).getString(k) as String? ?? ''; } catch (_) { return ''; }
    }

    final name       = (spell as dynamic).getDisplayName() as String? ?? '';
    final school     = strFor(StringKey.genre);
    final subSchool  = strFor(StringKey.setting);
    final descriptor = strFor(StringKey.dataFormat);
    final components = strFor(StringKey.spellComponents);
    final castTime   = strFor(StringKey.duration);
    final duration   = strFor(StringKey.help);
    final range      = strFor(StringKey.spellRange);
    final target     = strFor(StringKey.targetArea);
    final saveInfo   = strFor(StringKey.convertName);
    final desc       = strFor(StringKey.description);
    final classesRaw = strFor(StringKey.campaignSetting);

    final classEntries = <String>[];
    for (final part in classesRaw.split('|')) {
      final eq = part.indexOf('=');
      if (eq > 0) {
        classEntries.add('${part.substring(0, eq)} ${part.substring(eq + 1)}');
      }
    }

    final schoolLine = [
      school,
      if (subSchool.isNotEmpty) '($subSchool)',
      if (descriptor.isNotEmpty) '[$descriptor]',
    ].join(' ');

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
              child: Container(
                  width: 36, height: 4,
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
            _spellRow('Classes',    classEntries.take(8).join(', ')),
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
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
// Data classes
// ---------------------------------------------------------------------------

class _SpellClass {
  final String key;
  final String name;
  final int level;
  const _SpellClass({required this.key, required this.name, required this.level});
}

class _InnateEntry {
  final String spell, timesPerDay, cl;
  const _InnateEntry(
      {required this.spell, required this.timesPerDay, required this.cl});
}

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
