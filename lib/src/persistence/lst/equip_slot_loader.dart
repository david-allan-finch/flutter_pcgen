// Copyright 2001 (C) Bryan McRoberts <merton_monk@yahoo.com>
//
// Translation of pcgen.persistence.lst.EquipSlotLoader

import 'package:flutter_pcgen/src/core/character/equip_slot.dart';
import 'package:flutter_pcgen/src/core/game_mode.dart';
import 'package:flutter_pcgen/src/core/system_collections.dart';
import 'package:flutter_pcgen/src/persistence/lst/lst_line_file_loader.dart';

/// Loads EquipSlot definitions from equipmentslots.lst in the game mode dir.
///
/// File format — two types of line:
///
///   NUMSLOTS:DEFAULT  HEAD:1  HANDS:2  TORSO:1  LEGS:2  SHIELD:1  [VEHICLE:1]
///   EQSLOT:Head  CONTAINS:Headgear=1|Helmet=1  NUMBER:HEAD
///
/// NUMSLOTS defines how many of each body region a character has.
/// EQSLOT defines one named slot with the item types it accepts.
class EquipSlotLoader extends LstLineFileLoader {
  String _gameMode = '';

  void setGameMode(String gameMode) => _gameMode = gameMode;

  @override
  void parseLine(dynamic context, String lstLine, Uri sourceUri) {
    if (lstLine.isEmpty || lstLine.startsWith('#')) return;

    final firstColonIdx = lstLine.indexOf(':');
    if (firstColonIdx <= 0) return;

    final lineKey = lstLine.substring(0, firstColonIdx).trim().toUpperCase();

    if (lineKey == 'NUMSLOTS') {
      _parseNumSlots(lstLine);
      return;
    }

    // EQSLOT line — each tab-delimited field is a sub-token
    final eqSlot = EquipSlot();
    for (final col in lstLine.split('\t')) {
      final s = col.trim();
      final c = s.indexOf(':');
      if (c <= 0) continue;
      final key   = s.substring(0, c).trim().toUpperCase();
      final value = s.substring(c + 1).trim();

      switch (key) {
        case 'EQSLOT':
          eqSlot.slotName = value;
        case 'SLOTNAME':
          // Older alias — keep for backwards compatibility
          eqSlot.slotName = value;
        case 'NUMBER':
          eqSlot.slotNumType = value;
        case 'NUMSLOTS':
          eqSlot.containNum = int.tryParse(value) ?? 1;
        case 'CONTAINS':
          // Format: Type=count|Type=count  — strip the =count suffix
          for (final t in value.split('|')) {
            final raw = t.trim();
            if (raw.isEmpty) continue;
            final eqIdx = raw.indexOf('=');
            final typeName = eqIdx > 0 ? raw.substring(0, eqIdx).trim() : raw;
            if (typeName.isNotEmpty) eqSlot.addContainedType(typeName);
          }
        default:
          break;
      }
    }

    if (eqSlot.slotName.isNotEmpty) {
      SystemCollections.addToEquipSlotsList(eqSlot, _gameMode);
    }
  }

  /// Parses a NUMSLOTS line and stores body region counts in SystemCollections.
  ///
  /// NUMSLOTS:DEFAULT  HEAD:1  HANDS:2  TORSO:1  LEGS:2  SHIELD:1  [VEHICLE:1]
  void _parseNumSlots(String line) {
    final counts = <String, int>{};
    for (final col in line.split('\t')) {
      final s = col.trim();
      final c = s.indexOf(':');
      if (c <= 0) continue;
      final key   = s.substring(0, c).trim().toUpperCase();
      final value = s.substring(c + 1).trim();
      if (key == 'NUMSLOTS') continue; // skip the primary key
      final n = int.tryParse(value);
      if (n != null) counts[key] = n;
    }
    if (counts.isNotEmpty) {
      SystemCollections.setEquipSlotCounts(counts, _gameMode);
    }
  }
}
