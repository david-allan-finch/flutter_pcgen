// Copyright 2010 (C) Connor Petty <cpmeister@users.sourceforge.net>
// LGPL 2.1 — Translation of pcgen.gui2.tabs.SummaryInfoTab

import 'dart:math' show Random;

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

const _kDefaultStatKeys = ['STR', 'DEX', 'CON', 'INT', 'WIS', 'CHA'];

// ---- Stat allocation modes --------------------------------------------------
enum _StatMode { manual, standardArray, pointBuy, roll }

// 3.5e point-buy cost table: index = score - 8
const _kPointBuyCost = [0, 1, 2, 3, 4, 5, 6, 8, 10, 13, 16];

int _pointBuyCostFor(int score) {
  final idx = score - 8;
  if (idx < 0) return 0;
  if (idx >= _kPointBuyCost.length) return _kPointBuyCost.last;
  return _kPointBuyCost[idx];
}

const _kStandardArray = [15, 14, 13, 12, 10, 8];

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

  late TextEditingController _nameController;
  bool _nameEditPending = false;
  late TextEditingController _hpController;
  bool _hpEditPending = false;
  late TextEditingController _playerNameController;
  late TextEditingController _ageController;
  late TextEditingController _genderController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _eyeColorController;
  late TextEditingController _hairColorController;
  late TextEditingController _skinColorController;

  // ---- Stat allocation state ------------------------------------------------
  _StatMode _statMode = _StatMode.manual;
  int _pointBuyPool = 25;

  // Standard Array / Roll: unassigned pool values and current assignments.
  // _poolValues: remaining unassigned values; _assignments: statKey→assigned value (null = unassigned)
  List<int> _poolValues = [];
  final Map<String, int?> _assignments = {};

  // Roll mode generated scores (before assignment)
  List<int> _rolledScores = [];

  void _initAssignmentMode(List<String> statKeys, _StatMode mode) {
    _assignments.clear();
    for (final k in statKeys) {
      _assignments[k] = null;
    }
    if (mode == _StatMode.standardArray) {
      _poolValues = List.of(_kStandardArray);
    } else if (mode == _StatMode.roll) {
      _rolledScores = _rollStats(statKeys.length);
      _poolValues = List.of(_rolledScores);
    }
  }

  List<int> _rollStats(int count) {
    final rng = Random();
    return List.generate(count, (_) {
      final rolls = List.generate(4, (_) => rng.nextInt(6) + 1)..sort();
      return rolls.skip(1).fold(0, (a, b) => a + b); // drop lowest
    });
  }

  void _assignValue(dynamic character, List<PCStat> statObjects,
      List<String> statKeys, String statKey, int value) {
    // If stat already had a value, return it to pool
    final old = _assignments[statKey];
    if (old != null) _poolValues.add(old);
    _poolValues.remove(value);
    _assignments[statKey] = value;

    // Write to character
    final idx = statKeys.indexOf(statKey);
    if (idx >= 0 && idx < statObjects.length) {
      try {
        (character as dynamic).setScoreBase(statObjects[idx], value);
        currentCharacter.notifyListeners();
      } catch (_) {}
    }
    setState(() {});
  }

  void _clearAssignment(dynamic character, List<PCStat> statObjects,
      List<String> statKeys, String statKey) {
    final old = _assignments[statKey];
    if (old == null) return;
    _poolValues.add(old);
    _poolValues.sort((a, b) => b.compareTo(a));
    _assignments[statKey] = null;
    final idx = statKeys.indexOf(statKey);
    if (idx >= 0 && idx < statObjects.length) {
      try {
        (character as dynamic).setScoreBase(statObjects[idx], 10);
        currentCharacter.notifyListeners();
      } catch (_) {}
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _hpController = TextEditingController();
    _playerNameController = TextEditingController();
    _ageController = TextEditingController();
    _genderController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    _eyeColorController = TextEditingController();
    _hairColorController = TextEditingController();
    _skinColorController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hpController.dispose();
    _playerNameController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _eyeColorController.dispose();
    _hairColorController.dispose();
    _skinColorController.dispose();
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
                  _buildProgressCard(character),
                  const SizedBox(height: 12),
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

  // ---- Character Progress card ---------------------------------------------

  Widget _buildProgressCard(dynamic character) {
    Map<String, dynamic> data = {};
    try { data = (character as dynamic).toJson() as Map<String, dynamic>; } catch (_) {}

    final charName   = data['name'] as String? ?? '';
    final raceKey    = data['raceKey'] as String? ?? '';
    final classLevels = data['classLevels'] as List? ?? [];
    final statScores = data['statScores'] as Map? ?? {};
    final skillRanks  = data['skillRanks']  as Map? ?? {};
    final abilities   = data['selectedAbilities'] as Map? ?? {};
    final feats       = (abilities['FEAT'] as List?)?.isNotEmpty ?? false;

    final statsSet = statScores.values.any((v) => (v as num?)?.toInt() != 10);
    final hasSkills = skillRanks.values.any((v) => (v as num? ?? 0) > 0);
    final hasClass  = classLevels.isNotEmpty;

    final items = [
      _ProgressItem('Name',   charName.isNotEmpty,  charName.isNotEmpty ? charName : 'Not set'),
      _ProgressItem('Race',   raceKey.isNotEmpty,   raceKey.isNotEmpty  ? raceKey  : 'Not selected'),
      _ProgressItem('Class',  hasClass,              hasClass ? '${classLevels.length} level(s)' : 'No class chosen'),
      _ProgressItem('Stats',  statsSet,              statsSet ? 'Assigned' : 'All default (10) — use allocation below'),
      _ProgressItem('Skills', hasSkills || !hasClass,'${hasSkills ? "Some ranks spent" : hasClass ? "No ranks spent yet" : "N/A"}'),
      _ProgressItem('Feats',  feats || !hasClass,    feats ? 'Feats selected' : hasClass ? 'No feats selected' : 'N/A'),
    ];

    final done = items.where((i) => i.done).length;

    return Card(
      child: ExpansionTile(
        initiallyExpanded: done < items.length,
        title: Row(children: [
          Text('Character Progress', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(width: 8),
          Text('$done / ${items.length}',
              style: TextStyle(
                  fontSize: 12,
                  color: done == items.length ? Colors.green.shade700 : Colors.orange.shade700,
                  fontWeight: FontWeight.bold)),
        ]),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(
              children: items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(children: [
                  Icon(
                    item.done ? Icons.check_circle : Icons.radio_button_unchecked,
                    size: 16,
                    color: item.done ? Colors.green.shade600 : Colors.orange.shade600,
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 60,
                    child: Text(item.label,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  Expanded(
                    child: Text(item.detail,
                        style: TextStyle(
                            fontSize: 12,
                            color: item.done ? Colors.grey.shade700 : Colors.orange.shade700)),
                  ),
                ]),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ---- Identity section -----------------------------------------------------

  Widget _buildIdentitySection(dynamic character) {
    final charName = (character as dynamic).getName() as String? ?? '';
    if (!_nameEditPending && _nameController.text != charName) {
      _nameController.text = charName;
    }

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

    int height = 0;
    try { height = (character as dynamic).getHeight() as int? ?? 0; } catch (_) {}
    final heightStr = height > 0 ? '$height' : '';
    if (_heightController.text != heightStr) _heightController.text = heightStr;

    int weight = 0;
    try { weight = (character as dynamic).getWeight() as int? ?? 0; } catch (_) {}
    final weightStr = weight > 0 ? '$weight' : '';
    if (_weightController.text != weightStr) _weightController.text = weightStr;

    String eyeColor = '';
    try { eyeColor = (character as dynamic).getEyeColor() as String? ?? ''; } catch (_) {}
    if (_eyeColorController.text != eyeColor) _eyeColorController.text = eyeColor;

    String hairColor = '';
    try { hairColor = (character as dynamic).getHairColor() as String? ?? ''; } catch (_) {}
    if (_hairColorController.text != hairColor) _hairColorController.text = hairColor;

    String skinColor = '';
    try { skinColor = (character as dynamic).getSkinColor() as String? ?? ''; } catch (_) {}
    if (_skinColorController.text != skinColor) _skinColorController.text = skinColor;

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
                    onDone: (v) { try { (character as dynamic).setGender(v); } catch (_) {} })),
                  const SizedBox(width: 8),
                  Expanded(child: _editRow('Age', _ageController,
                    keyboardType: TextInputType.number,
                    onDone: (v) {
                      final n = int.tryParse(v);
                      if (n != null) try { (character as dynamic).setAge(n); } catch (_) {}
                    })),
                ]),
                const SizedBox(height: 4),
                Row(children: [
                  Expanded(child: _editRow('Height (in)', _heightController,
                    labelWidth: 95, keyboardType: TextInputType.number,
                    onDone: (v) {
                      final n = int.tryParse(v);
                      if (n != null) try { (character as dynamic).setHeight(n); } catch (_) {}
                    })),
                  const SizedBox(width: 8),
                  Expanded(child: _editRow('Weight (lb)', _weightController,
                    labelWidth: 95, keyboardType: TextInputType.number,
                    onDone: (v) {
                      final n = int.tryParse(v);
                      if (n != null) try { (character as dynamic).setWeight(n); } catch (_) {}
                    })),
                ]),
                const SizedBox(height: 4),
                Row(children: [
                  Expanded(child: _editRow('Eyes', _eyeColorController,
                    onDone: (v) { try { (character as dynamic).setEyeColor(v); } catch (_) {} })),
                  const SizedBox(width: 8),
                  Expanded(child: _editRow('Hair', _hairColorController,
                    onDone: (v) { try { (character as dynamic).setHairColor(v); } catch (_) {} })),
                  const SizedBox(width: 8),
                  Expanded(child: _editRow('Skin', _skinColorController,
                    onDone: (v) { try { (character as dynamic).setSkinColor(v); } catch (_) {} })),
                ]),
                const SizedBox(height: 6),
                _labelledValue('Race', raceName),
                _labelledValue('Class', _classLevelSummary(character)),
                const SizedBox(height: 4),
                // Size and speed from race
                Row(children: [
                  Expanded(child: _buildSizeSpeed(character)),
                ]),
                const SizedBox(height: 4),
                _buildVisionRow(character),
                const SizedBox(height: 6),
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
                          final key  = (a as dynamic).getKeyName()    as String;
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
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSizeSpeed(dynamic character) {
    String size = 'M';
    Map speeds = const {'Walk': 30};
    try { size   = (character as dynamic).getRaceSize() as String? ?? 'M'; } catch (_) {}
    try { speeds = (character as dynamic).getRaceSpeeds() as Map? ?? const {'Walk': 30}; } catch (_) {}

    final sizeName = _sizeLabel(size);
    final speedStr = speeds.entries
        .map((e) => '${e.key} ${e.value}ft')
        .join(', ');

    return Row(
      children: [
        const SizedBox(width: 80,
            child: Text('Size / Speed:', style: TextStyle(fontWeight: FontWeight.bold))),
        Text('$sizeName  •  $speedStr',
            style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildVisionRow(dynamic character) {
    List<String> visions = const [];
    try { visions = (character as dynamic).getVisionTypes() as List<String>? ?? []; } catch (_) {}
    if (visions.isEmpty) return const SizedBox.shrink();
    return Row(children: [
      const SizedBox(width: 80,
          child: Text('Vision:', style: TextStyle(fontWeight: FontWeight.bold))),
      Expanded(child: Text(visions.join(', '), style: const TextStyle(fontSize: 12))),
    ]);
  }

  String _sizeLabel(String abbr) {
    switch (abbr.toUpperCase()) {
      case 'F': return 'Fine';
      case 'D': return 'Diminutive';
      case 'T': return 'Tiny';
      case 'S': return 'Small';
      case 'M': return 'Medium';
      case 'L': return 'Large';
      case 'H': return 'Huge';
      case 'G': return 'Gargantuan';
      case 'C': return 'Colossal';
      default:  return abbr;
    }
  }

  Widget _editRow(String label, TextEditingController ctrl, {
    FocusNode? focusNode,
    String? hint,
    TextInputType? keyboardType,
    double labelWidth = 80,
    void Function(String)? onChanged,
    void Function(String)? onDone,
  }) {
    return Row(children: [
      SizedBox(width: labelWidth,
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
    try { return (character as dynamic).getClassLevelSummary() as String? ?? ''; }
    catch (_) { return ''; }
  }

  // ---- Languages section ----------------------------------------------------

  Widget _buildLanguagesSection(dynamic character, DataSet? dataset) {
    final available = dataset?.languages ?? const <Language>[];
    final selected = _getLanguageKeys(character);

    // Racial bonus language choices not yet learned
    List<String> bonusChoices = const [];
    try {
      bonusChoices =
          (character as dynamic).getRaceBonusLanguages() as List<String>? ?? [];
    } catch (_) {}
    final unlearnedBonus = bonusChoices
        .where((l) => !selected.contains(l))
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text('Languages', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              if (available.isNotEmpty && character != null)
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text('Add'),
                  onPressed: () => _showAddLanguageDialog(context, character, available, selected),
                ),
            ]),
            if (selected.isEmpty)
              const Text('No languages selected.',
                  style: TextStyle(color: Colors.grey, fontSize: 12))
            else
              Wrap(
                spacing: 6, runSpacing: 4,
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
            // Racial bonus language choices not yet taken
            if (unlearnedBonus.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('Racial bonus language choices:',
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic)),
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: unlearnedBonus.map((lang) => ActionChip(
                  label: Text('+ $lang', style: const TextStyle(fontSize: 11)),
                  backgroundColor: Colors.green.shade50,
                  onPressed: character == null
                      ? null
                      : () => _addLanguage(character, lang),
                )).toList(),
              ),
            ],
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
          width: 280, height: 360,
          child: ListView.builder(
            itemCount: available.length,
            itemBuilder: (context, i) {
              final lang = available[i];
              final isSelected = selected.contains(lang.getKeyName());
              return ListTile(
                dense: true,
                title: Text(lang.getDisplayName()),
                trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: isSelected ? null : () {
                  _addLanguage(character, lang.getKeyName());
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  // ---- Stats section --------------------------------------------------------

  Widget _buildStatsSection(dynamic character, List<String> statKeys, List<PCStat> statObjects) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ability Scores', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            // Mode selector
            _buildModeSelector(character, statKeys, statObjects),
            const SizedBox(height: 8),
            // Mode-specific controls
            if (_statMode == _StatMode.pointBuy)
              _buildPointBuyControls(character, statKeys, statObjects)
            else if (_statMode == _StatMode.standardArray || _statMode == _StatMode.roll)
              _buildPoolControls(character, statKeys, statObjects)
            else
              _buildManualTable(character, statKeys, statObjects),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSelector(dynamic character, List<String> statKeys, List<PCStat> statObjects) {
    final modes = [
      (_StatMode.manual,        'Manual'),
      (_StatMode.standardArray, 'Standard Array'),
      (_StatMode.pointBuy,      'Point Buy'),
      (_StatMode.roll,          'Dice Roll'),
    ];
    return Wrap(
      spacing: 6, runSpacing: 4,
      children: modes.map((m) {
        final (mode, label) = m;
        final selected = _statMode == mode;
        return ChoiceChip(
          label: Text(label, style: const TextStyle(fontSize: 12)),
          selected: selected,
          onSelected: (_) {
            setState(() {
              _statMode = mode;
              if (mode == _StatMode.standardArray || mode == _StatMode.roll) {
                _initAssignmentMode(statKeys, mode);
              } else if (mode == _StatMode.pointBuy) {
                // Set all stats to 10 as starting point for point buy
                for (int i = 0; i < statKeys.length && i < statObjects.length; i++) {
                  try {
                    (character as dynamic).setScoreBase(statObjects[i], 10);
                  } catch (_) {}
                }
                currentCharacter.notifyListeners();
              }
            });
          },
        );
      }).toList(),
    );
  }

  // ---- Manual mode (existing table) ----------------------------------------

  Widget _buildManualTable(dynamic character, List<String> statKeys, List<PCStat> statObjects) {
    return Table(
      columnWidths: const {
        0: FixedColumnWidth(52),
        1: FixedColumnWidth(60),
        2: FixedColumnWidth(44),
        3: FixedColumnWidth(50),
        4: FixedColumnWidth(40),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          decoration: BoxDecoration(color: Theme.of(context).highlightColor),
          children: const [
            Padding(padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: Text('Stat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            Padding(padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: Text('Base', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            Padding(padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: Text('Race', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            Padding(padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            Padding(padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: Text('Mod', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          ],
        ),
        for (int i = 0; i < statKeys.length; i++)
          _buildStatRow(character, statKeys[i], i < statObjects.length ? statObjects[i] : null),
      ],
    );
  }

  TableRow _buildStatRow(dynamic character, String statKey, PCStat? statObj) {
    int base = 10;
    int racial = 0;
    int levelGains = 0;
    if (statObj != null) {
      try { base       = (character as dynamic).getScoreBase(statObj)      as int? ?? 10; } catch (_) {}
      try { racial     = (character as dynamic).getRacialBonus(statObj)    as int? ?? 0;  } catch (_) {}
      try { levelGains = (character as dynamic).getLevelStatGains(statObj) as int? ?? 0;  } catch (_) {}
    }
    final effective = base + racial + levelGains;
    final mod = ((effective - 10) / 2).floor();
    final modStr = mod >= 0 ? '+$mod' : '$mod';

    final racialStr = racial == 0 ? '—' : (racial > 0 ? '+$racial' : '$racial');
    final racialColor = racial > 0
        ? Colors.blue.shade700
        : racial < 0 ? Colors.orange.shade700 : Colors.grey.shade400;

    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
          child: Tooltip(
            message: statObj?.getDisplayName() ?? statKey,
            child: Text(statKey, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
          child: Text(racialStr,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: racial != 0 ? FontWeight.bold : FontWeight.normal,
                  color: racialColor)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
          child: (racial == 0 && levelGains == 0)
              ? Text('$effective', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))
              : Tooltip(
                  message: [
                    'Base: $base',
                    if (racial != 0) 'Race: ${racial > 0 ? "+$racial" : "$racial"}',
                    if (levelGains != 0) 'Levels: ${levelGains > 0 ? "+$levelGains" : "$levelGains"}',
                    'Total: $effective',
                  ].join('\n'),
                  child: Text('$effective',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12,
                          color: effective > base ? Colors.blue.shade700 : Colors.orange.shade700)),
                ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
          child: Text(modStr,
              style: TextStyle(
                  fontSize: 12,
                  color: mod >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                  fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  // ---- Point Buy controls --------------------------------------------------

  Widget _buildPointBuyControls(dynamic character, List<String> statKeys, List<PCStat> statObjects) {
    // Current scores
    final scores = <String, int>{};
    for (int i = 0; i < statKeys.length && i < statObjects.length; i++) {
      int base = 10;
      try { base = (character as dynamic).getScoreBase(statObjects[i]) as int? ?? 10; } catch (_) {}
      scores[statKeys[i]] = base.clamp(8, 18);
    }

    // Total points spent
    int spent = 0;
    for (final s in scores.values) spent += _pointBuyCostFor(s);
    final remaining = _pointBuyPool - spent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pool selector + remaining display
        Row(children: [
          const Text('Pool:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(width: 8),
          ...[15, 20, 25, 28, 32].map((pool) => Padding(
            padding: const EdgeInsets.only(right: 4),
            child: ChoiceChip(
              label: Text('$pool', style: const TextStyle(fontSize: 11)),
              selected: _pointBuyPool == pool,
              onSelected: (_) => setState(() => _pointBuyPool = pool),
            ),
          )),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: remaining < 0 ? Colors.red.shade50 : Colors.green.shade50,
              border: Border.all(
                  color: remaining < 0 ? Colors.red : Colors.green),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('$remaining pts remaining',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: remaining < 0 ? Colors.red.shade700 : Colors.green.shade700)),
          ),
        ]),
        const SizedBox(height: 8),
        // Stat rows with +/- buttons
        for (int i = 0; i < statKeys.length && i < statObjects.length; i++) ...[
          _buildPointBuyRow(character, statKeys[i], statObjects[i],
              scores[statKeys[i]]!, remaining),
          if (i < statKeys.length - 1) const Divider(height: 4),
        ],
      ],
    );
  }

  Widget _buildPointBuyRow(dynamic character, String statKey, PCStat statObj,
      int score, int remaining) {
    int racial = 0;
    int levelGains = 0;
    try { racial     = (character as dynamic).getRacialBonus(statObj)    as int? ?? 0; } catch (_) {}
    try { levelGains = (character as dynamic).getLevelStatGains(statObj) as int? ?? 0; } catch (_) {}

    final cost      = _pointBuyCostFor(score);
    final costUp    = score < 18 ? _pointBuyCostFor(score + 1) - cost : 999;
    final canInc    = score < 18 && costUp <= remaining;
    final canDec    = score > 8;
    final effective = score + racial + levelGains;
    final mod       = ((effective - 10) / 2).floor();

    void setScore(int newScore) {
      try {
        (character as dynamic).setScoreBase(statObj, newScore);
        currentCharacter.notifyListeners();
        setState(() {});
      } catch (_) {}
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        SizedBox(width: 40, child: Text(statKey,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline, size: 18),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          onPressed: canDec ? () => setScore(score - 1) : null,
        ),
        SizedBox(
          width: 36,
          child: Text('$score',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline, size: 18),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          onPressed: canInc ? () => setScore(score + 1) : null,
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 38,
          child: Text('(${cost}pt)',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
        ),
        if (racial != 0 || levelGains != 0) ...[
          const SizedBox(width: 4),
          Text('→ $effective',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
        const SizedBox(width: 8),
        Text(mod >= 0 ? '+$mod' : '$mod',
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold,
                color: mod >= 0 ? Colors.green.shade700 : Colors.red.shade700)),
      ]),
    );
  }

  // ---- Standard Array / Roll controls --------------------------------------

  Widget _buildPoolControls(dynamic character, List<String> statKeys, List<PCStat> statObjects) {
    final sortedPool = List.of(_poolValues)..sort((a, b) => b.compareTo(a));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pool chips + roll/reset button
        Row(children: [
          const Text('Available: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          Expanded(
            child: Wrap(
              spacing: 4, runSpacing: 4,
              children: sortedPool.map((v) => Chip(
                label: Text('$v', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                padding: const EdgeInsets.symmetric(horizontal: 4),
              )).toList(),
            ),
          ),
          if (_statMode == _StatMode.roll) ...[
            const SizedBox(width: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.casino, size: 14),
              label: const Text('Reroll', style: TextStyle(fontSize: 12)),
              onPressed: () {
                setState(() {
                  _initAssignmentMode(statKeys, _StatMode.roll);
                  // Clear current assignments from character
                  for (int i = 0; i < statKeys.length && i < statObjects.length; i++) {
                    try { (character as dynamic).setScoreBase(statObjects[i], 10); } catch (_) {}
                  }
                  currentCharacter.notifyListeners();
                });
              },
            ),
          ],
          const SizedBox(width: 4),
          TextButton(
            onPressed: () {
              setState(() {
                _assignments.clear();
                if (_statMode == _StatMode.standardArray) {
                  _poolValues = List.of(_kStandardArray);
                } else {
                  _poolValues = List.of(_rolledScores);
                }
                for (final k in statKeys) _assignments[k] = null;
                for (int i = 0; i < statKeys.length && i < statObjects.length; i++) {
                  try { (character as dynamic).setScoreBase(statObjects[i], 10); } catch (_) {}
                }
                currentCharacter.notifyListeners();
              });
            },
            child: const Text('Clear', style: TextStyle(fontSize: 12)),
          ),
        ]),
        const SizedBox(height: 8),
        // Stat assignment rows
        for (int i = 0; i < statKeys.length; i++) ...[
          _buildAssignmentRow(character, statKeys, statObjects, statKeys[i],
              i < statObjects.length ? statObjects[i] : null, sortedPool),
          if (i < statKeys.length - 1) const Divider(height: 4),
        ],
        if (_poolValues.isEmpty && _assignments.values.every((v) => v != null))
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('✓ All stats assigned',
                style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }

  Widget _buildAssignmentRow(dynamic character, List<String> statKeys,
      List<PCStat> statObjects, String statKey, PCStat? statObj, List<int> sortedPool) {
    final assigned = _assignments[statKey];
    int racial = 0;
    int levelGains = 0;
    if (statObj != null) {
      try { racial     = (character as dynamic).getRacialBonus(statObj)    as int? ?? 0; } catch (_) {}
      try { levelGains = (character as dynamic).getLevelStatGains(statObj) as int? ?? 0; } catch (_) {}
    }
    final effective = (assigned ?? 10) + racial + levelGains;
    final mod = ((effective - 10) / 2).floor();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        SizedBox(width: 40,
            child: Text(statKey,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
        const SizedBox(width: 8),
        // Dropdown to pick from available pool
        DropdownButton<int>(
          value: assigned,
          hint: const Text('—', style: TextStyle(fontSize: 12)),
          isDense: true,
          items: [
            if (assigned != null)
              DropdownMenuItem(
                value: assigned,
                child: Text('$assigned (clear)',
                    style: const TextStyle(fontSize: 12)),
              ),
            ...sortedPool.where((v) => v != assigned).map((v) =>
              DropdownMenuItem(
                value: v,
                child: Text('$v', style: const TextStyle(fontSize: 12)),
              )),
          ],
          onChanged: (v) {
            if (v == assigned) {
              _clearAssignment(character, statObjects, statKeys, statKey);
            } else if (v != null) {
              _assignValue(character, statObjects, statKeys, statKey, v);
            }
          },
        ),
        const SizedBox(width: 12),
        if (assigned != null) ...[
          if (racial != 0 || levelGains != 0) ...[
            Text('→ $effective',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
          ],
          Text(mod >= 0 ? '+$mod' : '$mod',
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold,
                  color: mod >= 0 ? Colors.green.shade700 : Colors.red.shade700)),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.clear, size: 14),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
            onPressed: () => _clearAssignment(character, statObjects, statKeys, statKey),
          ),
        ] else
          Text('—', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
      ]),
    );
  }

  // ---- Combat section -------------------------------------------------------

  Widget _buildCombatSection(dynamic character, List<String> statKeys, List<PCStat> statObjects) {
    final dataset = loadedDataSet.value;
    final dexMod = _getStatMod(character, statKeys, statObjects, 'DEX');
    final bab    = _computeBab(character, dataset);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Combat', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(children: [
              _combatChip('Initiative', _fmtMod(dexMod)),
              const SizedBox(width: 12),
              _combatChip('BAB', _babSequence(bab)),
              const SizedBox(width: 12),
              _combatChip('AC', '${10 + dexMod}'),
            ]),
          ],
        ),
      ),
    );
  }

  String _babSequence(int bab) {
    if (bab <= 0) return '+0';
    if (bab < 6) return '+$bab';
    final attacks = <String>[];
    int current = bab;
    while (current > 0) { attacks.add('+$current'); current -= 5; }
    return attacks.join('/');
  }

  int _computeBab(dynamic character, DataSet? dataset) {
    List classLevels = [];
    try { classLevels = ((character as dynamic).toJson()['classLevels'] as List?) ?? []; } catch (_) {}
    if (classLevels.isEmpty) return 0;
    final classes = dataset?.classes ?? const <PCClass>[];
    final counts = <String, int>{};
    for (final l in classLevels) {
      if (l is Map) { final k = l['classKey'] as String? ?? ''; counts[k] = (counts[k] ?? 0) + 1; }
    }
    double total = 0.0;
    for (final entry in counts.entries) {
      final cls = classes.where((c) => c.getKeyName() == entry.key).firstOrNull;
      final bab = cls?.getBabProgression() ?? '';
      total += entry.value * (bab == 'Full' ? 1.0 : bab == 'Half' ? 0.5 : 0.75);
    }
    return total.floor();
  }

  Widget _combatChip(String label, String value) {
    return Column(children: [
      Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      const SizedBox(height: 2),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(6)),
        child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    ]);
  }

  // ---- Saves section --------------------------------------------------------

  int _getStatMod(dynamic character, List<String> statKeys,
      List<PCStat> statObjects, String key) {
    final idx = statKeys.indexOf(key);
    if (idx >= 0 && idx < statObjects.length) {
      try { return (character as dynamic).getModTotal(statObjects[idx]) as int? ?? 0; } catch (_) {}
    }
    return 0;
  }

  String _fmtMod(int v) => v >= 0 ? '+$v' : '$v';

  Widget _buildSavesSection(dynamic character, List<String> statKeys,
      List<PCStat> statObjects, DataSet? dataset) {
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

  int _computeSave(String saveName, String statAbb, dynamic character,
      List<String> statKeys, List<PCStat> statObjects, DataSet? dataset) {
    final statMod = _getStatMod(character, statKeys, statObjects, statAbb);
    if (dataset == null) return statMod;
    List classLevels = [];
    try { classLevels = ((character as dynamic).toJson()['classLevels'] as List?) ?? []; } catch (_) {}
    if (classLevels.isEmpty) return statMod;
    final counts = <String, int>{};
    for (final l in classLevels) {
      if (l is Map) { final k = l['classKey'] as String? ?? ''; counts[k] = (counts[k] ?? 0) + 1; }
    }
    double base = 0;
    bool hasGood = false;
    for (final entry in counts.entries) {
      final cls = dataset.classes.where((c) => c.getKeyName() == entry.key).firstOrNull;
      final isGood = cls?.isSaveGood(saveName) ?? false;
      if (isGood) {
        base += entry.value / 2;
        if (!hasGood) { base += 2; hasGood = true; }
      } else {
        base += entry.value / 3;
      }
    }
    return base.floor() + statMod;
  }

  Widget _saveChip(String label, String value) {
    return Column(children: [
      Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      const SizedBox(height: 2),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(6)),
        child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    ]);
  }

  // ---- Class level section --------------------------------------------------

  Widget _buildClassLevelSection(dynamic character) {
    final summary = _classLevelSummary(character);
    int totalLevel = 0;
    try { totalLevel = (character as dynamic).getTotalCharacterLevel() as int? ?? 0; } catch (_) {}
    int currentHp = 0, maxHp = 0;
    try { currentHp = (character as dynamic).getHP()    as int? ?? 0; } catch (_) {}
    try { maxHp     = (character as dynamic).getMaxHP() as int? ?? 0; } catch (_) {}

    if (!_hpEditPending && _hpController.text != '$currentHp') {
      _hpController.text = '$currentHp';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Level & HP', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _labelledValue('Total Level', '$totalLevel'),
            if (summary.isNotEmpty) _labelledValue('Classes', summary),
            const SizedBox(height: 4),
            _buildXPRow(character, totalLevel),
            const SizedBox(height: 8),
            Row(children: [
              const SizedBox(width: 80,
                  child: Text('HP:', style: TextStyle(fontWeight: FontWeight.bold))),
              SizedBox(
                width: 52,
                child: TextField(
                  controller: _hpController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(), isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    hintText: 'cur',
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
                  onEditingComplete: () {
                    _hpEditPending = false;
                    final n = int.tryParse(_hpController.text);
                    if (n != null) {
                      try { (character as dynamic).setHP(n); } catch (_) {}
                      currentCharacter.notifyListeners();
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text('/ $maxHp max',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ),
              if (maxHp > 0)
                Tooltip(
                  message: 'Restore to full ($maxHp HP)',
                  child: TextButton.icon(
                    icon: const Icon(Icons.favorite, size: 14, color: Colors.green),
                    label: const Text('Full', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                    onPressed: () {
                      _hpEditPending = false;
                      try { (character as dynamic).setHP(maxHp); } catch (_) {}
                      currentCharacter.notifyListeners();
                      setState(() {});
                    },
                  ),
                ),
              if (maxHp == 0 && totalLevel > 0)
                Text('(set HP in Class tab)',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500,
                        fontStyle: FontStyle.italic)),
            ]),
          ],
        ),
      ),
    );
  }

  // ---- XP row ---------------------------------------------------------------

  static const List<int> _kXpTable = [
    0, 1000, 3000, 6000, 10000, 15000, 21000, 28000, 36000, 45000,
    55000, 66000, 78000, 91000, 105000, 120000, 136000, 153000, 171000, 190000,
  ];

  int _xpForLevel(int level) {
    if (level <= 0) return 0;
    if (level - 1 < _kXpTable.length) return _kXpTable[level - 1];
    return _kXpTable.last + (level - _kXpTable.length) * 21000;
  }

  Widget _buildXPRow(dynamic character, int totalLevel) {
    int xp = 0;
    try { xp = (character as dynamic).getXP() as int? ?? 0; } catch (_) {}
    final currentThreshold = _xpForLevel(totalLevel);
    final nextThreshold    = _xpForLevel(totalLevel + 1);
    final xpInLevel        = xp - currentThreshold;
    final xpNeeded         = nextThreshold - currentThreshold;
    final readyToLevel     = xp >= nextThreshold;

    return Row(children: [
      const SizedBox(width: 80, child: Text('XP:', style: TextStyle(fontWeight: FontWeight.bold))),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('$xp', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(' / $nextThreshold',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            if (readyToLevel)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Text('★ Ready to level up!',
                    style: TextStyle(color: Colors.amber,
                        fontWeight: FontWeight.bold, fontSize: 12)),
              ),
          ]),
          SizedBox(
            width: 160, height: 5,
            child: LinearProgressIndicator(
              value: xpNeeded > 0 ? (xpInLevel / xpNeeded).clamp(0.0, 1.0) : 1.0,
              backgroundColor: Colors.grey.shade300,
              color: readyToLevel ? Colors.amber : null,
            ),
          ),
        ],
      ),
      const SizedBox(width: 8),
      SizedBox(
        width: 72,
        child: TextField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: '+XP', border: OutlineInputBorder(), isDense: true,
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
    ]);
  }

  // ---- Helpers --------------------------------------------------------------

  Widget _labelledValue(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        SizedBox(width: 80,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold))),
        Expanded(child: Text(value)),
      ]),
    );
  }
}

// ---- Progress item data class ----------------------------------------------

class _ProgressItem {
  final String label;
  final bool done;
  final String detail;
  const _ProgressItem(this.label, this.done, this.detail);
}

// ---- Editable integer field for ability score input ----------------------

class _StatScoreField extends StatefulWidget {
  final int initialValue;
  final ValueChanged<int> onChanged;

  const _StatScoreField({super.key, required this.initialValue, required this.onChanged});

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
    if (parsed != null) widget.onChanged(parsed.clamp(1, 30));
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
          border: OutlineInputBorder(), isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        ),
        onSubmitted: (_) => _commit(),
        onEditingComplete: _commit,
      ),
    );
  }
}
