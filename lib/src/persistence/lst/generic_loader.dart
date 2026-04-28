//
// Copyright 2008-10 (C) Tom Parker <thpr@users.sourceforge.net>
// Copyright 2001 (C) Bryan McRoberts <merton_monk@yahoo.com>
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
// Translation of pcgen.persistence.lst.GenericLoader
import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/object_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/string_key.dart';
import 'package:flutter_pcgen/src/core/skill.dart';
import 'package:flutter_pcgen/src/persistence/lst/lst_utils.dart';
import 'package:flutter_pcgen/src/rules/context/load_context.dart';
import 'package:flutter_pcgen/src/persistence/lst/lst_object_file_loader.dart';
import 'package:flutter_pcgen/src/persistence/lst/source_entry.dart';

// Generic loader for CDOMObjects — creates an instance via [factory] then applies LST tokens.
class GenericLoader<T extends CDOMObject> extends LstObjectFileLoader<T> {
  final T Function() factory;
  final List<Function(LoadContext, T, String, SourceEntry)> _tokenHandlers = [];

  GenericLoader(this.factory);

  void addTokenHandler(Function(LoadContext, T, String, SourceEntry) handler) {
    _tokenHandlers.add(handler);
  }

  @override
  T? parseLine(LoadContext context, T? object, String lstLine, SourceEntry source) {
    final bool isNew = object == null;
    final T po = isNew ? factory() : object;

    final fields = lstLine.split('\t');
    if (fields.isEmpty) return null;

    po.setName(fields[0]);
    po.putObject(ObjectKey.sourceCampaign, source.getCampaign());
    po.setSourceURI(source.getURI());

    if (isNew) {
      context.getReferenceContext().register(po);
    }

    for (int i = 1; i < fields.length; i++) {
      _processToken(context, po, source, fields[i]);
    }

    completeObject(context, source, po);
    return null; // one line per object
  }

  void _processToken(LoadContext context, T obj, SourceEntry source, String token) {
    if (token.trim().isEmpty) return;

    // Dispatch common tokens understood by all CDOMObjects.
    final (tag, value) = LstUtils.splitToken(token);
    if (value.isNotEmpty) {
      switch (tag.toUpperCase()) {
        case 'TYPE':
          // TYPE:Fighter.Magic — dot-separated list of type tags.
          for (final t in value.split('.')) {
            if (t.isNotEmpty) {
              try { obj.addToListFor(ListKey.getConstant<String>('TYPE'), t); } catch (_) {}
            }
          }
          return;
        case 'DESC':
          try { obj.putString(StringKey.description, value); } catch (_) {}
          return;
        case 'OUTPUTNAME':
          try { obj.putString(StringKey.outputName, value); } catch (_) {}
          return;
        case 'SOURCELONG':
          try { obj.putString(StringKey.sourceLong, value); } catch (_) {}
          return;
        case 'SOURCESHORT':
          try { obj.putString(StringKey.sourceShort, value); } catch (_) {}
          return;
        case 'SOURCEWEB':
          try { obj.putString(StringKey.sourceWeb, value); } catch (_) {}
          return;
        case 'KEY':
          try { obj.setKeyName(value); } catch (_) {}
          return;
        case 'SORTKEY':
          try { obj.putString(StringKey.sortKey, value); } catch (_) {}
          return;
        case 'ABB':
          // Abbreviation — e.g. ABB:STR for Strength stat
          try { obj.putString(StringKey.abbKr, value); } catch (_) {}
          return;
        case 'STATMOD':
          // Stat modifier formula — skip (formula system not yet wired)
          return;
        case 'DEFINE':
          // DEFINE:VARNAME|expression — skip
          return;
        case 'BONUSSPELLLEVEL':
        case 'BASESTATSCORE':
        case 'STATRANGE':
        case 'COST':
        case 'MAXLEVEL':
        case 'MAXHD':
        case 'LEGS':
        case 'HANDS':
        case 'FACE':
        case 'REACH':
        case 'UNENCUMBEREDMOVE':
          // Numeric/complex tokens — skip for now
          return;
        case 'KEY_STAT':
          // Skill key ability stat abbreviation (e.g. KEY_STAT:STR).
          try {
            obj.putObject(
              ObjectKey.getConstant<dynamic>('KEY_STAT'),
              KeyStatRef(value),
            );
          } catch (_) {}
          return;
        case 'USE_UNTRAINED':
          try {
            obj.putObject(
              ObjectKey.getConstant<bool>('USE_UNTRAINED', defaultValue: true),
              value.toUpperCase() != 'NO',
            );
          } catch (_) {}
          return;
        case 'EXCLUSIVE':
          try {
            obj.putObject(
              ObjectKey.getConstant<bool>('EXCLUSIVE', defaultValue: false),
              value.toUpperCase() == 'YES',
            );
          } catch (_) {}
          return;
        case 'SIZE':
          try { obj.putString(StringKey.sizeformula, value); } catch (_) {}
          return;
        case 'MOVE':
          // MOVE:Walk,30 — store raw movement string
          try { obj.putString(StringKey.tempvalue, value); } catch (_) {}
          return;
        case 'XTRASKILLPTSPERLVL':
          // Extra skill points per level (bonus, e.g. Human gets +1)
          try {
            obj.putObject(ObjectKey.getConstant<int>('XTRA_SKILL_PTS'), int.tryParse(value) ?? 0);
          } catch (_) {}
          return;
        case 'STARTFEATS':
          try {
            obj.putObject(ObjectKey.getConstant<int>('START_FEATS'), int.tryParse(value) ?? 0);
          } catch (_) {}
          return;
        case 'CR':
          try { obj.putString(StringKey.subregion, value); } catch (_) {}
          return;
        case 'RACETYPE':
          try { obj.addToListFor(ListKey.getConstant<String>('TYPE'), 'RACETYPE:$value'); } catch (_) {}
          return;
        case 'RACESUBTYPE':
          try { obj.addToListFor(ListKey.getConstant<String>('TYPE'), 'RACESUBTYPE:$value'); } catch (_) {}
          return;
        default:
          break; // fall through to registered handlers
      }
    }

    // Skip PRE/BONUS/AUTO tokens for now (complex formula system).
    if (LstUtils.isPrereqToken(tag) || LstUtils.isBonusToken(tag) ||
        tag.toUpperCase() == 'AUTO' || tag.toUpperCase() == 'CHOOSE') {
      return;
    }

    // Registered token handlers (added via addTokenHandler).
    for (final handler in _tokenHandlers) {
      handler(context, obj, token, source);
    }
  }

  @override
  T? getObjectKeyed(LoadContext context, String key) {
    return context.getReferenceContext().getAllConstructed<T>(T).cast<T?>().firstWhere(
      (o) => o?.getKeyName() == key,
      orElse: () => null,
    );
  }
}
