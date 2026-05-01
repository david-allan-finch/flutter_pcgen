//
// Translation of pcgen.gui2.tabs.EquipInfoTab
//
// Shows carried gear and allows assigning items to body slots.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
  'Carried',   // catch-all for items not worn in a named slot
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
  // The gear item currently selected in the left panel for assignment.
  int? _selectedGearIndex;

  void setCharacter(dynamic character) => setState(() {});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: currentCharacter,
      builder: (context, character, _) {
        if (character == null) {
          return const Center(child: Text('No character selected.'));
        }
        final gear = _getGear(character);
        final equipped = _getEquipped(character);
        return Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  // Left: carried gear list
                  SizedBox(
                    width: 240,
                    child: _buildGearPanel(character, gear, equipped),
                  ),
                  const VerticalDivider(width: 1),
                  // Right: body slot grid
                  Expanded(child: _buildSlotsPanel(character, gear, equipped)),
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
      dynamic character, List<Map<String, dynamic>> gear, Map<String, String> equipped) {
    // Count how many times each gear index is equipped across all slots.
    final usedKeys = equipped.values.toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: const Row(
            children: [
              Expanded(
                child: Text('Carried Gear',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
              SizedBox(
                width: 32,
                child: Text('Qty',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Colors.grey)),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        if (gear.isEmpty)
          const Expanded(
            child: Center(
              child: Text(
                'No items in gear.\nPurchase items in the Inventory tab.',
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
                final qty = item['qty'] as int? ?? 1;
                final key = item['key'] as String? ?? '';
                final isEquipped = usedKeys.contains(key);
                final isSelected = _selectedGearIndex == i;

                return ListTile(
                  dense: true,
                  selected: isSelected,
                  selectedTileColor:
                      Theme.of(context).colorScheme.primaryContainer.withAlpha(80),
                  tileColor: isEquipped ? Colors.green.withOpacity(0.05) : null,
                  title: Text(name, style: const TextStyle(fontSize: 12)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isEquipped)
                        const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(Icons.check_circle_outline,
                              size: 13, color: Colors.green),
                        ),
                      Text('×$qty',
                          style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                  onTap: () => setState(() {
                    _selectedGearIndex = isSelected ? null : i;
                  }),
                );
              },
            ),
          ),
        if (_selectedGearIndex != null)
          Container(
            color: Theme.of(context).colorScheme.primaryContainer.withAlpha(40),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text(
              'Tap a slot on the right to equip ${gear[_selectedGearIndex!]['name']}',
              style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.primary,
                  fontStyle: FontStyle.italic),
            ),
          ),
      ],
    );
  }

  // ---- Right panel: slots --------------------------------------------------

  Widget _buildSlotsPanel(
      dynamic character, List<Map<String, dynamic>> gear, Map<String, String> equipped) {
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
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: _kSlots.length,
            itemBuilder: (context, i) {
              final slot = _kSlots[i];
              final equippedKey = equipped[slot];
              final equippedName = equippedKey != null
                  ? _gearNameForKey(gear, equippedKey)
                  : null;
              return _buildSlotRow(character, slot, equippedName, equippedKey, gear);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSlotRow(dynamic character, String slot, String? equippedName,
      String? equippedKey, List<Map<String, dynamic>> gear) {
    final isOccupied = equippedName != null;
    final canAssign = _selectedGearIndex != null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          // Slot label
          SizedBox(
            width: 110,
            child: Text(slot,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.grey.shade700)),
          ),
          // Equipped item (or empty tap target)
          Expanded(
            child: InkWell(
              onTap: canAssign
                  ? () => _equipToSlot(character, slot, gear[_selectedGearIndex!])
                  : null,
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: canAssign && !isOccupied
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                        : Colors.grey.shade300,
                    width: canAssign && !isOccupied ? 1.5 : 1,
                  ),
                  borderRadius: BorderRadius.circular(4),
                  color: isOccupied
                      ? Colors.green.withOpacity(0.07)
                      : canAssign
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.03)
                          : null,
                ),
                child: Text(
                  equippedName ?? (canAssign ? 'Tap to equip…' : '—'),
                  style: TextStyle(
                    fontSize: 12,
                    color: isOccupied
                        ? Colors.black87
                        : Colors.grey.shade500,
                    fontStyle: isOccupied ? FontStyle.normal : FontStyle.italic,
                  ),
                ),
              ),
            ),
          ),
          // Unequip button
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
      final eq = (data['equippedSlots'] ??= <String, String>{}) as Map;
      final itemKey = item['key'] as String? ?? '';
      debugPrint('[equip] _equipToSlot slot=$slot itemKey=$itemKey');
      eq[slot] = itemKey;
      debugPrint('[equip] equippedSlots after: $eq');
      currentCharacter.notifyListeners();
      setState(() => _selectedGearIndex = null);
    } catch (e, st) {
      debugPrint('[equip] _equipToSlot error: $e\n$st');
    }
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
}
