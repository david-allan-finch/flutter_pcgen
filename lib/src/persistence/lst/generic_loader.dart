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
import 'package:flutter_pcgen/src/rules/parsed_choose.dart';

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
        case 'ACCHECK':
          // ACCHECK:-5 — armor check penalty (negative = penalty)
          try {
            obj.putObject(
              ObjectKey.getConstant<int>('ACCHECK'),
              int.tryParse(value.trim()) ?? 0,
            );
          } catch (_) {}
          return;
        case 'MAXDEX':
          // MAXDEX:2 — maximum DEX bonus to AC while wearing this armor
          try {
            final v = int.tryParse(value.trim());
            if (v != null) {
              obj.putObject(ObjectKey.getConstant<int>('MAXDEX'), v);
            }
          } catch (_) {}
          return;
        case 'SPELLFAILURE':
          // SPELLFAILURE:30 — arcane spell failure chance in percent
          try {
            obj.putObject(
              ObjectKey.getConstant<int>('SPELLFAILURE'),
              int.tryParse(value.trim()) ?? 0,
            );
          } catch (_) {}
          return;
        case 'EQMOD':
          // EQMOD:STEEL|LEATHER — modifier keys; store raw for future processing
          try {
            for (final mod in value.split('|')) {
              final m = mod.trim();
              if (m.isNotEmpty) {
                obj.addToListFor(ListKey.getConstant<String>('EQMOD_KEYS'), m);
              }
            }
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
        case 'MULT':
          // MULT:YES — feat/ability can be taken multiple times (once per CHOOSE selection)
          try {
            obj.putObject(ObjectKey.getConstant<bool>('MULT_OK'),
                value.toUpperCase() == 'YES');
          } catch (_) {}
          return;
        case 'STACK':
          // STACK:YES/NO — whether multiple instances of the same bonus stack
          try {
            obj.putObject(ObjectKey.getConstant<bool>('STACK_OK'),
                value.toUpperCase() == 'YES');
          } catch (_) {}
          return;
        case 'SELECT':
          // SELECT:N — number of choices to make (default 1)
          return;
        case 'COST':
          // COST:N — point cost (e.g. for ability pools)
          return;
        case 'VISIBLE':
          return;
        case 'SPELLLEVEL':
          // SPELLLEVEL:DOMAIN|Fire=1|Burning Hands|Fire=2|Produce Flame|...
          // SPELLLEVEL:Wizard=3|Sorcerer=3 (on spell objects — stored differently)
          _parseSpellLevel(obj, value);
          return;
        case 'CRITMULT':
          // CRITMULT:x2 — critical hit multiplier
          try { obj.putString(StringKey.critMult, value.trim()); } catch (_) {}
          return;
        case 'CRITRANGE':
          // CRITRANGE:1 means 20 (1 die face), 3 means 18-20
          try {
            obj.putObject(ObjectKey.getConstant<int>('CRITRANGE'),
                int.tryParse(value.trim()) ?? 1);
          } catch (_) {}
          return;
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
        case 'VISION':
          // VISION:Darkvision (60')|Low-Light Vision
          for (final v in value.split('|')) {
            final vt = v.trim();
            if (vt.isNotEmpty) {
              try { obj.addToListFor(ListKey.getConstant<String>('VISION_TYPES'), vt); } catch (_) {}
            }
          }
          return;
        case 'NATURALATTACKS':
          // NATURALATTACKS:Bite,Weapon.Natural.Melee.Bludgeoning,*1,1d6|Claw,...,*2,1d4
          for (final attack in value.split('|')) {
            final parts = attack.split(',');
            if (parts.length >= 4) {
              final name   = parts[0].trim();
              final count  = parts[2].trim().replaceAll('*', '');
              final damage = parts[3].trim();
              try {
                obj.addToListFor(
                  ListKey.getConstant<String>('NATURAL_ATTACKS'),
                  '$name:$count:$damage',
                );
              } catch (_) {}
            }
          }
          return;
        case 'ACHECK':
          // ACHECK:YES/NO/WEIGHT — does armor check penalty apply to this skill?
          try {
            obj.putObject(
              ObjectKey.getConstant<bool>('ACHECK'),
              value.toUpperCase() == 'YES' || value.toUpperCase() == 'WEIGHT',
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
          // SIZE:M — creature size (F D T S M L H G C P)
          try {
            obj.putString(StringKey.sizeformula, value.trim());
          } catch (_) {}
          return;
        case 'MOVE':
          // MOVE:Walk,30,Fly,60,Swim,20 — movement speeds (type,feet pairs)
          try {
            obj.putString(StringKey.tempvalue, value);
            // Also parse into structured map
            final parts = value.split(',');
            final moveMap = <String, int>{};
            for (int i = 0; i + 1 < parts.length; i += 2) {
              final type  = parts[i].trim();
              final speed = int.tryParse(parts[i + 1].trim()) ?? 0;
              if (type.isNotEmpty) moveMap[type] = speed;
            }
            if (moveMap.isNotEmpty) {
              obj.putObject(ObjectKey.getConstant<Map>('MOVE_SPEEDS'), moveMap);
            }
          } catch (_) {}
          return;
        case 'LANGBONUS':
          // LANGBONUS:Goblin,Orc,Giant — bonus language choices offered to character
          for (final lang in value.split(',')) {
            final l = lang.trim();
            if (l.isNotEmpty) {
              try {
                obj.addToListFor(ListKey.getConstant<String>('LANG_BONUS'), l);
              } catch (_) {}
            }
          }
          return;
        case 'STARTFEATS':
          try {
            obj.putObject(ObjectKey.getConstant<int>('START_FEATS'),
                int.tryParse(value) ?? 0);
          } catch (_) {}
          return;
        case 'UNENCUMBEREDMOVE':
          // UNENCUMBEREDMOVE:HeavyLoad|HeavyArmor — ignore for now
          return;
        case 'FACT':
          // FACT:FieldName|Value — e.g. FACT:BaseSize|M, FACT:ClassType|PC
          {
            final pipeIdx = value.indexOf('|');
            if (pipeIdx > 0) {
              final factName = value.substring(0, pipeIdx).toUpperCase();
              final factVal  = value.substring(pipeIdx + 1).trim();
              switch (factName) {
                case 'BASESIZE':
                  try { obj.putString(StringKey.sizeformula, factVal); } catch (_) {}
                  break;
                case 'CLASSTYPE':
                  try { obj.putString(StringKey.classType, factVal); } catch (_) {}
                  break;
                case 'ABB':
                  try { obj.putString(StringKey.abbKr, factVal); } catch (_) {}
                  break;
                case 'SPELLTYPE':
                  break; // used by class loader
                default:
                  break;
              }
            }
          }
          return;
        case 'GROUP':
          // GROUP:UNSELECTED etc. — ignore for now
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

    if (tag.toUpperCase() == 'CHOOSE') {
      final choose = ParsedChoose.parse(value);
      try {
        obj.putObject(ObjectKey.getConstant<ParsedChoose>('PARSED_CHOOSE'), choose);
      } catch (_) {}
      return;
    }

    if (tag.toUpperCase() == 'AUTO') {
      _parseAutoToken(obj, value);
      return;
    }

    // Registered token handlers (added via addTokenHandler).
    for (final handler in _tokenHandlers) {
      handler(context, obj, token, source);
    }
  }

  /// Parse SPELLLEVEL: token.
  ///
  /// On domain objects: SPELLLEVEL:DOMAIN|DomainName=Level|SpellName|...
  ///   → stores 'Level:SpellName' in DOMAIN_SPELLS list
  /// On spell objects: SPELLLEVEL:Wizard=3|Cleric=5|...
  ///   → stores 'ClassName=Level' pairs in SPELL_CLASS_LEVELS list (for class spell lists)
  void _parseSpellLevel(T obj, String value) {
    final parts = value.split('|');
    if (parts.isEmpty) return;

    if (parts[0].toUpperCase() == 'DOMAIN') {
      // Domain spell list: alternating DomainName=Level, SpellName pairs
      // e.g.: DOMAIN|Fire=1|Burning Hands|Fire=2|Produce Flame
      int i = 1;
      while (i + 1 < parts.length) {
        final levelPart = parts[i].trim();   // e.g. "Fire=1"
        final spellName = parts[i + 1].trim();
        final eq = levelPart.indexOf('=');
        if (eq > 0 && spellName.isNotEmpty) {
          final level = int.tryParse(levelPart.substring(eq + 1));
          if (level != null) {
            try {
              obj.addToListFor(
                ListKey.getConstant<String>('DOMAIN_SPELLS'),
                '$level:$spellName',
              );
            } catch (_) {}
          }
        }
        i += 2;
      }
    } else {
      // Spell object class list: e.g. Wizard=3|Sorcerer=3|Cleric=5
      // Store the raw class=level pairs for spell lookup by class
      final classLevels = <String>[];
      for (final p in parts) {
        final eq = p.indexOf('=');
        if (eq > 0) {
          final cls   = p.substring(0, eq).trim();
          final level = int.tryParse(p.substring(eq + 1).trim());
          if (cls.isNotEmpty && level != null) {
            classLevels.add('$cls=$level');
            // Also update the CLASSES: (campaignSetting) string for backward compat
            try {
              final existing =
                  obj.getString(StringKey.campaignSetting) ?? '';
              if (!existing.contains('$cls=')) {
                final updated = existing.isEmpty
                    ? '$cls=$level'
                    : '$existing|$cls=$level';
                obj.putString(StringKey.campaignSetting, updated);
              }
            } catch (_) {}
          }
        }
      }
      for (final cl in classLevels) {
        try {
          obj.addToListFor(
            ListKey.getConstant<String>('SPELL_CLASS_LEVELS'), cl);
        } catch (_) {}
      }
    }
  }

  /// Parse AUTO: tokens. Currently handles AUTO:LANG and AUTO:WEAPONPROF.
  void _parseAutoToken(T obj, String value) {
    final pipeIdx = value.indexOf('|');
    final autoType = pipeIdx > 0
        ? value.substring(0, pipeIdx).toUpperCase()
        : value.toUpperCase();
    final autoValue = pipeIdx > 0 ? value.substring(pipeIdx + 1) : '';

    if (autoType == 'LANG') {
      // AUTO:LANG|Common|Elvish|%LIST
      for (final lang in autoValue.split('|')) {
        final l = lang.trim();
        if (l.isNotEmpty && !l.startsWith('%')) {
          try {
            obj.addToListFor(ListKey.getConstant<String>('AUTO_LANG'), l);
          } catch (_) {}
        }
      }
    } else if (autoType == 'WEAPONPROF') {
      for (final prof in autoValue.split('|')) {
        final p = prof.trim();
        if (p.isNotEmpty && !p.startsWith('%') && !p.startsWith('TYPE=')) {
          try {
            obj.addToListFor(ListKey.getConstant<String>('AUTO_WEAPONPROF'), p);
          } catch (_) {}
        }
      }
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
