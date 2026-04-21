// Translation of pcgen.gui2.tabs.spells.SpellsPreparedTab

import 'package:flutter/material.dart';

/// Tab showing spells the character has prepared (memorized) for the day.
class SpellsPreparedTab extends StatefulWidget {
  final dynamic character;

  const SpellsPreparedTab({super.key, this.character});

  @override
  State<SpellsPreparedTab> createState() => _SpellsPreparedTabState();
}

class _PreparedSpell {
  final String name;
  final int level;
  int count;
  _PreparedSpell({required this.name, required this.level, this.count = 1});
}

class _SpellsPreparedTabState extends State<SpellsPreparedTab> {
  final List<_PreparedSpell> _prepared = [];

  void _addSlot(String name, int level) {
    setState(() {
      final existing = _prepared.where((s) => s.name == name).firstOrNull;
      if (existing != null) {
        existing.count++;
      } else {
        _prepared.add(_PreparedSpell(name: name, level: level));
      }
    });
  }

  void _removeSlot(int index) {
    setState(() {
      final spell = _prepared[index];
      if (spell.count > 1) {
        spell.count--;
      } else {
        _prepared.removeAt(index);
      }
    });
  }

  Map<int, List<_PreparedSpell>> get _byLevel {
    final result = <int, List<_PreparedSpell>>{};
    for (final spell in _prepared) {
      result.putIfAbsent(spell.level, () => []).add(spell);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final byLevel = _byLevel;
    return Column(
      children: [
        Expanded(
          child: _prepared.isEmpty
              ? const Center(child: Text('No spells prepared'))
              : ListView(
                  children: byLevel.entries.map((entry) {
                    return ExpansionTile(
                      initiallyExpanded: true,
                      title: Text('Level ${entry.key}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      children: entry.value.asMap().entries.map((e) {
                        final idx = _prepared.indexOf(e.value);
                        return ListTile(
                          title: Text(e.value.name),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('x${e.value.count}'),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline,
                                    size: 18),
                                onPressed: () => _removeSlot(idx),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  }).toList(),
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () => setState(() => _prepared.clear()),
                child: const Text('Clear All'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
