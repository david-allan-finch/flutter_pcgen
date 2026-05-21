// Copyright 2010 (C) Tom Parker <thpr@users.sourceforge.net>
// Copyright 2001 (C) Bryan McRoberts <merton_monk@yahoo.com>
//
// Translation of pcgen.persistence.lst.SizeAdjustmentLoader

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_pcgen/src/core/size_adjustment.dart';
import 'package:flutter_pcgen/src/rules/context/load_context.dart';
import 'package:flutter_pcgen/src/persistence/lst/lst_line_file_loader.dart';

/// Loads SizeAdjustment objects from sizeAdjustment.lst game mode files.
///
/// File format — multiple lines per size category, all starting with SIZENAME:key:
///   SIZENAME:M  ABB:M  DISPLAYNAME:Medium  ISDEFAULTSIZE:Y  SIZENUM:050
///   SIZENAME:M  BONUS:COMBAT|AC|0|TYPE=Size  …
///   SIZENAME:M  ABILITY:Internal|AUTOMATIC|SIZE_MASTER
///
/// All lines with the same SIZENAME key contribute to the same SizeAdjustment.
class SizeAdjustmentLoader extends LstLineFileLoader {
  final Map<String, SizeAdjustment> _sizes = {};

  @override
  void parseLine(dynamic context, String lstLine, Uri sourceUri) {
    if (lstLine.isEmpty || lstLine.startsWith('#')) return;

    final fields = lstLine.split('\t');
    if (fields.isEmpty) return;

    // First field must be SIZENAME:key
    final first = fields[0].trim();
    final firstColon = first.indexOf(':');
    if (firstColon <= 0) return;
    final firstKey = first.substring(0, firstColon).trim().toUpperCase();
    if (firstKey != 'SIZENAME') return;
    final sizeKey = first.substring(firstColon + 1).trim();
    if (sizeKey.isEmpty) return;

    // Get or create the SizeAdjustment for this key
    final size = _sizes.putIfAbsent(sizeKey, () {
      final s = SizeAdjustment();
      s.setName(sizeKey);
      s.setSourceURI(sourceUri.toString());
      if (context is LoadContext) {
        context.getReferenceContext().register(s);
      }
      return s;
    });

    // Process remaining sub-tokens on this line
    for (int i = 1; i < fields.length; i++) {
      final tok = fields[i].trim();
      if (tok.isEmpty) continue;
      final c = tok.indexOf(':');
      if (c <= 0) continue;
      final key   = tok.substring(0, c).trim().toUpperCase();
      final value = tok.substring(c + 1).trim();

      switch (key) {
        case 'ABB':
          size.setDisplayName(value); // abbreviation used as display name
        case 'DISPLAYNAME':
          // DISPLAYNAME overrides ABB for the human-readable name
          size.setDisplayName(value);
        case 'ISDEFAULTSIZE':
          size.isDefaultSize = value.toUpperCase() == 'Y' || value.toUpperCase() == 'YES';
        case 'SIZENUM':
          // Numeric sort key used for size comparisons (e.g. 050 for Medium)
          size.sizeNum = int.tryParse(value) ?? 0;
        case 'BONUS':
        case 'ABILITY':
          // Important for size modifiers to AC, skills, carrying capacity.
          // Stored as raw tokens until BONUS/ABILITY dispatch is fully wired.
          size.rawTokens.add('$key:$value');
        default:
          if (kDebugMode) {
            // ignore: avoid_print
            print('PCGen STUB: sizeAdjustment.lst unknown sub-token $key=$value');
          }
      }
    }
  }

  List<SizeAdjustment> getSizes() => List.unmodifiable(_sizes.values);
}
