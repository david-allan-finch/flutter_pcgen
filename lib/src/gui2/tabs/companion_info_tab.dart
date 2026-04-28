// Translation of pcgen.gui2.tabs.CompanionInfoTab

import 'package:flutter/material.dart';
import 'package:flutter_pcgen/src/gui2/app_state.dart';

/// Tab panel for managing character companions (animal companion, familiar, etc.).
class CompanionInfoTab extends StatefulWidget {
  const CompanionInfoTab({super.key});

  @override
  State<CompanionInfoTab> createState() => CompanionInfoTabState();
}

class CompanionInfoTabState extends State<CompanionInfoTab> {
  dynamic _character;

  void setCharacter(dynamic character) => setState(() => _character = character);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: currentCharacter,
      builder: (context, character, _) {
        final companions = _getCompanions(character);
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  const Text('Companions',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Spacer(),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add'),
                    onPressed: character == null
                        ? null
                        : () => _showAddCompanionDialog(context, character),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: companions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.pets, size: 48, color: Colors.grey),
                          const SizedBox(height: 8),
                          Text(
                            character == null
                                ? 'No character selected.'
                                : 'No companions yet.\nAdd an animal companion, familiar, or mount.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.grey, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: companions.length,
                      itemBuilder: (context, i) {
                        final comp = companions[i];
                        final name = comp['name'] as String? ?? 'Companion';
                        final type = comp['type'] as String? ?? 'Companion';
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: ListTile(
                            leading: const Icon(Icons.pets),
                            title: Text(name),
                            subtitle: Text(type),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: character == null
                                  ? null
                                  : () {
                                      _removeCompanion(character, i);
                                    },
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

  List<Map<String, dynamic>> _getCompanions(dynamic character) {
    if (character == null) return [];
    try {
      final data = (character as dynamic).toJson() as Map<String, dynamic>;
      final list = data['companions'];
      if (list is List) return list.cast<Map<String, dynamic>>();
    } catch (_) {}
    return [];
  }

  void _removeCompanion(dynamic character, int index) {
    try {
      final data = (character as dynamic).toJson() as Map<String, dynamic>;
      final list = data['companions'] as List?;
      if (list != null && index < list.length) {
        list.removeAt(index);
        currentCharacter.notifyListeners();
        setState(() {});
      }
    } catch (_) {}
  }

  void _showAddCompanionDialog(BuildContext context, dynamic character) {
    final nameController = TextEditingController();
    String type = 'Animal Companion';
    final types = ['Animal Companion', 'Familiar', 'Mount', 'Special Mount', 'Other'];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Add Companion'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Companion name (e.g. Rex)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButton<String>(
                isExpanded: true,
                value: type,
                items: types
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setS(() => type = v ?? type),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  _addCompanion(character, nameController.text, type);
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

  void _addCompanion(dynamic character, String name, String type) {
    try {
      final data = (character as dynamic).toJson() as Map<String, dynamic>;
      final list = (data['companions'] ??= <Map<String, dynamic>>[]) as List;
      list.add({'name': name, 'type': type});
      currentCharacter.notifyListeners();
      setState(() {});
    } catch (_) {}
  }
}
