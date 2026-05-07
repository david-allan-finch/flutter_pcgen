//
// Translation of pcgen.gui2.tabs.EquipInfoTab
//
// Shows carried gear and allows assigning items to body slots.

import 'package:flutter/material.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/gui2/app_state.dart';

// Standard 3.5e / Pathfinder body slots in display order.
const _kSlots = [
  'Head',
  'Eyes',
  'Neck',
  'Shoulders',
  'Back',
  'Armor',
  'Torso',
  'Arms',
  'Hands',
  'Ring (Left)',
  'Ring (Right)',
  'Belt',
  'Primary Hand',
  'Off Hand',
  'Feet',
  'Ammunition',
];

// Which item TYPEs can go in which slots (used for soft validation hints only).
const _kSlotTypes = <String, List<String>>{
  'Head':         ['Headgear', 'Helm', 'Hat'],
  'Eyes':         ['Eyegear', 'Goggles', 'Lens'],
  'Neck':         ['Amulet', 'Necklace', 'Collar'],
  'Shoulders':    ['Pauldron', 'Shoulder'],
  'Back':         ['Cloak', 'Cape', 'Wing'],
  'Armor':        ['Armor', 'Light Armor', 'Medium Armor', 'Heavy Armor'],
  'Torso':        ['Shirt', 'Vest', 'Robe'],
  'Arms':         ['Bracer', 'Bracers', 'Armband'],
  'Hands':        ['Gloves', 'Gauntlets', 'Glove'],
  'Ring (Left)':  ['Ring'],
  'Ring (Right)': ['Ring'],
  'Belt':         ['Belt', 'Girdle'],
  'Primary Hand': ['Weapon', 'Melee Weapon', 'Ranged Weapon', 'Shield'],
  'Off Hand':     ['Weapon', 'Shield', 'Buckler'],
  'Feet':         ['Boot', 'Boots', 'Sandal', 'Shoe'],
  'Ammunition':   ['Ammunition', 'Arrow', 'Bolt', 'Bullet'],
};

class EquipInfoTab extends StatefulWidget {
  const EquipInfoTab({super.key});

  @override
  State<EquipInfoTab> createState() => EquipInfoTabState();
}

class EquipInfoTabState extends State<EquipInfoTab> {

  void setCharacter(dynamic character) => setState(() {});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: currentCharacter,
      builder: (context, character, _) {
        if (character == null) {
          return const Center(child: Text('No character selected.'));
        }
        final gear     = _getGear(character);
        final equipped = _getEquipped(character);
        final carried  = _getCarried(character);
        return Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  // Left: gear list (all items, shows equipped status)
                  SizedBox(
                    width: 240,
                    child: _buildGearPanel(character, gear, equipped, carried),
                  ),
                  const VerticalDivider(width: 1),
                  // Right: body slots + carried containers
                  Expanded(child: _buildSlotsPanel(character, gear, equipped, carried)),
                ],
              ),
            ),
            const Divider(height: 1),
            _buildFooter(character, gear),
          ],
        );
      },
    );
  }

  // ---- Left panel: carried gear --------------------------------------------

  Widget _buildGearPanel(
      dynamic character, List<Map<String, dynamic>> gear,
      Map<String, String> equipped, List<String> carriedKeys) {
    final slotKeys    = equipped.values.toSet();
    final carriedSet  = carriedKeys.toSet();
    final allUsedKeys = {...slotKeys, ...carriedSet};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: const Row(
            children: [
              Expanded(child: Text('Gear',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
              SizedBox(width: 32, child: Text('Qty',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Colors.grey))),
            ],
          ),
        ),
        const Divider(height: 1),
        if (gear.isEmpty)
          const Expanded(
            child: Center(
              child: Text(
                'No items in gear.\nPurchase items in the Inventory tab first.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: gear.length,
              itemBuilder: (context, i) {
                final item = gear[i];
                final name = item['name'] as String? ?? 'Unknown';
                final qty  = item['qty']  as int?    ?? 1;
                final key  = item['key']  as String? ?? '';
                final isCarried  = carriedSet.contains(key);
                final isSlotted  = slotKeys.contains(key);
                final isEquipped = isCarried || isSlotted;
                final slotLabels = equipped.entries
                    .where((e) => e.value == key)
                    .map((e) => e.key)
                    .toList();
                final subtitle = isCarried
                    ? 'Carried'
                    : isSlotted
                        ? slotLabels.join(', ')
                        : null;
                return ListTile(
                  dense: true,
                  tileColor: isEquipped ? Colors.green.withValues(alpha: 0.05) : null,
                  title: Text(name, style: const TextStyle(fontSize: 12)),
                  subtitle: subtitle != null
                      ? Text(subtitle,
                          style: const TextStyle(fontSize: 10, color: Colors.green))
                      : const Text('Tap to equip →',
                          style: TextStyle(fontSize: 10, color: Colors.grey,
                              fontStyle: FontStyle.italic)),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    if (isEquipped)
                      const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(Icons.check_circle_outline, size: 13, color: Colors.green),
                      ),
                    Text('×$qty', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ]),
                  onTap: () => _pickSlotForItem(character, item, equipped),
                );
              },
            ),
          ),
      ],
    );
  }

  // ---- Right panel: slots --------------------------------------------------

  Widget _buildSlotsPanel(
      dynamic character, List<Map<String, dynamic>> gear,
      Map<String, String> equipped, List<String> carriedKeys) {
    // Container contents (bags, pouches, gloves of storing, etc.)
    Map<String, List<String>> containers = {};
    try {
      final data = (character as dynamic).toJson() as Map<String, dynamic>;
      final raw = data['containerContents'] as Map? ?? {};
      for (final e in raw.entries) {
        final k = e.key as String? ?? '';
        final v = e.value;
        if (k.isNotEmpty && v is List) {
          containers[k] = v.cast<String>();
        }
      }
    } catch (_) {}

    // Track which containers were shown inside a body slot (to avoid duplication).
    final shownContainers = <String>{};

    // Build a list: slot rows + container sections
    final items = <Widget>[];
    for (final slot in _kSlots) {
      final equippedKey = equipped[slot];
      final equippedName = equippedKey != null ? _gearNameForKey(gear, equippedKey) : null;
      items.add(_buildSlotRow(character, slot, equippedName, equippedKey, gear));

      // If this slot has an equipped item that is a container, show its contents
      if (equippedName != null && containers.containsKey(equippedName)) {
        final contents = containers[equippedName]!;
        if (contents.isNotEmpty) {
          items.add(_buildContainerContents(equippedName, contents));
        }
        shownContainers.add(equippedName);
      }
    }

    // Carried items section (bags, wands, potions, etc. in carriedItems list)
    if (carriedKeys.isNotEmpty) {
      items.add(const SizedBox(height: 8));
      items.add(Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: const Text('Carried / Equipped',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      ));
      // Build name lookup from gear
      final keyToName = <String, String>{};
      for (final g in gear) { keyToName[g['key'] as String? ?? ''] = g['name'] as String? ?? ''; }

      for (final key in carriedKeys) {
        final name = keyToName[key] ?? key;
        final contents = containers[name];
        final isContainer = contents != null && contents.isNotEmpty;
        items.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          child: Row(
            children: [
              Icon(isContainer ? Icons.backpack : Icons.inventory_2_outlined,
                  size: 13, color: Colors.brown.shade400),
              const SizedBox(width: 6),
              Expanded(child: Text(name,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
              // Uncarry button
              InkWell(
                onTap: () => _uncarryItem(character, key),
                borderRadius: BorderRadius.circular(10),
                child: const Padding(
                  padding: EdgeInsets.all(3),
                  child: Icon(Icons.close, size: 12, color: Colors.red),
                ),
              ),
            ],
          ),
        ));
        if (isContainer && !shownContainers.contains(name)) {
          items.add(_buildContainerContents(name, contents));
        }
      }
      // Add button to carry a new item
      items.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: TextButton.icon(
          style: TextButton.styleFrom(padding: const EdgeInsets.all(4)),
          icon: const Icon(Icons.add, size: 14),
          label: const Text('Carry item…', style: TextStyle(fontSize: 11)),
          onPressed: () => _pickCarriedItem(character, gear, carriedKeys),
        ),
      ));
    } else {
      // No carried items yet — show an add button
      items.add(const SizedBox(height: 8));
      items.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: TextButton.icon(
          style: TextButton.styleFrom(padding: const EdgeInsets.all(4)),
          icon: const Icon(Icons.add, size: 14),
          label: const Text('Carry item…', style: TextStyle(fontSize: 11)),
          onPressed: () => _pickCarriedItem(character, gear, carriedKeys),
        ),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: const Text('Equipment Slots',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(8),
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildContainerContents(String containerName, List<String> contents) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...contents.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: Row(children: [
              const Icon(Icons.subdirectory_arrow_right, size: 12, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(child: Text(item,
                  style: const TextStyle(fontSize: 11, color: Colors.grey))),
            ]),
          )),
        ],
      ),
    );
  }

  Widget _buildSlotRow(dynamic character, String slot, String? equippedName,
      String? equippedKey, List<Map<String, dynamic>> gear) {
    final isOccupied = equippedName != null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(slot,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12,
                    color: Colors.grey.shade700)),
          ),
          Expanded(
            child: InkWell(
              // Tapping any slot opens a picker of all carried gear
              onTap: gear.isEmpty ? null : () => _pickItemForSlot(character, slot, gear),
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isOccupied
                        ? Colors.green.shade300
                        : gear.isEmpty ? Colors.grey.shade200 : Colors.grey.shade400,
                  ),
                  borderRadius: BorderRadius.circular(4),
                  color: isOccupied ? Colors.green.withOpacity(0.07) : null,
                ),
                child: Text(
                  equippedName ?? (gear.isEmpty ? '—' : 'Tap to equip…'),
                  style: TextStyle(
                    fontSize: 12,
                    color: isOccupied ? Colors.black87 : Colors.grey.shade500,
                    fontStyle: isOccupied ? FontStyle.normal : FontStyle.italic,
                  ),
                ),
              ),
            ),
          ),
          if (isOccupied)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: InkWell(
                onTap: () => _unequipSlot(character, slot),
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close, size: 14, color: Colors.red),
                ),
              ),
            )
          else
            const SizedBox(width: 22),
        ],
      ),
    );
  }

  /// Tap an item → pick which slot to equip it to.
  Future<void> _pickSlotForItem(dynamic character, Map<String, dynamic> item,
      Map<String, String> equipped) async {
    final name = item['name'] as String? ?? 'Unknown';
    final key  = item['key']  as String? ?? '';

    // Look up item TYPE list from dataset to filter compatible slots
    final dataset = loadedDataSet.value;
    final itemTypes = <String>[];
    if (dataset != null) {
      try {
        final dsItem = dataset.equipment
            .where((e) => e.getKeyName() == key)
            .firstOrNull;
        if (dsItem != null) {
          final tl = dsItem.getSafeListFor(
              ListKey.getConstant<String>('TYPE')) as List?;
          if (tl != null) {
            for (final t in tl) { if (t is String) itemTypes.add(t.toLowerCase()); }
          }
        }
      } catch (_) {}
    }

    // Determine which slots are compatible based on _kSlotTypes
    bool slotCompatible(String slot) {
      if (itemTypes.isEmpty) return true; // unknown type — show all
      final allowed = _kSlotTypes[slot];
      if (allowed == null) return false;
      return allowed.any((t) => itemTypes.contains(t.toLowerCase()));
    }

    final compatibleSlots = _kSlots.where(slotCompatible).toList();
    final offerSlots = compatibleSlots.isEmpty ? _kSlots.toList() : compatibleSlots;

    // Offer compatible slots; mark occupied ones
    final picked = await showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text('Equip "$name" to…', style: const TextStyle(fontSize: 15)),
        children: [
          ...offerSlots.map((slot) {
            final occupant = equipped[slot];
            final isSelf = occupant == key;
            final isFull = occupant != null && !isSelf;
            return SimpleDialogOption(
              onPressed: isFull ? null : () => Navigator.pop(context, slot),
              child: Row(children: [
                Expanded(child: Text(slot,
                    style: TextStyle(fontSize: 13,
                        color: isFull ? Colors.grey : null))),
                if (isSelf)
                  const Text('(equipped)',
                      style: TextStyle(fontSize: 11, color: Colors.green)),
                if (isFull && !isSelf)
                  Text('($occupant)',
                      style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ]),
            );
          }),
          if (equipped.values.contains(key))
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, '__unequip__'),
              child: const Text('Unequip',
                  style: TextStyle(fontSize: 13, color: Colors.red)),
            ),
        ],
      ),
    );
    if (picked == null) return;
    if (picked == '__unequip__') {
      // Remove from body slot and move to carriedItems.
      try {
        final data = (character as dynamic).toJson() as Map<String, dynamic>;
        final eq = data['equippedSlots'] as Map?;
        if (eq != null) {
          eq.removeWhere((_, v) => v == key);
          final ci = (data['carriedItems'] ??= <String>[]) as List;
          if (!ci.contains(key)) ci.add(key);
          currentCharacter.notifyListeners();
          setState(() {});
        }
      } catch (_) {}
    } else {
      _equipToSlot(character, picked, item);
    }
  }

  Future<void> _pickItemForSlot(dynamic character, String slot,
      List<Map<String, dynamic>> gear) async {
    // Filter gear to items compatible with this slot via dataset TYPE lookup.
    final allowedTypes = _kSlotTypes[slot];
    final dataset = loadedDataSet.value;

    List<Map<String, dynamic>> compatible;
    if (allowedTypes == null || allowedTypes.isEmpty || dataset == null) {
      compatible = gear;
    } else {
      final allowedLower = allowedTypes.map((t) => t.toLowerCase()).toSet();
      compatible = gear.where((item) {
        final key      = item['key']      as String? ?? '';
        final baseItem = item['baseItem'] as String? ?? '';
        // Look up dataset item by key, then baseItem fallback.
        dynamic dsItem = (dataset as dynamic).equipment
            .where((e) => (e as dynamic).getKeyName() == key)
            .firstOrNull;
        dsItem ??= (dataset as dynamic).equipment
            .where((e) => (e as dynamic).getKeyName() == baseItem)
            .firstOrNull;
        if (dsItem == null) return true; // unknown item — show anyway
        final types = <String>[];
        try {
          final tl = (dsItem as dynamic).getSafeListFor(
              ListKey.getConstant<dynamic>('TYPE')) as List?;
          if (tl != null) {
            for (final t in tl) { if (t is String) types.add(t.toLowerCase()); }
          }
        } catch (_) {}
        if (types.isEmpty) return true; // no type info — show anyway
        return types.any(allowedLower.contains);
      }).toList();
      // If nothing matched, fall back to full list so slot is never unusable.
      if (compatible.isEmpty) compatible = gear;
    }

    final picked = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text('Equip to $slot', style: const TextStyle(fontSize: 15)),
        children: compatible.map((item) {
          final name = item['name'] as String? ?? 'Unknown';
          final qty  = item['qty']  as int?    ?? 1;
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, item),
            child: Row(children: [
              Expanded(child: Text(name, style: const TextStyle(fontSize: 13))),
              Text('×$qty', style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ]),
          );
        }).toList(),
      ),
    );
    if (picked != null) _equipToSlot(character, slot, picked);
  }

  // ---- Footer: weight + load -----------------------------------------------

  Widget _buildFooter(dynamic character, List<Map<String, dynamic>> gear) {
    // Compute total weight from gear list (each item should have a 'weight' key
    // in lbs; fall back to 0 if missing).
    double totalWeight = 0;
    for (final item in gear) {
      final wt = (item['weight'] as num?)?.toDouble() ?? 0.0;
      final qty = (item['qty'] as num?)?.toInt() ?? 1;
      totalWeight += wt * qty;
    }

    // Light/Medium/Heavy load thresholds for STR score (3.5e table, STR 10).
    // We use a simplified version; a real implementation would read STR score.
    int strScore = 10;
    try {
      // Try to read STR from character if possible
      final data = (character as dynamic).toJson() as Map<String, dynamic>;
      final scores = data['statScores'] as Map?;
      if (scores != null) {
        final str = scores['STR'];
        if (str is num) strScore = str.toInt();
      }
    } catch (_) {}

    final light  = _lightLoad(strScore);
    final medium = _mediumLoad(strScore);
    final heavy  = _heavyLoad(strScore);

    String loadCategory;
    Color loadColor;
    if (totalWeight <= light) {
      loadCategory = 'Light';
      loadColor = Colors.green.shade700;
    } else if (totalWeight <= medium) {
      loadCategory = 'Medium';
      loadColor = Colors.orange.shade700;
    } else if (totalWeight <= heavy) {
      loadCategory = 'Heavy';
      loadColor = Colors.red.shade700;
    } else {
      loadCategory = 'Overloaded';
      loadColor = Colors.red.shade900;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Text('Total Weight: ',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          Text('${totalWeight.toStringAsFixed(1)} lb',
              style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 16),
          Text('Load: ',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          Text(loadCategory,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: loadColor)),
          const SizedBox(width: 12),
          Text(
            'Light ≤${light}lb  Medium ≤${medium}lb  Heavy ≤${heavy}lb',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  // ---- Encumbrance thresholds (3.5e table) ---------------------------------

  // 3.5e light load by STR: max carry = STR × 10 lb; thresholds are ×1/3 and ×2/3
  int _lightLoad(int str)  => (str * 10 / 3).floor();
  int _mediumLoad(int str) => (str * 10 * 2 / 3).floor();
  int _heavyLoad(int str)  => str * 10;

  // ---- Data helpers --------------------------------------------------------

  List<Map<String, dynamic>> _getGear(dynamic character) {
    try {
      final data = (character as dynamic).toJson() as Map<String, dynamic>;
      final gear = data['gear'];
      if (gear is List) return gear.cast<Map<String, dynamic>>();
    } catch (_) {}
    return [];
  }

  // equipped: slot → itemKey
  Map<String, String> _getEquipped(dynamic character) {
    try {
      final data = (character as dynamic).toJson() as Map<String, dynamic>;
      final eq = data['equippedSlots'];
      if (eq is Map) return eq.cast<String, String>();
    } catch (_) {}
    return {};
  }

  String? _gearNameForKey(List<Map<String, dynamic>> gear, String key) {
    try {
      return gear.firstWhere((g) => g['key'] == key)['name'] as String?;
    } catch (_) {
      return key; // fall back to key if item not found in current gear list
    }
  }

  void _equipToSlot(dynamic character, String slot, Map<String, dynamic> item) {
    try {
      final data = (character as dynamic).toJson() as Map<String, dynamic>;
      final key = item['key'] as String? ?? '';
      final eq  = (data['equippedSlots'] ??= <String, String>{}) as Map;
      eq[slot] = key;
      // If this item was previously carried, remove it from carriedItems.
      final ci = data['carriedItems'] as List?;
      ci?.remove(key);
      currentCharacter.notifyListeners();
      setState(() {});
    } catch (_) {}
  }

  void _unequipSlot(dynamic character, String slot) {
    try {
      final data = (character as dynamic).toJson() as Map<String, dynamic>;
      final eq = data['equippedSlots'] as Map?;
      if (eq != null) {
        eq.remove(slot);
        currentCharacter.notifyListeners();
        setState(() {});
      }
    } catch (_) {}
  }

  // ---- Carried items helpers -----------------------------------------------

  List<String> _getCarried(dynamic character) {
    try {
      final data = (character as dynamic).toJson() as Map<String, dynamic>;
      final ci = data['carriedItems'];
      if (ci is List) return ci.cast<String>();
    } catch (_) {}
    return [];
  }

  void _uncarryItem(dynamic character, String key) {
    try {
      final data = (character as dynamic).toJson() as Map<String, dynamic>;
      final ci = data['carriedItems'] as List?;
      if (ci != null) {
        ci.remove(key);
        currentCharacter.notifyListeners();
        setState(() {});
      }
    } catch (_) {}
  }

  Future<void> _pickCarriedItem(dynamic character,
      List<Map<String, dynamic>> gear, List<String> currentCarried) async {
    final carriedSet = currentCarried.toSet();
    final available = gear.where((g) {
      final k = g['key'] as String? ?? '';
      return k.isNotEmpty && !carriedSet.contains(k);
    }).toList();
    if (available.isEmpty) return;

    final picked = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Carry item', style: TextStyle(fontSize: 15)),
        children: available.map((item) {
          final name = item['name'] as String? ?? '';
          final qty  = item['qty']  as int?    ?? 1;
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, item),
            child: Row(children: [
              Expanded(child: Text(name, style: const TextStyle(fontSize: 13))),
              Text('×$qty', style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ]),
          );
        }).toList(),
      ),
    );
    if (picked == null) return;
    try {
      final data = (character as dynamic).toJson() as Map<String, dynamic>;
      final ci = (data['carriedItems'] ??= <String>[]) as List;
      final key = picked['key'] as String? ?? '';
      if (key.isNotEmpty && !ci.contains(key)) ci.add(key);
      currentCharacter.notifyListeners();
      setState(() {});
    } catch (_) {}
  }
}
