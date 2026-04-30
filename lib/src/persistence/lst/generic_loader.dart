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
import 'package:flutter_pcgen/src/rules/parsed_bonus.dart';

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
          return;
        case 'DEFINE':
          return;
        case 'BONUS':
          _parseBonusToken(obj, value);
          return;
        case 'COST':
          try { obj.putString(StringKey.cost, value); } catch (_) {}
          return;
        case 'WT':
          try {
            obj.putObject(
              ObjectKey.getConstant<double>('WEIGHT'),
              double.tryParse(value) ?? 0.0,
            );
          } catch (_) {}
          return;
        case 'PROFICIENCY':
          // PROFICIENCY:WEAPON|SwordLong — store weapon proficiency name
          try {
            final idx = value.indexOf('|');
            if (idx > 0) {
              obj.putString(StringKey.targetArea, value.substring(idx + 1));
            }
          } catch (_) {}
          return;
        case 'WIELD':
          // WIELD:TwoHanded|OneHanded|Light etc.
          try { obj.putString(StringKey.nameText, value); } catch (_) {}
          return;
        case 'DAMAGE':
          try { obj.putString(StringKey.damage, value); } catch (_) {}
          return;
        case 'RANGE':
          // Weapon range in feet — store in itemcreate for now
          try { obj.putString(StringKey.itemcreate, value); } catch (_) {}
          return;
        case 'SCHOOL':
          // Spell school (Evocation, Conjuration, etc.)
          try { obj.putString(StringKey.genre, value); } catch (_) {}
          return;
        case 'SUBSCHOOL':
          try { obj.putString(StringKey.setting, value); } catch (_) {}
          return;
        case 'DESCRIPTOR':
          try { obj.putString(StringKey.dataFormat, value); } catch (_) {}
          return;
        case 'CLASSES':
          // CLASSES:Wizard=3|Sorcerer=3|Cleric=5|...
          try { obj.putString(StringKey.campaignSetting, value); } catch (_) {}
          return;
        case 'CASTTIME':
        case 'CASTINGTIME':
          // Spell casting time
          try { obj.putString(StringKey.duration, value); } catch (_) {}
          return;
        case 'DURATION':
          // Spell duration (e.g. "1 round/level")
          try { obj.putString(StringKey.help, value); } catch (_) {}
          return;
        case 'COMPS':
          // Spell components (V, S, M, etc.)
          try { obj.putString(StringKey.spellComponents, value); } catch (_) {}
          return;
        case 'SAVEINFO':
          // Saving throw info for spell
          try { obj.putString(StringKey.convertName, value); } catch (_) {}
          return;
        case 'SPELLRANGE':
          try { obj.putString(StringKey.spellRange, value); } catch (_) {}
          return;
        case 'STAT':
          // STAT:CL (for spell level checks)
          break;
        case 'CRITRANGE':
        case 'CRITMULT':
        case 'FUMBLERANGE':
        case 'BONUSSPELLLEVEL':
        case 'BASESTATSCORE':
        case 'STATRANGE':
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
        case 'ABILITY':
          // ABILITY:Category|AUTOMATIC|Name[|!PRE...] — store automatic ability names
          // so racial stat bonuses from ability chains can be resolved later.
          final abParts = value.split('|');
          if (abParts.length >= 3 &&
              abParts[1].trim().toUpperCase() == 'AUTOMATIC') {
            final rawName = abParts[2].trim();
            // Strip any leading conditional prefix (e.g. name starts with '!')
            if (rawName.isNotEmpty && !rawName.startsWith('!') &&
                !rawName.startsWith('PRE')) {
              try {
                obj.addToListFor(
                  ListKey.getConstant<String>('AUTO_ABILITIES'), rawName);
              } catch (_) {}
            }
          }
          return;
        default:
          break; // fall through to registered handlers
      }
    }

    // Store PRE tokens as ParsedPrereq for the rules engine.
    if (LstUtils.isPrereqToken(tag)) {
      final prereq = ParsedPrereq.parse('$tag:$value');
      if (prereq != null) {
        try {
          obj.addToListFor(
            ListKey.getConstant<ParsedPrereq>('PARSED_PREREQ'), prereq);
        } catch (_) {}
      }
      return;
    }

    if (tag.toUpperCase() == 'AUTO' || tag.toUpperCase() == 'CHOOSE') {
      return;
    }

    // Registered token handlers (added via addTokenHandler).
    for (final handler in _tokenHandlers) {
      handler(context, obj, token, source);
    }
  }

  /// Parse a BONUS: token and store as a [ParsedBonus] on the object.
  ///
  /// All bonus categories are stored uniformly so the rules engine can
  /// evaluate them at runtime against the current character state.
  /// Additionally, STAT and CHECKS bonuses are stored in the legacy
  /// STAT_BONUS / masterCheckFormula fields for backward compatibility.
  void _parseBonusToken(T obj, String value) {
    final bonus = ParsedBonus.parse(value);
    if (bonus == null) return;

    // Store as structured ParsedBonus for the rules engine.
    try {
      obj.addToListFor(
        ListKey.getConstant<ParsedBonus>('PARSED_BONUS'),
        bonus,
      );
    } catch (_) {}

    // ---- Legacy compatibility: STAT and CHECKS ----

    if (bonus.category == 'STAT') {
      // Only for simple integer formulas (no prerequisite) — the BFS racial
      // bonus chain still uses STAT_BONUS strings.
      final intVal = int.tryParse(bonus.formula);
      if (intVal != null && bonus.prereqs.isEmpty) {
        for (final tgt in bonus.targets) {
          final s = tgt.toUpperCase();
          if (s.isNotEmpty) {
            try {
              obj.addToListFor(
                ListKey.getConstant<String>('STAT_BONUS'),
                '$s:$intVal',
              );
            } catch (_) {}
          }
        }
      }
    }

    if (bonus.category == 'CHECKS' || bonus.category == 'SAVE') {
      // Derive Good/Poor save for PCClass.isSaveGood() fallback.
      final saveParts = bonus.targets.join(',').toUpperCase();
      final formula   = bonus.formula.toLowerCase();
      String saveKey = '';
      if (saveParts.contains('FORT')) saveKey = 'Fortitude';
      else if (saveParts.contains('REF'))  saveKey = 'Reflex';
      else if (saveParts.contains('WILL') || saveParts.contains('WIL')) saveKey = 'Will';
      if (saveKey.isNotEmpty) {
        final isGood = formula.contains('/2') || formula.contains('*.5') ||
            formula.contains('*0.5') || formula.contains('+2') || formula.contains('cl');
        final type = isGood ? 'Good' : 'Poor';
        try {
          final existing = obj.getString(StringKey.masterCheckFormula) ?? '';
          if (!existing.contains(saveKey)) {
            final updated = existing.isEmpty ? '$saveKey:$type' : '$existing,$saveKey:$type';
            obj.putString(StringKey.masterCheckFormula, updated);
          }
        } catch (_) {}
      }
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
