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
import 'package:flutter/foundation.dart';
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
    po.putObject(CDOMObjectKey.sourceCampaign, source.getCampaign());
    po.setSourceURI(source.getURI());

    if (isNew) {
      context.getReferenceContext().register(po);
    }

    for (int i = 1; i < fields.length; i++) {
      processToken(context, po, source, fields[i]);
    }

    completeObject(context, source, po);
    return null; // one line per object
  }

  void processToken(LoadContext context, T obj, SourceEntry source, String token) {
    if (token.trim().isEmpty) return;

    final (tag, value) = LstUtils.splitToken(token);
    final tagUp = tag.toUpperCase();

    // ---- Pattern-based dispatch (handles any subtype generically) ----

    // All PRE*/!PRE* tokens → ParsedPrereq regardless of specific subtype.
    if (LstUtils.isPrereqToken(tag)) {
      final prereq = ParsedPrereq.parse('$tag:$value');
      if (prereq != null) {
        try { obj.addToListFor(ListKey.getConstant<ParsedPrereq>('PARSED_PREREQ'), prereq); } catch (_) {}
      }
      return;
    }

    // CHOOSE → ParsedChoose
    if (tagUp == 'CHOOSE') {
      final choose = ParsedChoose.parse(value);
      try { obj.putObject(CDOMObjectKey.getConstant<ParsedChoose>('PARSED_CHOOSE'), choose); } catch (_) {}
      return;
    }

    // AUTO → _parseAutoToken
    if (tagUp == 'AUTO') {
      _parseAutoToken(obj, value);
      return;
    }

    // Token-specific dispatch.
    if (value.isNotEmpty) {
      switch (tagUp) {
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
          // DEFINE:VarName|initialValue — store for two-pass VAR resolution.
          try {
            final pipe = value.indexOf('|');
            if (pipe > 0) {
              final varName = value.substring(0, pipe).trim();
              final initVal = value.substring(pipe + 1).trim();
              if (varName.isNotEmpty) {
                obj.addToListFor(
                  ListKey.getConstant<String>('VAR_DEFINES'),
                  '$varName=$initVal',
                );
              }
            }
          } catch (_) {}
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
              CDOMObjectKey.getConstant<double>('WEIGHT'),
              double.tryParse(value) ?? 0.0,
            );
          } catch (_) {}
          return;
        case 'ACCHECK':
          // ACCHECK:-5 — armor check penalty (negative = penalty)
          try {
            obj.putObject(
              CDOMObjectKey.getConstant<int>('ACCHECK'),
              int.tryParse(value.trim()) ?? 0,
            );
          } catch (_) {}
          return;
        case 'MAXDEX':
          // MAXDEX:2 — maximum DEX bonus to AC while wearing this armor
          try {
            final v = int.tryParse(value.trim());
            if (v != null) {
              obj.putObject(CDOMObjectKey.getConstant<int>('MAXDEX'), v);
            }
          } catch (_) {}
          return;
        case 'SPELLFAILURE':
          // SPELLFAILURE:30 — arcane spell failure chance in percent
          try {
            obj.putObject(
              CDOMObjectKey.getConstant<int>('SPELLFAILURE'),
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
            obj.putObject(CDOMObjectKey.getConstant<bool>('MULT_OK'),
                value.toUpperCase() == 'YES');
          } catch (_) {}
          return;
        case 'STACK':
          // STACK:YES/NO — whether multiple instances of the same bonus stack
          try {
            obj.putObject(CDOMObjectKey.getConstant<bool>('STACK_OK'),
                value.toUpperCase() == 'YES');
          } catch (_) {}
          return;
        case 'SELECT':
          // SELECT:N — number of choices to make (default 1)
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
            obj.putObject(CDOMObjectKey.getConstant<int>('CRITRANGE'),
                int.tryParse(value.trim()) ?? 1);
          } catch (_) {}
          return;
        case 'FUMBLERANGE':
        case 'BONUSSPELLLEVEL':
        case 'BASESTATSCORE':
        case 'STATRANGE':
        case 'MAXLEVEL':
        case 'MAXHD':
          return;
        case 'KEYSTAT':
        case 'KEY_STAT':
          // Skill key ability stat abbreviation (e.g. KEYSTAT:INT).
          try {
            obj.putObject(
              CDOMObjectKey.getConstant<dynamic>('KEY_STAT'),
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
              CDOMObjectKey.getConstant<bool>('ACHECK'),
              value.toUpperCase() == 'YES' || value.toUpperCase() == 'WEIGHT',
            );
          } catch (_) {}
          return;
        case 'USE_UNTRAINED':
        case 'USEUNTRAINED':   // LST files use this form (no underscore)
          try {
            obj.putObject(
              CDOMObjectKey.getConstant<bool>('USE_UNTRAINED', defaultValue: true),
              value.toUpperCase() != 'NO',
            );
          } catch (_) {}
          return;
        case 'EXCLUSIVE':
          try {
            obj.putObject(
              CDOMObjectKey.getConstant<bool>('EXCLUSIVE', defaultValue: false),
              value.toUpperCase() == 'YES',
            );
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
            obj.putObject(CDOMObjectKey.getConstant<int>('START_FEATS'),
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
            obj.putObject(CDOMObjectKey.getConstant<int>('XTRA_SKILL_PTS'), int.tryParse(value) ?? 0);
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

        // ---- Race / creature tokens ----------------------------------------
        case 'MOVE':
          // MOVE:Walk,30  or  MOVE:Walk,30,Swim,20
          try {
            final parts = value.split(',');
            for (int i = 0; i + 1 < parts.length; i += 2) {
              final type = parts[i].trim();
              final speed = int.tryParse(parts[i + 1].trim()) ?? 0;
              if (type.isNotEmpty) {
                obj.addToListFor(
                  ListKey.getConstant<String>('MOVE_SPEEDS'), '$type:$speed');
              }
            }
          } catch (_) {}
          return;
        case 'SIZE':
          try { obj.putObject(CDOMObjectKey.getConstant<String>('RACE_SIZE'), value.trim()); } catch (_) {}
          return;
        case 'FAVCLASS':
          try { obj.putString(StringKey.abbreviation, value); } catch (_) {}
          return;
        case 'FACE':
        case 'LEGS':
        case 'HANDS':
        case 'ARMS':
        case 'TAIL':
          return; // cosmetic — ignore
        case 'REACH':
          try { obj.putObject(CDOMObjectKey.getConstant<int>('REACH'), int.tryParse(value.trim()) ?? 5); } catch (_) {}
          return;
        case 'SR':
          try { obj.putObject(CDOMObjectKey.getConstant<String>('SR_FORMULA'), value.trim()); } catch (_) {}
          return;
        case 'DR':
          try { obj.addToListFor(ListKey.getConstant<String>('DR_LIST'), value.trim()); } catch (_) {}
          return;
        case 'TEMPLATE':
          // TEMPLATE:TemplateName|TemplateName2
          for (final t in value.split('|')) {
            final name = t.trim();
            if (name.isNotEmpty && !name.toUpperCase().startsWith('CHOOSE')) {
              try { obj.addToListFor(ListKey.getConstant<String>('AUTO_TEMPLATES'), name); } catch (_) {}
            }
          }
          return;
        case 'SPELLS':
          // SPELLS:Innate|TIMES=1|SpellName,DC — store raw for innate spell use
          try { obj.addToListFor(ListKey.getConstant<String>('INNATE_SPELLS'), value); } catch (_) {}
          return;
        case 'UDAM':
          // UDAM:1d3 — unarmed damage (store in damage field if not already set)
          try { obj.putString(StringKey.damage, value); } catch (_) {}
          return;

        // ---- Equipment tokens -----------------------------------------------
        case 'VISIBLE':
          try {
            obj.putObject(CDOMObjectKey.getConstant<String>('VISIBLE'),
                value.trim().toUpperCase());
          } catch (_) {}
          return;
        case 'BASEITEM':
          try { obj.putString(StringKey.altName, value.trim()); } catch (_) {}
          return;
        case 'SLOTS':
          try { obj.putObject(CDOMObjectKey.getConstant<int>('EQUIP_SLOTS'), int.tryParse(value.trim()) ?? 1); } catch (_) {}
          return;
        case 'PLUS':
          // PLUS:N — enhancement bonus (magic weapon/armor). Stored on the
          // equipment object; applied as BONUS:COMBAT|TOHIT/DAMAGE|N or
          // BONUS:COMBAT|AC|N (with type ENHANCEMENT/ARMORENHANCEMENT) when
          // the item is equipped in CharacterFacadeImpl._buildEquipBonuses().
          try { obj.putObject(CDOMObjectKey.getConstant<int>('PLUS'), int.tryParse(value.trim()) ?? 0); } catch (_) {}
          return;
        case 'ARMORTYPE':
          // ARMORTYPE:LIGHT/MEDIUM/HEAVY — armour category for proficiency checks.
          try { obj.putObject(CDOMObjectKey.getConstant<dynamic>('ARMOR_TYPE'), value.trim().toUpperCase()); } catch (_) {}
          return;
        case 'QUALITY':
          // QUALITY:Name|description — item quality tag
          try { obj.putString(StringKey.nameText, value.split('|').first.trim()); } catch (_) {}
          return;
        case 'CHARGES':
          // CHARGES:min|max — item charge limits (e.g. a wand)
          {
            final parts2 = value.split('|');
            final max = int.tryParse(parts2.last.trim()) ?? 0;
            try { obj.putObject(CDOMObjectKey.getConstant<int>('CHARGES'), max); } catch (_) {}
          }
          return;
        case 'ITYPE':
          // ITYPE:TYPE1.TYPE2 — additional item types
          for (final t in value.split('.')) {
            final tp = t.trim();
            if (tp.isNotEmpty) {
              try { obj.addToListFor(ListKey.getConstant<String>('ITYPE_LIST'), tp.toUpperCase()); } catch (_) {}
            }
          }
          return;
        case 'MODS':
          // MODS:YES/NO — whether equipment mods can be applied
          return; // metadata only
        case 'VARIANTS':
          // VARIANTS:name1|name2 — alternate equipment names (cosmetic)
          return;
        case 'QUALITY':
          return;
        // ---- Special ability text ----
        case 'SAB':
          for (final s in value.split('|')) {
            final t = s.trim();
            if (t.isNotEmpty) {
              try { obj.addToListFor(ListKey.getConstant<String>('SAB_LIST'), t); } catch (_) {}
            }
          }
          return;

        case 'SPROP':
          // Special property for equipment — store for display
          try { obj.addToListFor(ListKey.getConstant<String>('SPROP_LIST'), value.trim()); } catch (_) {}
          return;

        // ---- Class skill lists ----
        case 'CSKILL':
          for (final s in value.split('|')) {
            final skill = s.trim();
            if (skill.isNotEmpty) {
              try { obj.addToListFor(ListKey.getConstant<String>('CLASS_SKILLS'), skill); } catch (_) {}
            }
          }
          return;
        case 'CCSKILL':
          for (final s in value.split('|')) {
            final skill = s.trim();
            if (skill.isNotEmpty) {
              try { obj.addToListFor(ListKey.getConstant<String>('CROSS_CLASS_SKILLS'), skill); } catch (_) {}
            }
          }
          return;
        case 'MONCSKILL':
          for (final s in value.split('|')) {
            final skill = s.trim();
            if (skill.isNotEmpty) {
              try { obj.addToListFor(ListKey.getConstant<String>('MON_CLASS_SKILLS'), skill); } catch (_) {}
            }
          }
          return;

        // ---- Auto-granted languages ----
        case 'LANGAUTO':
          for (final lang in value.split(',')) {
            final l = lang.trim();
            if (l.isNotEmpty && !l.startsWith('%')) {
              try { obj.addToListFor(ListKey.getConstant<String>('AUTO_LANG'), l); } catch (_) {}
            }
          }
          return;

        // ---- Class / creature stats ----
        case 'HD':
          // HD:N — hit dice sides (e.g. HD:8 on a monster race means d8 HD)
          try { obj.putObject(CDOMObjectKey.getConstant<int>('HIT_DIE'), int.tryParse(value.trim()) ?? 8); } catch (_) {}
          return;
        case 'FAVOREDCLASS':
          // FAVOREDCLASS:Wizard|Any — favoured class(es) for this race
          try { obj.putString(StringKey.abbreviation, value.split('|').first.trim()); } catch (_) {}
          return;
        case 'WEAPONBONUS':
          // WEAPONBONUS:TOHIT|N — bonus to attack with a specific weapon type
          // Store as a BONUS entry for weapon type
          try {
            final wp = value.split('|');
            if (wp.length >= 2) {
              obj.addToListFor(ListKey.getConstant<String>('WEAPON_BONUS_LIST'), value);
            }
          } catch (_) {}
          return;
        case 'SPELLKNOWN':
          // SPELLKNOWN:CLASS.ClassName|0=4|1=2 — spells known per level
          // These supplement spontaneous caster tables already set by the class loader.
          return; // handled by class loader; ignore extra entries
        case 'SPELLLIST':
          // SPELLLIST:1|CLASS.ClassName — extra spell lists
          return; // class-level handling; ignore in generic loader
        case 'ADDSPELLLEVEL':
          // ADDSPELLLEVEL:N — adds N levels to effective spell casting level
          // (used by some prestige class abilities)
          return; // complex prerequisite handling; ignore for now
        case 'SITUATION':
          // SITUATION:Name|Formula — situational bonus (not always applied)
          try { obj.addToListFor(ListKey.getConstant<String>('SITUATION_LIST'), value); } catch (_) {}
          return;
        case 'TEMPDESC':
          // TEMPDESC:Description — description for a temporary bonus
          try { obj.putString(StringKey.tempvalue, value.trim()); } catch (_) {}
          return;
        case 'TEMPVALUE':
          // TEMPVALUE:N — default value for a temporary bonus
          return; // stored on TEMPBONUS
        case 'HITDIE':
          try { obj.putString(StringKey.hdFormula, value.trim()); } catch (_) {}
          return;
        case 'STARTSKILLPTS':
          try { obj.putObject(CDOMObjectKey.getConstant<int>('START_SKILL_PTS'), int.tryParse(value.trim()) ?? 2); } catch (_) {}
          return;
        case 'LEVELSPERFEAT':
          try { obj.putObject(CDOMObjectKey.getConstant<int>('LEVELS_PER_FEAT'), int.tryParse(value.trim()) ?? 3); } catch (_) {}
          return;
        case 'LEVELADJUSTMENT':
          try { obj.putObject(CDOMObjectKey.getConstant<int>('LEVEL_ADJUSTMENT'), int.tryParse(value.trim()) ?? 0); } catch (_) {}
          return;
        case 'SKILLMULT':
          try { obj.putObject(CDOMObjectKey.getConstant<int>('SKILL_MULT'), int.tryParse(value.trim()) ?? 1); } catch (_) {}
          return;
        case 'KEYSTAT':
          try { obj.putString(StringKey.keystatFormula, value.trim()); } catch (_) {}
          return;

        // ---- ADD token ----
        case 'ADD':
          _parseAddToken(obj, value);
          return;

        // ---- Temporary bonuses ----
        case 'TEMPBONUS':
          try { obj.addToListFor(ListKey.getConstant<String>('TEMP_BONUS'), value); } catch (_) {}
          return;

        // ---- Feat/ability detail text ----
        case 'BENEFIT':
          try { obj.putString(StringKey.benefit, value); } catch (_) {}
          return;
        case 'ASPECT':
          try { obj.addToListFor(ListKey.getConstant<String>('ASPECT_LIST'), value); } catch (_) {}
          return;

        // ---- Monster info ----
        case 'MONSTERCLASS':
          try { obj.putString(StringKey.monsterClass, value); } catch (_) {}
          return;
        case 'HITDICEADVANCEMENT':
          try { obj.putString(StringKey.tempvalue, value); } catch (_) {}
          return;

        // ---- Starting kits ----
        case 'KIT':
          try { obj.addToListFor(ListKey.getConstant<String>('KIT_LIST'), value); } catch (_) {}
          return;

        // ---- Replacement and removal ----
        case 'REPLACES':
          for (final r in value.split('|')) {
            final t = r.trim();
            if (t.isNotEmpty) {
              try { obj.addToListFor(ListKey.getConstant<String>('REPLACES_LIST'), t); } catch (_) {}
            }
          }
          return;
        case 'REMOVE':
          try { obj.addToListFor(ListKey.getConstant<String>('REMOVE_LIST'), value); } catch (_) {}
          return;
        case 'QUALIFY':
          try { obj.addToListFor(ListKey.getConstant<String>('QUALIFY_LIST'), value); } catch (_) {}
          return;
        case 'SERVESAS':
          try { obj.addToListFor(ListKey.getConstant<String>('SERVES_AS'), value); } catch (_) {}
          return;

        // ---- Spell detail tokens ----
        case 'SPELLRES':
          try { obj.putObject(CDOMObjectKey.getConstant<bool>('SPELL_RES'), value.trim().toUpperCase() == 'YES'); } catch (_) {}
          return;
        case 'XPCOST':
          try { obj.putObject(CDOMObjectKey.getConstant<int>('XP_COST'), int.tryParse(value.trim()) ?? 0); } catch (_) {}
          return;

        case 'DEITYWEAP':
          // Deity's favoured weapon — store for auto-proficiency grant.
          try { obj.putString(StringKey.nameText, value.trim()); } catch (_) {}
          return;

        // ---- Pure metadata — no rules value, discard ----
        case 'SOURCEPAGE':
        case 'SOURCEWEB2':
        case 'SOURCELONG2':
        case 'SOURCESHORT2':
        case 'COMMENT':
        case 'NAMEISPI':
        case 'NAMEOPT':
        case 'DESCISIP':
        case 'FORMATCAT':
          return;

        // ---- Everything else: store generically so nothing is silently lost ----
        default:
          _storeExtraToken(obj, tag, value);
          return;
      }
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

  void _parseAutoToken(T obj, String value) {
    final pipeIdx = value.indexOf('|');
    final autoType = pipeIdx > 0
        ? value.substring(0, pipeIdx).toUpperCase()
        : value.toUpperCase();
    final autoValue = pipeIdx > 0 ? value.substring(pipeIdx + 1) : '';

    switch (autoType) {
      case 'LANG':
        for (final lang in autoValue.split('|')) {
          final l = lang.trim();
          if (l.isNotEmpty && !l.startsWith('%')) {
            try { obj.addToListFor(ListKey.getConstant<String>('AUTO_LANG'), l); } catch (_) {}
          }
        }
        break;
      case 'WEAPONPROF':
        for (final prof in autoValue.split('|')) {
          final p = prof.trim();
          if (p.isNotEmpty && !p.startsWith('%') && !p.startsWith('TYPE=')) {
            try { obj.addToListFor(ListKey.getConstant<String>('AUTO_WEAPONPROF'), p); } catch (_) {}
          }
        }
        break;
      case 'FEAT':
        for (final feat in autoValue.split('|')) {
          final f = feat.trim();
          if (f.isNotEmpty && !f.startsWith('%') && !f.startsWith('PRE')) {
            try { obj.addToListFor(ListKey.getConstant<String>('AUTO_FEATS'), f); } catch (_) {}
          }
        }
        break;
      case 'ARMORPROF':
        for (final prof in autoValue.split('|')) {
          final p = prof.trim();
          if (p.isNotEmpty && !p.startsWith('%')) {
            try { obj.addToListFor(ListKey.getConstant<String>('AUTO_ARMORPROF'), p); } catch (_) {}
          }
        }
        break;
      case 'SHIELDPROF':
        for (final prof in autoValue.split('|')) {
          final p = prof.trim();
          if (p.isNotEmpty && !p.startsWith('%')) {
            try { obj.addToListFor(ListKey.getConstant<String>('AUTO_SHIELDPROF'), p); } catch (_) {}
          }
        }
        break;
      default:
        break;
    }
  }

  void _parseAddToken(T obj, String value) {
    final pipeIdx = value.indexOf('|');
    final addType = pipeIdx > 0
        ? value.substring(0, pipeIdx).toUpperCase()
        : value.toUpperCase();
    final addValue = pipeIdx > 0 ? value.substring(pipeIdx + 1) : '';

    switch (addType) {
      case 'CLASSSKILLS':
        for (final s in addValue.split('|')) {
          final skill = s.trim();
          if (skill.isNotEmpty) {
            try { obj.addToListFor(ListKey.getConstant<String>('ADD_CLASS_SKILLS'), skill); } catch (_) {}
          }
        }
        break;
      case 'FEAT':
        if (addValue.isNotEmpty) {
          try { obj.addToListFor(ListKey.getConstant<String>('ADD_FEATS'), addValue); } catch (_) {}
        }
        break;
      case 'ABILITY':
        if (addValue.isNotEmpty) {
          try { obj.addToListFor(ListKey.getConstant<String>('ADD_ABILITIES'), addValue); } catch (_) {}
        }
        break;
      case 'LANGUAGE':
        for (final lang in addValue.split('|')) {
          final l = lang.trim();
          if (l.isNotEmpty) {
            try { obj.addToListFor(ListKey.getConstant<String>('LANG_BONUS'), l); } catch (_) {}
          }
        }
        break;
      default:
        break;
    }
  }

  // ---- Generic token storage -------------------------------------------------
  //
  // Any token not explicitly handled is stored in EXTRA_TOKENS_MAP so it is
  // never silently lost.  The map is keyed by TAG_NAME (upper-case) and each
  // value is the list of raw values seen for that tag.
  //
  // Retrieve with [getExtraTokenValues].

  static void _storeExtraToken(CDOMObject obj, String tag, String value) {
    final key = tag.trim().toUpperCase();
    if (key.isEmpty) return;
    try {
      final mapKey = CDOMObjectKey.getConstant<Map<String, List<String>>>('EXTRA_TOKENS_MAP');
      final existing = obj.getSafeObject(mapKey) as Map<String, List<String>>?
          ?? <String, List<String>>{};
      (existing[key] ??= []).add(value);
      obj.putObject(mapKey, existing);
    } catch (_) {}
    // Debug: log tokens we haven't explicitly coded so we can prioritise them.
    if (kDebugMode) {
      _unknownTags.add(key);
    }
  }

  /// Returns the stored values for [tag] on [obj], or an empty list.
  static List<String> getExtraTokenValues(CDOMObject obj, String tag) {
    try {
      final mapKey = CDOMObjectKey.getConstant<Map<String, List<String>>>('EXTRA_TOKENS_MAP');
      final m = obj.getSafeObject(mapKey) as Map<String, List<String>>?;
      return m?[tag.trim().toUpperCase()] ?? const [];
    } catch (_) { return const []; }
  }

  // In debug mode: accumulate unseen tag names and print a summary once.
  static final Set<String> _unknownTags = {};
  static bool _debugFlushed = false;

  static void flushUnknownTagReport() {
    if (!kDebugMode || _debugFlushed || _unknownTags.isEmpty) return;
    _debugFlushed = true;
    // ignore: avoid_print
    print('[GenericLoader] Tokens stored generically (not explicitly handled): '
        '${_unknownTags.toList()..sort()}');
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
