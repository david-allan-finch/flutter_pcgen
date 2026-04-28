// Translation of pcgen.gui2.tabs.AbilitiesInfoTab

import 'package:flutter/material.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/string_key.dart';
import 'package:flutter_pcgen/src/core/ability.dart';
import 'package:flutter_pcgen/src/core/data_set.dart';
import 'package:flutter_pcgen/src/gui2/app_state.dart';

class AbilitiesInfoTab extends StatefulWidget {
  const AbilitiesInfoTab({super.key});

  @override
  State<AbilitiesInfoTab> createState() => AbilitiesInfoTabState();
}

class AbilitiesInfoTabState extends State<AbilitiesInfoTab>
    with SingleTickerProviderStateMixin {
  dynamic _character;
  late final TabController _catTabController;
  final TextEditingController _search = TextEditingController();

  static const _kCategories = ['FEAT', 'Special Ability', 'Class Ability'];

  void setCharacter(dynamic character) => setState(() => _character = character);

  @override
  void initState() {
    super.initState();
    _catTabController = TabController(length: _kCategories.length, vsync: this);
  }

  @override
  void dispose() {
    _catTabController.dispose();
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
                  controller: _catTabController,
                  isScrollable: true,
                  tabs: _kCategories.map((c) => Tab(text: c)).toList(),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    controller: _search,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Filter…',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _catTabController,
                    children: _kCategories.map((cat) {
                      final available =
                          dataset?.getAbilitiesByCategoryName(cat) ?? const <Ability>[];
                      return _buildCategoryView(character, available, cat);
                    }).toList(),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryView(
      dynamic character, List<Ability> available, String category) {
    final query = _search.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? available
        : available
            .where((a) => a.getDisplayName().toLowerCase().contains(query))
            .toList();

    final selectedKeys =
        character != null ? _getSelectedKeys(character, category) : const <String>[];

    if (available.isEmpty) {
      return Center(
          child: Text('No ${category.toLowerCase()} entries loaded.',
              style: const TextStyle(color: Colors.grey)));
    }

    return Row(
      children: [
        // Available panel
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text('Available (${filtered.length})',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final ability = filtered[i];
                    final isSelected =
                        selectedKeys.contains(ability.getKeyName());
                    String? desc;
                    try { desc = ability.getString(StringKey.description); } catch (_) {}
                    return ListTile(
                      dense: true,
                      title: Text(ability.getDisplayName(),
                          style: const TextStyle(fontSize: 12)),
                      subtitle: desc != null && desc.isNotEmpty
                          ? Text(desc,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 10, color: Colors.grey))
                          : null,
                      tileColor: isSelected
                          ? Colors.green.withOpacity(0.07)
                          : null,
                      trailing: isSelected
                          ? const Icon(Icons.check_circle,
                              color: Colors.green, size: 16)
                          : null,
                      onTap: character == null
                          ? null
                          : () {
                              if (isSelected) {
                                _removeAbility(
                                    character, category, ability.getKeyName());
                              } else {
                                _addAbility(
                                    character, category, ability.getKeyName());
                              }
                            },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        // Selected panel
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text('Selected (${selectedKeys.length})',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              Expanded(
                child: selectedKeys.isEmpty
                    ? const Center(
                        child: Text(
                            'Tap an entry on the left to select it.',
                            style: TextStyle(
                                color: Colors.grey,
                                fontStyle: FontStyle.italic)),
                      )
                    : ListView.builder(
                        itemCount: selectedKeys.length,
                        itemBuilder: (context, i) {
                          final key = selectedKeys[i];
                          final ability = available
                              .where((a) => a.getKeyName() == key)
                              .firstOrNull;
                          return ListTile(
                            dense: true,
                            title: Text(ability?.getDisplayName() ?? key,
                                style: const TextStyle(fontSize: 12)),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle_outline,
                                  size: 16, color: Colors.red),
                              onPressed: character == null
                                  ? null
                                  : () => _removeAbility(
                                      character, category, key),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<String> _getSelectedKeys(dynamic character, String category) {
    try {
      final result =
          (character as dynamic).getSelectedAbilityKeys(category);
      return result is List ? result.cast<String>() : [];
    } catch (_) {
      return [];
    }
  }

  void _addAbility(dynamic character, String category, String key) {
    try {
      (character as dynamic).addSelectedAbility(category, key);
      currentCharacter.notifyListeners();
      setState(() {});
    } catch (_) {}
  }

  void _removeAbility(dynamic character, String category, String key) {
    try {
      (character as dynamic).removeSelectedAbility(category, key);
      currentCharacter.notifyListeners();
      setState(() {});
    } catch (_) {}
  }
}
