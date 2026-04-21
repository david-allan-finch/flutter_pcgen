//
// Copyright 2013 (C) James Dempsey <jdempsey@users.equipforge.net>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.persistence.lst.MigrationLoader

import 'package:flutter_pcgen/src/core/system/migration_rule.dart';
import 'package:flutter_pcgen/src/rules/context/load_context.dart';
import 'lst_line_file_loader.dart';

/// Loads migration rules from migration.lst files.
///
/// Migration rules describe how to convert old key names to new ones across
/// PCGen version boundaries. Each line starts with a category token
/// (RACE, CLASS, EQUIPMENT, etc.) and defines an old key → new key mapping.
class MigrationLoader extends LstLineFileLoader {
  String? _gameModeName;

  void setGameMode(String gameMode) => _gameModeName = gameMode;

  @override
  void parseLine(dynamic context, String lstLine, Uri sourceUri) {
    if (lstLine.isEmpty || lstLine.startsWith('#')) return;

    final cols = lstLine.split('\t');
    if (cols.isEmpty) return;

    final firstToken = cols[0].trim();
    final rule = _parseFirstToken(firstToken, sourceUri);
    if (rule == null) return;

    // Apply remaining tokens
    for (int i = 1; i < cols.length; i++) {
      final col = cols[i].trim();
      if (col.isEmpty) continue;
      final colonIdx = col.indexOf(':');
      if (colonIdx <= 0) continue;
      final key = col.substring(0, colonIdx);
      final value = col.substring(colonIdx + 1);
      _applyToken(rule, key, value);
    }

    // Register rule in context (TODO: full registry)
  }

  MigrationRule? _parseFirstToken(String token, Uri sourceUri) {
    final colonIdx = token.indexOf(':');
    if (colonIdx <= 0) return null;

    final category = token.substring(0, colonIdx).trim().toUpperCase();
    final oldKey = token.substring(colonIdx + 1).trim();
    if (oldKey.isEmpty) return null;

    // Map string category to ObjectType
    final ObjectType? objectType = _mapCategory(category);
    if (objectType == null) return null;

    return objectType.isCategorized
        ? MigrationRule.categorized(objectType, null, oldKey)
        : MigrationRule.uncategorized(objectType, oldKey);
  }

  ObjectType? _mapCategory(String category) {
    switch (category) {
      case 'RACE': return ObjectType.race;
      case 'EQUIPMENT': return ObjectType.equipment;
      case 'ABILITY':
      case 'FEAT': return ObjectType.ability;
      case 'SPELL': return ObjectType.spell;
      case 'SOURCE': return ObjectType.source;
      default: return null;
    }
  }

  void _applyToken(MigrationRule rule, String key, String value) {
    switch (key) {
      case 'NEWKEY':
        rule.newKey = value;
      case 'MAXVER':
        rule.maxVer = value;
      case 'MINVER':
        rule.minVer = value;
      case 'NEWCATEGORY':
        rule.newCategory = value;
      default:
        break;
    }
  }
}
