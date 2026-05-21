// Copyright 2010 (C) Tom Parker <thpr@users.sourceforge.net>
// Copyright 2001 (C) Bryan McRoberts <merton_monk@yahoo.com>
//
// Translation of pcgen.persistence.lst.LoadInfoLoader

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_pcgen/src/persistence/lst/lst_line_file_loader.dart';

/// Loads encumbrance and carry capacity data from load.lst game mode files.
///
/// File format:
///   SIZEMULT:F|0.125       — size abbreviation → capacity multiplier
///   LOAD:1|10              — STR score → max carry weight in pounds
///   LOADMULT:4             — multiplier for loads above STR 29
///   ENCUMBRANCE:Light|1/3||0  — encumbrance category|fraction|speedMod|skillPenalty
class LoadInfoLoader extends LstLineFileLoader {
  /// Size abbreviation → carrying capacity multiplier (e.g. 'F' → 0.125)
  final Map<String, double> sizeMult = {};

  /// STR score → maximum carry weight in lbs (e.g. 1 → 10, 10 → 100)
  final Map<int, int> loadTable = {};

  /// Multiplier applied when STR > the last table entry (default 4)
  double loadMult = 4.0;

  /// Encumbrance categories: name → {fraction, speedMod, skillPenalty}
  final Map<String, Map<String, String>> encumbranceCategories = {};

  @override
  void parseLine(dynamic context, String lstLine, Uri sourceUri) {
    if (lstLine.isEmpty || lstLine.startsWith('#')) return;

    final colonIdx = lstLine.indexOf(':');
    if (colonIdx <= 0) return;
    final key = lstLine.substring(0, colonIdx).trim();
    final rest = lstLine.substring(colonIdx + 1).trim();

    switch (key) {
      case 'SIZEMULT':
        // SIZEMULT:F|0.125
        final pipe = rest.indexOf('|');
        if (pipe > 0) {
          final sizeAbb = rest.substring(0, pipe).trim();
          final factor  = double.tryParse(rest.substring(pipe + 1).trim());
          if (sizeAbb.isNotEmpty && factor != null) {
            sizeMult[sizeAbb] = factor;
          }
        }

      case 'LOAD':
        // LOAD:10|100  (STR score | max pounds)
        final pipe = rest.indexOf('|');
        if (pipe > 0) {
          final score  = int.tryParse(rest.substring(0, pipe).trim());
          final weight = int.tryParse(rest.substring(pipe + 1).trim());
          if (score != null && weight != null) {
            loadTable[score] = weight;
          }
        }

      case 'LOADMULT':
        loadMult = double.tryParse(rest) ?? loadMult;

      case 'ENCUMBRANCE':
        // ENCUMBRANCE:Light|1/3||0  — name|fractionOfMax|speedMod|skillPenalty
        final parts = rest.split('|');
        if (parts.isNotEmpty) {
          final name = parts[0].trim();
          encumbranceCategories[name] = {
            'fraction':     parts.length > 1 ? parts[1].trim() : '',
            'speedMod':     parts.length > 2 ? parts[2].trim() : '',
            'skillPenalty': parts.length > 3 ? parts[3].trim() : '0',
          };
        }

      default:
        if (kDebugMode) {
          // ignore: avoid_print
          print('PCGen STUB: load.lst unknown token $key=$rest');
        }
    }
  }

  /// Returns the maximum carry weight for [strScore] in pounds.
  /// Returns 0 if the table has no entries.
  int maxCarryForStr(int strScore) {
    if (loadTable.isEmpty) return 0;
    // Find the largest table entry ≤ strScore
    int? result;
    int? lastScore;
    for (final entry in loadTable.entries.toList()..sort((a, b) => a.key.compareTo(b.key))) {
      if (entry.key <= strScore) {
        result = entry.value;
        lastScore = entry.key;
      }
    }
    if (result == null) return 0;
    if (strScore > (lastScore ?? strScore)) {
      // Apply LOADMULT for each step beyond the table
      final steps = strScore - (lastScore ?? strScore);
      return (result * (loadMult * steps)).toInt();
    }
    return result;
  }
}
