// Translation of pcgen.gui2.tabs.TempBonusInfoTab

import 'package:flutter/material.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/string_key.dart';
import 'package:flutter_pcgen/src/core/data_set.dart';
import 'package:flutter_pcgen/src/gui2/app_state.dart';

/// Tab for applying temporary bonuses (spells, conditions, etc.).
class TempBonusInfoTab extends StatefulWidget {
  const TempBonusInfoTab({super.key});

  @override
  State<TempBonusInfoTab> createState() => TempBonusInfoTabState();
}

class TempBonusInfoTabState extends State<TempBonusInfoTab> {
  dynamic _character;
  void setCharacter(dynamic character) => setState(() => _character = character);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: currentCharacter,
      builder: (context, character, _) {
        final bonuses = _getBonuses(character);
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  const Text('Temporary Bonuses',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Spacer(),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add'),
                    onPressed: character == null
                        ? null
                        : () => _showAddBonusDialog(context, character),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Ability-sourced temp bonuses
            ValueListenableBuilder<DataSet?>(
              valueListenable: loadedDataSet,
              builder: (ctx, dataset, _) {
                final availableTb = _getAbilityTempBonuses(character, dataset);
                if (availableTb.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(8, 6, 8, 2),
                      child: Text('From Abilities:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    ...availableTb.map((tb) {
                      final name = tb['name'] as String;
                      final desc = tb['desc'] as String? ?? '';
                      final isActive = _isTempBonusActive(character, name);
                      return CheckboxListTile(
                        dense: true,
                        title: Text(name, style: const TextStyle(fontSize: 12)),
                        subtitle: desc.isNotEmpty ? Text(desc, style: const TextStyle(fontSize: 10)) : null,
                        value: isActive,
                        onChanged: character == null ? null : (v) => _toggleAbilityTempBonus(character, tb, v ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      );
                    }),
                    const Divider(height: 1),
                  ],
                );
              },
            ),
            Expanded(
              child: bonuses.isEmpty
                  ? const Center(
                      child: Text('No temporary bonuses active.',
                          style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)))
                  : ListView.builder(
                      itemCount: bonuses.length,
                      itemBuilder: (context, i) {
                        final bonus = bonuses[i];
                        final name = bonus['name'] as String? ?? 'Bonus';
                        final value = bonus['value'] as String? ?? '+0';
                        final stat = bonus['stat'] as String? ?? '';
                        final active = bonus['active'] as bool? ?? true;
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          child: ListTile(
                            dense: true,
                            leading: Checkbox(
                              value: active,
                              onChanged: character == null
                                  ? null
                                  : (v) => _toggleBonus(character, i, v ?? false),
                            ),
                            title: Text(name,
                                style: TextStyle(
                                    decoration: active ? null : TextDecoration.lineThrough,
                                    color: active ? null : Colors.grey)),
                            subtitle: Text('$stat $value'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  size: 16, color: Colors.red),
                              onPressed: character == null
                                  ? null
                                  : () => _removeBonus(character, i),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  List<Map<String, dynamic>> _getBonuses(dynamic character) {
    if (character == null) return [];
    try {
      final data = (character as dynamic).toJson() as Map<String, dynamic>;
      final list = data['tempBonuses'];
      if (list is List) return list.cast<Map<String, dynamic>>();
    } catch (_) {}
    return [];
  }

  void _toggleBonus(dynamic character, int index, bool active) {
    try {
      final data = (character as dynamic).toJson() as Map<String, dynamic>;
      final list = data['tempBonuses'] as List?;
      if (list != null && index < list.length) {
        list[index]['active'] = active;
        currentCharacter.notifyListeners();
        setState(() {});
      }
    } catch (_) {}
  }

  void _removeBonus(dynamic character, int index) {
    try {
      final data = (character as dynamic).toJson() as Map<String, dynamic>;
      final list = data['tempBonuses'] as List?;
      if (list != null && index < list.length) {
        list.removeAt(index);
        currentCharacter.notifyListeners();
        setState(() {});
      }
    } catch (_) {}
  }

  // Category → available targets
  static const _kBonusTypes = {
    'COMBAT':  ['AC', 'BASEAB', 'TOHIT', 'DAMAGE', 'INITIATIVE'],
    'SAVE':    ['ALL', 'Fortitude', 'Reflex', 'Will'],
    'STAT':    ['STR', 'DEX', 'CON', 'INT', 'WIS', 'CHA'],
    'SKILL':   ['ALL'],
    'HP':      ['CURRENTMAX'],
  };
  static const _kBonusSubtypes = [
    'Morale', 'Luck', 'Competence', 'Circumstance', 'Insight',
    'Resistance', 'Sacred', 'Profane', 'Enhancement', 'Dodge',
    '', // untyped (stacks)
  ];

  void _showAddBonusDialog(BuildContext context, dynamic character) {
    final nameCtrl  = TextEditingController();
    final valueCtrl = TextEditingController(text: '2');
    String category  = 'COMBAT';
    String target    = 'AC';
    String bonusType = 'Morale';

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) {
          final targets = _kBonusTypes[category] ?? ['AC'];
          if (!targets.contains(target)) target = targets.first;
          return AlertDialog(
            title: const Text('Add Temporary Bonus'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Source (e.g. Bless, Bull\'s Strength)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: category,
                        decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder(), isDense: true),
                        items: _kBonusTypes.keys.map((c) =>
                            DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (v) => setS(() { category = v!; target = _kBonusTypes[v]!.first; }),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: targets.contains(target) ? target : targets.first,
                        decoration: const InputDecoration(labelText: 'Target', border: OutlineInputBorder(), isDense: true),
                        items: targets.map((t) =>
                            DropdownMenuItem(value: t, child: Text(t))).toList(),
                        onChanged: (v) => setS(() => target = v!),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: bonusType,
                        decoration: const InputDecoration(labelText: 'Bonus Type', border: OutlineInputBorder(), isDense: true),
                        items: _kBonusSubtypes.map((t) =>
                            DropdownMenuItem(value: t, child: Text(t.isEmpty ? 'Untyped (stacks)' : t))).toList(),
                        onChanged: (v) => setS(() => bonusType = v!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 80,
                      child: TextField(
                        controller: valueCtrl,
                        keyboardType: const TextInputType.numberWithOptions(signed: true),
                        decoration: const InputDecoration(labelText: 'Value', border: OutlineInputBorder(), isDense: true),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  if (nameCtrl.text.isNotEmpty) {
                    _addBonus(character, nameCtrl.text, category, target,
                        valueCtrl.text.replaceAll('+', ''), bonusType);
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _addBonus(dynamic character, String name, String category,
      String target, String value, String bonusType) {
    try {
      final data = (character as dynamic).toJson() as Map<String, dynamic>;
      final list = (data['tempBonuses'] ??= <Map<String, dynamic>>[]) as List;
      list.add({
        'name': name,
        'category': category,
        'target': target,
        'stat': '$category|$target',
        'value': value,
        'bonusType': bonusType,
        'active': true,
      });
      currentCharacter.notifyListeners();
      setState(() {});
    } catch (_) {}
  }

  /// Collect TEMPBONUS entries from selected abilities.
  List<Map<String, dynamic>> _getAbilityTempBonuses(dynamic character, DataSet? dataset) {
    final result = <Map<String, dynamic>>[];
    if (character == null || dataset == null) return result;
    try {
      final data = (character as dynamic).toJson() as Map;
      final selected = data['selectedAbilities'] as Map? ?? {};
      final allKeys = <String>[];
      for (final cat in selected.values) {
        if (cat is List) allKeys.addAll(cat.map((e) => e.toString().split('|').first));
      }
      final allAbilities = dataset.getAllAbilities();
      for (final ab in allAbilities) {
        if (!allKeys.contains((ab as dynamic).getKeyName())) continue;
        final tbList = (ab as dynamic)
            .getSafeListFor(ListKey.getConstant<String>('TEMP_BONUS')) as List?;
        if (tbList == null || tbList.isEmpty) continue;
        final name = (ab as dynamic).getDisplayName() as String? ?? '';
        String desc = '';
        try { desc = (ab as dynamic).getString(StringKey.tempDescription) as String? ?? ''; } catch (_) {}
        result.add({'name': name, 'desc': desc, 'bonuses': tbList});
      }
    } catch (_) {}
    return result;
  }

  bool _isTempBonusActive(dynamic character, String name) {
    try {
      final data = (character as dynamic).toJson() as Map;
      final list = data['tempBonuses'] as List? ?? [];
      return list.any((b) => b is Map && b['name'] == name && (b['active'] as bool? ?? true));
    } catch (_) { return false; }
  }

  void _toggleAbilityTempBonus(dynamic character, Map<String, dynamic> tb, bool active) {
    try {
      final name = tb['name'] as String;
      final data = (character as dynamic).toJson() as Map<String, dynamic>;
      final list = (data['tempBonuses'] ??= <Map<String, dynamic>>[]) as List;
      // Remove existing entry with this name
      list.removeWhere((b) => b is Map && b['name'] == name);
      if (active) {
        // Parse each TEMPBONUS entry and add to list
        final bonuses = tb['bonuses'] as List? ?? [];
        for (final raw in bonuses) {
          if (raw is! String) continue;
          // Format: ANYPC|CATEGORY|TARGET|VALUE[|TYPE=...]
          final parts = raw.split('|');
          if (parts.length < 4) continue;
          final category  = parts[1];
          final target    = parts[2];
          final value     = parts[3];
          String bonusType = '';
          for (final p in parts.skip(4)) {
            if (p.toUpperCase().startsWith('TYPE=')) bonusType = p.substring(5);
          }
          list.add({
            'name': name,
            'category': category,
            'target': target,
            'stat': '$category|$target',
            'value': value,
            'bonusType': bonusType,
            'active': true,
            'fromAbility': true,
          });
        }
      }
      currentCharacter.notifyListeners();
      setState(() {});
    } catch (_) {}
  }
}
