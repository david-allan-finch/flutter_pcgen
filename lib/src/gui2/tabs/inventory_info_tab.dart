// Translation of pcgen.gui2.tabs.InventoryInfoTab

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/object_key.dart' as cdom;
import 'package:flutter_pcgen/src/cdom/enumeration/string_key.dart';
import 'package:flutter_pcgen/src/core/data_set.dart';
import 'package:flutter_pcgen/src/core/equipment.dart';
import 'package:flutter_pcgen/src/gui2/app_state.dart';

class InventoryInfoTab extends StatefulWidget {
  const InventoryInfoTab({super.key});

  @override
  State<InventoryInfoTab> createState() => InventoryInfoTabState();
}

class InventoryInfoTabState extends State<InventoryInfoTab>
    with SingleTickerProviderStateMixin {
  dynamic _character;
  late final TabController _tabController;
  Equipment? _selected;
  final TextEditingController _search = TextEditingController();

  void setCharacter(dynamic character) => setState(() => _character = character);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
            final equipment = dataset?.equipment ?? const <Equipment>[];
            return Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Purchase'),
                    Tab(text: 'Carried Gear'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPurchaseTab(character, equipment),
                      _buildCarriedTab(character),
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

  IconData _categoryIcon(String cat) {
    switch (cat.toLowerCase()) {
      case 'weapon':   return Icons.sports_martial_arts;
      case 'armor':    return Icons.shield;
      case 'shield':   return Icons.shield_outlined;
      case 'ammunition': return Icons.arrow_forward;
      case 'goods':    return Icons.shopping_bag;
      case 'magic':    return Icons.auto_fix_high;
      case 'potion':   return Icons.local_drink;
      case 'scroll':   return Icons.description;
      case 'ring':     return Icons.circle_outlined;
      case 'wand':     return Icons.architecture;
      case 'rod':      return Icons.linear_scale;
      case 'staff':    return Icons.linear_scale;
      default:         return Icons.inventory_2_outlined;
    }
  }

  /// Extract the primary TYPE category from an equipment item.
  String _primaryType(Equipment item) {
    try {
      final tl = item.getSafeListFor(ListKey.getConstant<String>('TYPE'));
      if (tl.isNotEmpty) {
        final first = tl.cast<String>().first;
        // Strip RACETYPE:/RACESUBTYPE: prefixes stored by generic_loader
        if (first.startsWith('RACETYPE:') || first.startsWith('RACESUBTYPE:')) {
          return tl.cast<String>().skip(1).firstWhere(
            (t) => !t.startsWith('RACETYPE:') && !t.startsWith('RACESUBTYPE:'),
            orElse: () => 'Other',
          );
        }
        return first;
      }
    } catch (_) {}
    return 'Other';
  }

  Widget _buildPurchaseTab(dynamic character, List<Equipment> equipment) {
    final query = _search.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? equipment
        : equipment
            .where((e) => e.getDisplayName().toLowerCase().contains(query))
            .toList();

    // Group by primary type, sorted alphabetically within each group
    final grouped = <String, List<Equipment>>{};
    for (final item in filtered) {
      final cat = _primaryType(item);
      grouped.putIfAbsent(cat, () => []).add(item);
    }
    // Sort categories; sort items within each category
    final categories = grouped.keys.toList()..sort();
    for (final cat in categories) {
      grouped[cat]!.sort((a, b) =>
          a.getDisplayName().toLowerCase().compareTo(b.getDisplayName().toLowerCase()));
    }

    return Row(
      children: [
        // Available equipment tree
        Expanded(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: _search,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Filter equipment…',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${filtered.length} items in ${categories.length} categories',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
              ),
              Expanded(
                child: equipment.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'No equipment loaded.\n\nAdd equipment data to your campaign\'s equipment LST files.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ))
                    : ListView.builder(
                        itemCount: categories.length,
                        itemBuilder: (context, ci) {
                          final cat = categories[ci];
                          final items = grouped[cat]!;
                          // Auto-expand when searching
                          return ExpansionTile(
                            key: PageStorageKey('eq_cat_$cat'),
                            initiallyExpanded: query.isNotEmpty || categories.length <= 5,
                            tilePadding: const EdgeInsets.symmetric(horizontal: 8),
                            leading: Icon(_categoryIcon(cat), size: 18),
                            title: Text(cat,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13)),
                            trailing: Text('${items.length}',
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey)),
                            children: items.map((item) {
                              String cost = '';
                              try { cost = item.getString(StringKey.cost) ?? ''; } catch (_) {}
                              return ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.only(
                                    left: 32, right: 8),
                                selected: _selected == item,
                                selectedTileColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer
                                    .withAlpha(80),
                                title: Text(item.getDisplayName(),
                                    style: const TextStyle(fontSize: 12)),
                                trailing: cost.isNotEmpty
                                    ? Text('$cost gp',
                                        style: const TextStyle(
                                            fontSize: 11, color: Colors.grey))
                                    : null,
                                onTap: () => setState(() => _selected = item),
                              );
                            }).toList(),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        // Item detail + buy
        Expanded(
          child: _selected == null
              ? const Center(child: Text('Select an item to see details.'))
              : _buildItemDetail(_selected!, character),
        ),
      ],
    );
  }

  Widget _buildItemDetail(Equipment item, dynamic character) {
    // Pull parsed LST data
    String cost = '';
    String wt = '';
    String damage = '';
    String wield = '';
    List<String> types = [];
    try { cost = item.getString(StringKey.cost) ?? ''; } catch (_) {}
    try {
      final w = item.getSafeObject(cdom.CDOMObjectKey.getConstant<double>('WEIGHT'));
      if (w != null) wt = '${w} lb';
    } catch (_) {}
    try { damage = item.getString(StringKey.damage) ?? ''; } catch (_) {}
    try { wield = item.getString(StringKey.nameText) ?? ''; } catch (_) {}
    try {
      final typeList = item.getSafeListFor(ListKey.getConstant<String>('TYPE'));
      types = typeList.cast<String>().take(6).toList();
    } catch (_) {}

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.getDisplayName(),
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _row('Key', item.getKeyName()),
          if (cost.isNotEmpty) _row('Cost', '$cost gp'),
          if (wt.isNotEmpty) _row('Weight', wt),
          if (damage.isNotEmpty) _row('Damage', damage),
          if (wield.isNotEmpty) _row('Wield', wield),
          if (types.isNotEmpty) _row('Type', types.join(', ')),
          if (item.getSourceURI() != null)
            _row('Source',
                Uri.parse(item.getSourceURI()!).pathSegments.last),
          const SizedBox(height: 16),
          if (character != null)
            ElevatedButton.icon(
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Add to Gear'),
              onPressed: () {
                _addToGear(character, item);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added ${item.getDisplayName()} to carried gear'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCarriedTab(dynamic character) {
    if (character == null) {
      return const Center(child: Text('No character selected.'));
    }
    final gear = _getGear(character);
    final funds = _getFunds(character);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Text('Carried Gear (${gear.length} items)',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              // Funds display + edit
              const Text('Gold: ', style: TextStyle(fontSize: 12)),
              SizedBox(
                width: 70,
                child: TextFormField(
                  initialValue: funds.toStringAsFixed(2),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontSize: 12),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    suffixText: 'gp',
                  ),
                  onFieldSubmitted: (v) {
                    final amount = double.tryParse(v);
                    if (amount != null) {
                      try {
                        (character as dynamic).setFunds(amount);
                        currentCharacter.notifyListeners();
                        setState(() {});
                      } catch (_) {}
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: gear.isEmpty
              ? const Center(
                  child: Text('No items in gear.',
                      style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)))
              : ListView.builder(
                  itemCount: gear.length,
                  itemBuilder: (context, i) {
                    final entry = gear[i];
                    final name = entry['name'] as String? ?? 'Unknown';
                    final qty = entry['qty'] as int? ?? 1;
                    return ListTile(
                      dense: true,
                      title: Text(name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('×$qty'),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline,
                                size: 16, color: Colors.red),
                            onPressed: () => _removeFromGear(character, i),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getGear(dynamic character) {
    try {
      final data = (character as dynamic).toJson() as Map<String, dynamic>;
      final gear = data['gear'];
      if (gear is List) return gear.cast<Map<String, dynamic>>();
    } catch (_) {}
    return [];
  }

  void _addToGear(dynamic character, Equipment item) {
    try {
      final data = (character as dynamic).toJson() as Map<String, dynamic>;
      final gear = (data['gear'] ??= <Map<String, dynamic>>[]) as List;
      final existing = gear.firstWhere(
        (e) => e is Map && e['key'] == item.getKeyName(),
        orElse: () => null,
      );
      if (existing != null) {
        existing['qty'] = (existing['qty'] as int? ?? 1) + 1;
      } else {
        // Parse cost from stored string (e.g. '50' gp)
        String costStr = '';
        try { costStr = item.getString(StringKey.cost) ?? ''; } catch (_) {}
        final costGp = double.tryParse(costStr) ?? 0.0;
        gear.add({
          'name': item.getDisplayName(),
          'key': item.getKeyName(),
          'qty': 1,
          'cost': costGp,
        });
        // Deduct cost from funds
        if (costGp > 0) {
          final current = (character as dynamic).getFunds() as double? ?? 0.0;
          (character as dynamic).setFunds(current - costGp);
        }
      }
      currentCharacter.notifyListeners();
      setState(() {});
    } catch (_) {}
  }

  void _removeFromGear(dynamic character, int index) {
    try {
      final data = (character as dynamic).toJson() as Map<String, dynamic>;
      final gear = data['gear'] as List?;
      if (gear != null && index < gear.length) {
        gear.removeAt(index);
        currentCharacter.notifyListeners();
        setState(() {});
      }
    } catch (_) {}
  }

  double _getFunds(dynamic character) {
    try { return (character as dynamic).getFunds() as double? ?? 0.0; }
    catch (_) { return 0.0; }
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: [
          SizedBox(width: 70, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ]),
      );
}
