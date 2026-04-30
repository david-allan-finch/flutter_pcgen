// Translation of pcgen.gui2.tabs.AbilitiesInfoTab

import 'package:flutter/material.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/string_key.dart';
import 'package:flutter_pcgen/src/core/ability.dart';
import 'package:flutter_pcgen/src/core/data_set.dart';
import 'package:flutter_pcgen/src/core/pc_class.dart';
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
            final featBudget = _computeFeatBudget(character, dataset);
            final featUsed   = character != null
                ? (_getSelectedKeys(character, 'FEAT')).length
                : 0;

            return Column(
              children: [
                TabBar(
                  controller: _catTabController,
                  isScrollable: true,
                  tabs: _kCategories.map((c) => Tab(text: c)).toList(),
                ),
                // Feat budget bar — only show on FEAT tab
                AnimatedBuilder(
                  animation: _catTabController,
                  builder: (context, _) {
                    if (_catTabController.index != 0) return const SizedBox.shrink();
                    final remaining = featBudget - featUsed;
                    final over = remaining < 0;
                    return Container(
                      color: over
                          ? Colors.red.shade50
                          : remaining == 0
                              ? Colors.green.shade50
                              : null,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      child: Row(children: [
                        Text(
                          'Feats: $featUsed / $featBudget used',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: over
                                  ? Colors.red.shade700
                                  : remaining == 0
                                      ? Colors.green.shade700
                                      : Colors.grey.shade700),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: featBudget > 0
                                ? (featUsed / featBudget).clamp(0.0, 1.0)
                                : 0,
                            backgroundColor: Colors.grey.shade200,
                            color: over
                                ? Colors.red
                                : remaining == 0
                                    ? Colors.green
                                    : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        if (over)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              '${-remaining} over budget',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.red.shade700),
                            ),
                          )
                        else if (remaining > 0)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              '$remaining remaining',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600),
                            ),
                          ),
                      ]),
                    );
                  },
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

  // 3.5e feat budget:
  //   • 1 feat at level 1, then every 3 character levels (3, 6, 9, 12…)
  //   • Humans get 1 bonus feat
  //   • Fighters get 1 bonus feat at level 1 and every 2 fighter levels (2, 4, 6…)
  //   • Wizards get 1 bonus metamagic/item-creation feat at level 5, 10, 15, 20
  int _computeFeatBudget(dynamic character, DataSet? dataset) {
    if (character == null) return 0;

    List classLevels = [];
    String raceKey = '';
    try {
      final data = (character as dynamic).toJson() as Map<String, dynamic>;
      classLevels = data['classLevels'] as List? ?? [];
      raceKey = data['raceKey'] as String? ?? '';
    } catch (_) {}

    final totalLevel = classLevels.length;
    if (totalLevel == 0) return 1; // even a level-0 character gets 1 feat eventually

    // Base feats: 1 at level 1, then +1 every 3 levels
    int feats = 1 + (totalLevel / 3).floor();

    // Racial bonus feat (Human, Half-Human races in 3.5e)
    final raceKeyLower = raceKey.toLowerCase();
    if (raceKeyLower.contains('human') && !raceKeyLower.contains('halfhuman') == false ||
        raceKeyLower == 'human' ||
        raceKeyLower.startsWith('human_')) {
      feats += 1;
    }

    // Class bonus feats
    final classes = dataset?.classes ?? const <PCClass>[];
    final counts = <String, int>{};
    for (final l in classLevels) {
      if (l is Map) {
        final k = l['classKey'] as String? ?? '';
        counts[k] = (counts[k] ?? 0) + 1;
      }
    }
    for (final entry in counts.entries) {
      final cls = classes.where((c) => c.getKeyName() == entry.key).firstOrNull;
      if (cls == null) continue;
      final clsName = cls.getDisplayName().toLowerCase();
      final lvl = entry.value;
      if (clsName.contains('fighter')) {
        // Fighter: 1 bonus feat at lvl 1, then every 2 levels
        feats += 1 + ((lvl - 1) / 2).floor();
      } else if (clsName.contains('wizard')) {
        // Wizard: bonus feat at 5, 10, 15, 20
        feats += (lvl / 5).floor();
      }
    }

    return feats;
  }
}
