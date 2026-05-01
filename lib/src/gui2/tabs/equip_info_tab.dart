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
    final usedKeys = equipped.values.toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: const Row(
            children: [
              Expanded(child: Text('Carried Gear',
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
                final qty = item['qty'] as int? ?? 1;
                final key = item['key'] as String? ?? '';
                final isEquipped = usedKeys.contains(key);
                return ListTile(
                  dense: true,
                  tileColor: isEquipped ? Colors.green.withOpacity(0.05) : null,
                  title: Text(name, style: const TextStyle(fontSize: 12)),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    if (isEquipped)
                      const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(Icons.check_circle_outline, size: 13, color: Colors.green),
                      ),
                    Text('×$qty', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ]),
                );
              },
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

  Future<void> _pickItemForSlot(dynamic character, String slot,
      List<Map<String, dynamic>> gear) async {
    final picked = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text('Equip to $slot', style: const TextStyle(fontSize: 15)),
        children: gear.map((item) {
          final name = item['name'] as String? ?? 'Unknown';
          final qty = item['qty'] as int? ?? 1;
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
      final eq = (data['equippedSlots'] ??= <String, String>{}) as Map;
      eq[slot] = item['key'] as String? ?? '';
      currentCharacter.notifyListeners();
      setState(() => _selectedGearIndex = null);
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
}
