// Translation of pcgen.gui2.tabs.spells.SpellsKnownTab

import 'package:flutter/material.dart';
import 'spell_tree_view_model.dart';

/// Tab showing spells the character knows (innate or learned).
class SpellsKnownTab extends StatefulWidget {
  final dynamic character;

  const SpellsKnownTab({super.key, this.character});

  @override
  State<SpellsKnownTab> createState() => _SpellsKnownTabState();
}

class _SpellsKnownTabState extends State<SpellsKnownTab> {
  final SpellTreeViewModel _model = SpellTreeViewModel();
  String _selectedView = SpellTreeViewModel.classView;

  static const List<String> _views = [
    SpellTreeViewModel.classView,
    SpellTreeViewModel.levelView,
    SpellTreeViewModel.schoolView,
    SpellTreeViewModel.descriptorView,
  ];

  @override
  Widget build(BuildContext context) {
    final grouped = _model.grouped;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              const Text('View by: '),
              DropdownButton<String>(
                value: _selectedView,
                items: _views
                    .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      _selectedView = v;
                      _model.setView(v);
                    });
                  }
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: grouped.isEmpty
              ? const Center(child: Text('No spells known'))
              : ListView(
                  children: grouped.entries.map((entry) {
                    return ExpansionTile(
                      title: Text(entry.key,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      children: entry.value
                          .map((spell) => ListTile(
                                title: Text(spell['name'] as String? ?? ''),
                                subtitle: Text(
                                    '${spell['school'] ?? ''} — Level ${spell['level'] ?? 0}'),
                              ))
                          .toList(),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }
}
