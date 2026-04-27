// Copyright 2010 Tom Parker <thpr@users.sourceforge.net>
//
// Translation of pcgen.persistence.lst.AbilityCategoryLoader

import 'package:flutter_pcgen/src/core/ability_category.dart';
import 'package:flutter_pcgen/src/persistence/lst/lst_line_file_loader.dart';

/// Parses ABILITYCATEGORY lines from game-mode miscinfo.lst or campaign LST files.
///
/// Format:
///   ABILITYCATEGORY:<key>  [TOKEN:value ...]
///
/// Uses AbilityCategory's factory constructor which does get-or-create, so
/// duplicate definitions extend rather than replace existing categories.
class AbilityCategoryLoader extends LstLineFileLoader {
  @override
  void parseLine(dynamic context, String lstLine, Uri sourceUri) {
    final colonLoc = lstLine.indexOf(':');
    if (colonLoc <= 0 || colonLoc == lstLine.length - 1) return;

    final key = lstLine.substring(0, colonLoc);
    if (key != 'ABILITYCATEGORY') return;

    final rest = lstLine.substring(colonLoc + 1);
    final tokens = rest.split('\t');
    if (tokens.isEmpty || tokens[0].trim().isEmpty) return;

    final name = tokens[0].trim();
    final cat = AbilityCategory(name);

    for (int i = 1; i < tokens.length; i++) {
      _applyToken(cat, tokens[i].trim());
    }
  }

  void _applyToken(AbilityCategory cat, String token) {
    if (token.isEmpty) return;
    final sep = token.indexOf(':');
    if (sep <= 0) return;
    final key = token.substring(0, sep);
    final value = token.substring(sep + 1);

    switch (key) {
      case 'PLURAL':
        cat.setPluralName(value);
        break;
      case 'EDITABLE':
        cat.setEditable(value == 'YES');
        break;
      case 'EDITPOOL':
        cat.setEditPool(value == 'YES');
        break;
      case 'FRACTIONALPOOL':
        cat.setFractionalPool(value == 'YES');
        break;
      case 'VISIBLE':
        cat.setVisible(value != 'NO');
        break;
      case 'TYPE':
        for (final t in value.split('.')) {
          if (t.isNotEmpty) cat.addAbilityType(t);
        }
        break;
      case 'CATEGORY':
      case 'DISPLAYNAME':
        cat.setDisplayName(value);
        break;
      default:
        // Remaining tokens (POOL, ABILITYCATEGORY sub-refs, etc.) ignored for now
        break;
    }
  }
}
