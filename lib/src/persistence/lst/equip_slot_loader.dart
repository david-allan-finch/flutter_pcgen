// Translation of pcgen.persistence.lst.EquipSlotLoader

import '../../core/character/equip_slot.dart';
import '../../core/game_mode.dart';
import '../../core/system_collections.dart';
import 'lst_line_file_loader.dart';

/// Loads EquipSlot definitions from equipslot .lst files in the game mode.
///
/// Each line defines one equipment slot (e.g. SLOTNAME:Weapon Hand).
/// The parsed slots are added to SystemCollections for the current game mode.
class EquipSlotLoader extends LstLineFileLoader {
  String _gameMode = '';

  void setGameMode(String gameMode) => _gameMode = gameMode;

  @override
  void parseLine(dynamic context, String lstLine, Uri sourceUri) {
    if (lstLine.isEmpty || lstLine.startsWith('#')) return;

    final eqSlot = EquipSlot();
    final cols = lstLine.split('\t');

    for (final col in cols) {
      final s = col.trim();
      final colonIdx = s.indexOf(':');
      if (colonIdx <= 0) continue;

      final key = s.substring(0, colonIdx).trim();
      final value = s.substring(colonIdx + 1).trim();

      switch (key) {
        case 'SLOTNAME':
          eqSlot.slotName = value;
        case 'NUMSLOTS':
          eqSlot.containNum = int.tryParse(value) ?? 1;
        case 'NUMBER':
          eqSlot.slotNumType = value;
        case 'CONTAINS':
          for (final t in value.split('|')) {
            if (t.trim().isNotEmpty) eqSlot.addContainedType(t.trim());
          }
        default:
          break;
      }
    }

    if (eqSlot.slotName.isNotEmpty) {
      SystemCollections.addToEquipSlotsList(eqSlot, _gameMode);
    }
  }
}
