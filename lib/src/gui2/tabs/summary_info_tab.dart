//
// Copyright 2010 (C) Connor Petty <cpmeister@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.gui2.tabs.SummaryInfoTab

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_pcgen/src/core/data_set.dart';
import 'package:flutter_pcgen/src/core/language.dart';
import 'package:flutter_pcgen/src/core/pc_class.dart';
import 'package:flutter_pcgen/src/core/pc_stat.dart';
import 'package:flutter_pcgen/src/gui2/app_state.dart';
import 'package:flutter_pcgen/src/gui2/tabs/character_info_tab.dart';
import 'package:flutter_pcgen/src/gui2/tabs/tab_title.dart';
import 'package:flutter_pcgen/src/gui2/tabs/todo_handler.dart';

/// Standard 3.5e ability score abbreviations in order.
const _kDefaultStatKeys = ['STR', 'DEX', 'CON', 'INT', 'WIS', 'CHA'];

/// The Summary tab — displays key character attributes, stats, class levels,
/// and saves. Fully reactive via ValueListenableBuilders on global app state.
class SummaryInfoTabWidget extends StatefulWidget implements TodoHandler {
  const SummaryInfoTabWidget({super.key});

  @override
  void adviseTodo(String fieldName) {}

  @override
  State<SummaryInfoTabWidget> createState() => _SummaryInfoTabState();
}

class _SummaryInfoTabState extends State<SummaryInfoTabWidget>
    implements CharacterInfoTab {
  final TabTitle _tabTitle = TabTitle.withTitle('Summary', null);

  // Name editing
  late TextEditingController _nameController;
  bool _nameEditPending = false;

  // HP editing
  late TextEditingController _hpController;
  bool _hpEditPending = false;

  // Deity editing — must be a persistent controller or it resets on every rebuild
  late TextEditingController _deityController;
  late FocusNode _deityFocus;

  // Player name / Age / Gender
  late TextEditingController _playerNameController;
  late TextEditingController _ageController;
  late TextEditingController _genderController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _hpController = TextEditingController();
    _deityController = TextEditingController();
    _deityFocus = FocusNode();
    _playerNameController = TextEditingController();
    _ageController = TextEditingController();
    _genderController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hpController.dispose();
    _deityController.dispose();
    _deityFocus.dispose();
    _playerNameController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    super.dispose();
  }

  @override
  TabTitle getTabTitle() => _tabTitle;

  @override
  ModelMap createModels(dynamic character) => ModelMap();

  @override
  void restoreModels(ModelMap models) {}

  @override
  void storeModels(ModelMap models) {}

  // ---- Build ----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: currentCharacter,
      builder: (context, character, _) {
        if (character == null) {
          return const Center(child: Text('No character selected.'));
        }
        return ValueListenableBuilder(
          valueListenable: loadedDataSet,
          builder: (context, dataset, _) {
            // Stat list: prefer loaded stats, fall back to hardcoded 3.5e list.
            final statKeys = (dataset != null && dataset.stats.isNotEmpty)
                ? dataset.stats.map((s) => s.getKeyName()).toList()
                : _kDefaultStatKeys;
            final statObjects = (dataset != null && dataset.stats.isNotEmpty)
                ? dataset.stats
                : <PCStat>[];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIdentitySection(character),
                  const SizedBox(height: 12),
                  _buildLanguagesSection(character, dataset),
                  const SizedBox(height: 12),
                  _buildStatsSection(character, statKeys, statObjects),
                  const SizedBox(height: 12),
                  _buildCombatSection(character, statKeys, statObjects),
                  const SizedBox(height: 12),
                  _buildSavesSection(character, statKeys, statObjects, dataset),
                  const SizedBox(height: 12),
                  _buildClassLevelSection(character),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ---- Identity section -----------------------------------------------------

  Widget _buildIdentitySection(dynamic character) {
    // Sync name only when not actively editing
    final charName = (character as dynamic).getName() as String? ?? '';
    if (!_nameEditPending && _nameController.text != charName) {
      _nameController.text = charName;
    }

    // Sync deity only when the field is not focused
    String deityKey = '';
    try { deityKey = (character as dynamic).getDeityKey() as String? ?? ''; } catch (_) {}
    if (!_deityFocus.hasFocus && _deityController.text != deityKey) {
      _deityController.text = deityKey;
    }

    // Sync player name / age / gender when not focused (no pending flag needed
    // since these fields save on submit, not on every keystroke)
    String playerName = '';
    try { playerName = (character as dynamic).getPlayersName() as String? ?? ''; } catch (_) {}
    if (_playerNameController.text != playerName) _playerNameController.text = playerName;

    String gender = '';
    try { gender = (character as dynamic).getGender() as String? ?? ''; } catch (_) {}
    if (_genderController.text != gender) _genderController.text = gender;

    int age = 0;
    try { age = (character as dynamic).getAge() as int? ?? 0; } catch (_) {}
    final ageStr = age > 0 ? '$age' : '';
    if (_ageController.text != ageStr) _ageController.text = ageStr;

    final raceRef = character.getRaceRef();
    final raceObj = raceRef?.get();
    final raceName = raceObj != null
        ? (raceObj as dynamic).getDisplayName() as String? ?? '(none)'
        : '(none)';

    return ValueListenableBuilder(
      valueListenable: loadedDataSet,
      builder: (context, dataset, _) {
        final alignments = dataset?.alignments ?? const [];
        String alignKey = '';
        try { alignKey = (character as dynamic).getAlignmentKey() as String? ?? ''; } catch (_) {}

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Identity', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                _editRow('Name', _nameController,
                  onChanged: (v) { _nameEditPending = true; character.setName(v); },
                  onDone: (v) { _nameEditPending = false; }),
                const SizedBox(height: 4),
                _editRow('Player', _playerNameController,
                  onDone: (v) {
                    try { (character as dynamic).setPlayersName(v); } catch (_) {}
                  }),
                const SizedBox(height: 4),
                Row(children: [
                  Expanded(child: _editRow('Gender', _genderController,
                    onDone: (v) {
                      try { (character as dynamic).setGender(v); } catch (_) {}
                    })),
                  const SizedBox(width: 8),
                  Expanded(child: _editRow('Age', _ageController,
                    keyboardType: TextInputType.number,
                    onDone: (v) {
                      final n = int.tryParse(v);
                      if (n != null) try { (character as dynamic).setAge(n); } catch (_) {}
                    })),
                ]),
                const SizedBox(height: 6),
                _labelledValue('Race', raceName),
                _labelledValue('Class', _classLevelSummary(character)),
                const SizedBox(height: 6),
                // Alignment dropdown
                if (alignments.isNotEmpty)
                  Row(children: [
                    const SizedBox(width: 80,
                        child: Text('Alignment:', style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: alignKey.isEmpty ? null : alignKey,
                        hint: const Text('— Select —'),
                        items: alignments.map((a) {
                          final key = (a as dynamic).getKeyName() as String;
                          final name = (a as dynamic).getDisplayName() as String;
                          return DropdownMenuItem(value: key, child: Text(name));
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) {
                            try { (character as dynamic).setAlignmentKey(v); } catch (_) {}
                            currentCharacter.notifyListeners();
                            setState(() {});
                          }
                        },
                      ),
                    ),
                  ]),
                const SizedBox(height: 6),
                // Deity — persistent controller, only syncs when not focused
                _editRow('Deity', _deityController,
                  focusNode: _deityFocus,
                  hint: 'Deity name',
                  onDone: (v) {
                    try { (character as dynamic).setDeityKey(v); } catch (_) {}
                    currentCharacter.notifyListeners();
                  }),
              ],
            ),
          ),
        );
      },
    );
  }

  /// A labelled text field row that commits on submit/unfocus.
  Widget _editRow(String label, TextEditingController ctrl, {
    FocusNode? focusNode,
    String? hint,
    TextInputType? keyboardType,
    void Function(String)? onChanged,
    void Function(String)? onDone,
  }) {
    return Row(children: [
      SizedBox(width: 80,
          child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold))),
      Expanded(
        child: TextField(
          controller: ctrl,
          focusNode: focusNode,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            border: const OutlineInputBorder(), isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            hintText: hint,
          ),
          onChanged: onChanged,
          onSubmitted: onDone,
          onEditingComplete: () { if (onDone != null) onDone(ctrl.text); },
        ),
      ),
    ]);
  }

  String _classLevelSummary(dynamic character) {
    try {
      return (character as dynamic).getClassLevelSummary() as String? ?? '';
    } catch (_) {
      return '';
    }
  }

  // ---- Stats section --------------------------------------------------------

  // ---- Languages section ----------------------------------------------------

  Widget _buildLanguagesSection(dynamic character, DataSet? dataset) {
    final available = dataset?.languages ?? const <Language>[];
    final selected = _getLanguageKeys(character);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Languages', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                if (available.isNotEmpty && character != null)
                  TextButton.icon(
                    icon: const Icon(Icons.add, size: 14),
                    label: const Text('Add'),
                    onPressed: () => _showAddLanguageDialog(context, character, available, selected),
                  ),
              ],
            ),
            if (selected.isEmpty)
              const Text('No languages selected.',
                  style: TextStyle(color: Colors.grey, fontSize: 12))
            else
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: selected.map((key) {
                  final lang = available.where((l) => l.getKeyName() == key).firstOrNull;
                  return InputChip(
                    label: Text(lang?.getDisplayName() ?? key,
                        style: const TextStyle(fontSize: 12)),
                    onDeleted: character == null
                        ? null
                        : () => _removeLanguage(character, key),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  List<String> _getLanguageKeys(dynamic character) {
    if (character == null) return [];
    try {
      final data = (character as dynamic).toJson() as Map<String, dynamic>;
      final list = data['languageKeys'];
      if (list is List) return list.cast<String>();
    } catch (_) {}
    return [];
  }

  void _addLanguage(dynamic character, String key) {
    try {
      final data = (character as dynamic).toJson() as Map<String, dynamic>;
      final list = (data['languageKeys'] ??= <String>[]) as List;
      if (!list.contains(key)) {
        list.add(key);
        currentCharacter.notifyListeners();
        setState(() {});
      }
    } catch (_) {}
  }

  void _removeLanguage(dynamic character, String key) {
    try {
      final data = (character as dynamic).toJson() as Map<String, dynamic>;
      final list = data['languageKeys'] as List?;
      if (list != null && list.remove(key)) {
        currentCharacter.notifyListeners();
        setState(() {});
      }
    } catch (_) {}
  }

  void _showAddLanguageDialog(BuildContext context, dynamic character,
      List<Language> available, List<String> selected) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Language'),
        content: SizedBox(
          width: 280,
          height: 360,
          child: ListView.builder(
            itemCount: available.length,
            itemBuilder: (context, i) {
              final lang = available[i];
              final isSelected = selected.contains(lang.getKeyName());
              return ListTile(
                dense: true,
                title: Text(lang.getDisplayName()),
                trailing: isSelected
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: isSelected
                    ? null
                    : () {
                        _addLanguage(character, lang.getKeyName());
                        Navigator.pop(context);
                      },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(
      dynamic character, List<String> statKeys, List<PCStat> statObjects) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ability Scores',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Table(
              columnWidths: const {
                0: FixedColumnWidth(56),
                1: FixedColumnWidth(68),
                2: FixedColumnWidth(46),
                3: FixedColumnWidth(44),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                  decoration: BoxDecoration(
                      color: Theme.of(context).highlightColor),
                  children: const [
                    Padding(padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                        child: Text('Stat', style: TextStyle(fontWeight: FontWeight.bold))),
                    Padding(padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                        child: Text('Base', style: TextStyle(fontWeight: FontWeight.bold))),
                    Padding(padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                        child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
                    Padding(padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                        child: Text('Mod', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
                for (int i = 0; i < statKeys.length; i++)
                  _buildStatRow(
                    character,
                    statKeys[i],
                    i < statObjects.length ? statObjects[i] : null,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildStatRow(dynamic character, String statKey, PCStat? statObj) {
    int base = 10;
    int racial = 0;
    int effective = 10;
    if (statObj != null) {
      try { base = (character as dynamic).getScoreBase(statObj) as int? ?? 10; } catch (_) {}
      try { racial = (character as dynamic).getRacialBonus(statObj) as int? ?? 0; } catch (_) {}
      effective = base + racial;
    }
    final mod = ((effective - 10) / 2).floor();
    final modStr = mod >= 0 ? '+$mod' : '$mod';

    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
          child: Tooltip(
            message: statObj?.getDisplayName() ?? statKey,
            child: Text(statKey,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
          child: _StatScoreField(
            key: ValueKey('stat_$statKey'),
            initialValue: base,
            onChanged: (newBase) {
              if (statObj != null) {
                try {
                  (character as dynamic).setScoreBase(statObj, newBase);
                  currentCharacter.notifyListeners();
                } catch (_) {}
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
          child: racial == 0
              ? Text('$effective',
                  style: const TextStyle(fontWeight: FontWeight.bold))
              : Tooltip(
                  message: 'Base $base + racial ${racial >= 0 ? "+$racial" : "$racial"}',
                  child: Text('$effective',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: racial > 0
                              ? Colors.blue.shade700
                              : Colors.orange.shade700)),
                ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
          child: Text(modStr,
              style: TextStyle(
                  color: mod >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                  fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  // ---- Combat section -------------------------------------------------------

  Widget _buildCombatSection(dynamic character, List<String> statKeys,
      List<PCStat> statObjects) {
    final dataset = loadedDataSet.value;
    final dexMod = _getStatMod(character, statKeys, statObjects, 'DEX');
    final bab = _computeBab(character, dataset);
    final initiative = dexMod;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Combat', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                _combatChip('Initiative', _fmtMod(initiative)),
                const SizedBox(width: 12),
                _combatChip('BAB', _babSequence(bab)),
                const SizedBox(width: 12),
                _combatChip('AC', '${10 + dexMod}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Full attack sequence string: '+6/+1' for BAB 6, '+11/+6/+1' for 11, etc.
  String _babSequence(int bab) {
    if (bab <= 0) return '+0';
    if (bab < 6) return '+$bab';
    final attacks = <String>[];
    int current = bab;
    while (current > 0) {
      attacks.add('+$current');
      current -= 5;
    }
    return attacks.join('/');
  }

  /// Compute BAB from class levels and each class's BAB progression type.
  int _computeBab(dynamic character, DataSet? dataset) {
    List classLevels = [];
    try { classLevels = ((character as dynamic).toJson()['classLevels'] as List?) ?? []; } catch (_) {}
    if (classLevels.isEmpty) return 0;
    final classes = dataset?.classes ?? const <PCClass>[];

    // Count levels per class key.
    final counts = <String, int>{};
    for (final l in classLevels) {
      if (l is Map) {
        final k = l['classKey'] as String? ?? '';
        counts[k] = (counts[k] ?? 0) + 1;
      }
    }

    // Sum BAB contribution from each class.
    double total = 0.0;
    for (final entry in counts.entries) {
      final cls = classes.where((c) => c.getKeyName() == entry.key).firstOrNull;
      final bab = cls?.getBabProgression() ?? '';
      final rate = bab == 'Full' ? 1.0 : bab == 'Half' ? 0.5 : 0.75;
      total += entry.value * rate;
    }
    return total.floor();
  }

  Widget _combatChip(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  // ---- Saves section --------------------------------------------------------

  int _getStatMod(dynamic character, List<String> statKeys,
      List<PCStat> statObjects, String key) {
    final idx = statKeys.indexOf(key);
    if (idx >= 0 && idx < statObjects.length) {
      try {
        return (character as dynamic).getModTotal(statObjects[idx]) as int? ?? 0;
      } catch (_) {}
    }
    return 0;
  }

  String _fmtMod(int v) => v >= 0 ? '+$v' : '$v';

  Widget _buildSavesSection(dynamic character, List<String> statKeys,
      List<PCStat> statObjects, DataSet? dataset) {
    // Standard 3.5e saves with governing stat abbreviations.
    const saves = [
      ('Fortitude', 'Fort', 'CON'),
      ('Reflex',    'Ref',  'DEX'),
      ('Will',      'Will', 'WIS'),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Saving Throws', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: saves.map((s) {
                final (fullName, abbr, statAbb) = s;
                final total = _computeSave(fullName, statAbb, character,
                    statKeys, statObjects, dataset);
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _saveChip(abbr, _fmtMod(total)),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Compute a saving throw total using class levels + stat modifier.
  /// Uses 3.5e Good (floor(L/2)+2) / Poor (floor(L/3)) progression per class.
  int _computeSave(String saveName, String statAbb, dynamic character,
      List<String> statKeys, List<PCStat> statObjects, DataSet? dataset) {
    final statMod = _getStatMod(character, statKeys, statObjects, statAbb);
    if (dataset == null) return statMod;

    List classLevels = [];
    try {
      classLevels = ((character as dynamic).toJson()['classLevels'] as List?) ?? [];
    } catch (_) {}
    if (classLevels.isEmpty) return statMod;

    final counts = <String, int>{};
    for (final l in classLevels) {
      if (l is Map) {
        final k = l['classKey'] as String? ?? '';
        counts[k] = (counts[k] ?? 0) + 1;
      }
    }

    double base = 0;
    bool hasGoodClass = false;
    for (final entry in counts.entries) {
      final cls = dataset.classes
          .where((c) => c.getKeyName() == entry.key)
          .firstOrNull;
      final isGood = cls?.isSaveGood(saveName) ?? false;
      if (isGood) {
        // Good save: floor(L/2) + 2 per class, but +2 bonus counted once
        base += entry.value / 2;
        if (!hasGoodClass) { base += 2; hasGoodClass = true; }
      } else {
        base += entry.value / 3;
      }
    }

    return base.floor() + statMod;
  }

  Widget _saveChip(String label, String value) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(value,
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  // ---- Class level section --------------------------------------------------

  Widget _buildClassLevelSection(dynamic character) {
    final summary = _classLevelSummary(character);
    int totalLevel = 0;
    try { totalLevel = (character as dynamic).getTotalCharacterLevel() as int? ?? 0; } catch (_) {}

    // HP: load from data or compute estimate (d8 + CON mod) × level
    int hp = 0;
    try { hp = (character as dynamic).getHP() as int? ?? 0; } catch (_) {}
    if (!_hpEditPending && _hpController.text != '$hp') {
      _hpController.text = '$hp';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Class & Combat', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _labelledValue('Total Level', '$totalLevel'),
            if (summary.isNotEmpty) _labelledValue('Classes', summary),
            // XP tracking
            const SizedBox(height: 4),
            _buildXPRow(character, totalLevel),
            const SizedBox(height: 6),
            Row(
              children: [
                const SizedBox(width: 80,
                    child: Text('HP:', style: TextStyle(fontWeight: FontWeight.bold))),
                SizedBox(
                  width: 60,
                  child: TextField(
                    controller: _hpController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    ),
                    onChanged: (_) => _hpEditPending = true,
                    onSubmitted: (v) {
                      _hpEditPending = false;
                      final n = int.tryParse(v);
                      if (n != null) {
                        try { (character as dynamic).setHP(n); } catch (_) {}
                        currentCharacter.notifyListeners();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                if (totalLevel > 0)
                  TextButton.icon(
                    icon: const Icon(Icons.casino, size: 14),
                    label: const Text('Max'),
                    onPressed: () {
                      _hpEditPending = false;
                      try {
                        final dataset = loadedDataSet.value;
                        final statObjects = dataset?.stats ?? const [];
                        int conMod = 0;
                        for (final s in statObjects) {
                          if (s.getKeyName().toUpperCase() == 'CON') {
                            conMod = (character as dynamic).getModTotal(s) as int? ?? 0;
                            break;
                          }
                        }
                        // Use class HD if available, otherwise d8 default.
                        int hdSize = 8;
                        try {
                          final levels = (character as dynamic).toJson()['classLevels'];
                          if (levels is List && levels.isNotEmpty) {
                            final clsKey = levels.last['classKey'] as String?;
                            final cls = dataset?.classes.where((c) => c.getKeyName() == clsKey).firstOrNull;
                            if (cls != null) {
                              final hdStr = cls.getHD();
                              hdSize = int.tryParse(hdStr) ?? 8;
                            }
                          }
                        } catch (_) {}
                        final maxHp = (hdSize + conMod).clamp(1, hdSize) * totalLevel;
                        (character as dynamic).setHP(maxHp);
                        currentCharacter.notifyListeners();
                        setState(() {});
                      } catch (_) {}
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---- XP row ---------------------------------------------------------------

  Widget _buildXPRow(dynamic character, int totalLevel) {
    int xp = 0;
    try { xp = (character as dynamic).getXP() as int? ?? 0; } catch (_) {}
    // 3.5e XP thresholds: level × (level - 1) × 500
    final nextLevelXP = totalLevel > 0 ? (totalLevel * (totalLevel + 1) * 500) : 1000;

    return Row(
      children: [
        const SizedBox(width: 80, child: Text('XP:', style: TextStyle(fontWeight: FontWeight.bold))),
        Text('$xp / $nextLevelXP'),
        const SizedBox(width: 8),
        SizedBox(
          width: 120,
          height: 6,
          child: LinearProgressIndicator(
            value: (xp / nextLevelXP).clamp(0.0, 1.0),
            backgroundColor: Colors.grey.shade300,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: '+XP',
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            ),
            onSubmitted: (v) {
              final gain = int.tryParse(v);
              if (gain != null && gain != 0) {
                try {
                  (character as dynamic).adjustXP(gain);
                  currentCharacter.notifyListeners();
                  setState(() {});
                } catch (_) {}
              }
            },
          ),
        ),
      ],
    );
  }

  // ---- Helpers --------------------------------------------------------------

  Widget _labelledValue(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text('$label:',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

/// An editable integer field for ability score input.
class _StatScoreField extends StatefulWidget {
  final int initialValue;
  final ValueChanged<int> onChanged;

  const _StatScoreField({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<_StatScoreField> createState() => _StatScoreFieldState();
}

class _StatScoreFieldState extends State<_StatScoreField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.initialValue}');
  }

  @override
  void didUpdateWidget(_StatScoreField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _controller.text = '${widget.initialValue}';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _commit() {
    final parsed = int.tryParse(_controller.text);
    if (parsed != null) {
      widget.onChanged(parsed.clamp(1, 30));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 55,
      child: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        ),
        onSubmitted: (_) => _commit(),
        onEditingComplete: _commit,
      ),
    );
  }
}
