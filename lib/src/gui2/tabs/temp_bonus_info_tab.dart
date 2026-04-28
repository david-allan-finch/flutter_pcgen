// Translation of pcgen.gui2.tabs.TempBonusInfoTab

import 'package:flutter/material.dart';
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
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                'Temporary bonuses track spell effects, conditions, and other '
                'situational modifiers. They are not yet factored into combat stats.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
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

  void _showAddBonusDialog(BuildContext context, dynamic character) {
    final nameController = TextEditingController();
    final valueController = TextEditingController(text: '+2');
    String stat = 'AC';
    final stats = ['AC', 'ATK', 'DAM', 'SAVE', 'SKILL', 'ABILITY', 'OTHER'];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Add Temporary Bonus'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Source (e.g. Bless, Bull\'s Strength)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: stat,
                    items: stats.map((s) =>
                        DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (v) => setS(() => stat = v ?? stat),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: valueController,
                    decoration: const InputDecoration(
                      labelText: 'Value',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ]),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  _addBonus(character, nameController.text, stat, valueController.text);
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _addBonus(dynamic character, String name, String stat, String value) {
    try {
      final data = (character as dynamic).toJson() as Map<String, dynamic>;
      final list = (data['tempBonuses'] ??= <Map<String, dynamic>>[]) as List;
      list.add({'name': name, 'stat': stat, 'value': value, 'active': true});
      currentCharacter.notifyListeners();
      setState(() {});
    } catch (_) {}
  }
}
