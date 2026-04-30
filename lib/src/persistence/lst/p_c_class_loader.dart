//
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
// Translation of pcgen.persistence.lst.PCClassLoader

import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/object_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/string_key.dart';
import 'package:flutter_pcgen/src/core/pc_class.dart';
import 'package:flutter_pcgen/src/core/sub_class.dart';
import 'package:flutter_pcgen/src/core/substitution_class.dart';
import 'package:flutter_pcgen/src/persistence/lst/lst_utils.dart';
import 'package:flutter_pcgen/src/rules/context/load_context.dart';
import 'package:flutter_pcgen/src/persistence/lst/lst_object_file_loader.dart';
import 'package:flutter_pcgen/src/persistence/lst/source_entry.dart';
import 'package:flutter_pcgen/src/rules/parsed_bonus.dart';

/// Loads PCClass (and SubClass / SubstitutionClass) objects from LST files.
///
/// In Java, PCClassLoader extends LstObjectFileLoader<PCClass>. The first
/// column of each line is "ClassName" for a new class, "ClassName.SUBCLASS"
/// for a sub-class header, "ClassName  <level>" for a class level definition,
/// etc. This Dart version provides the outer parse loop and dispatches to
/// helpers for the complex class-level logic.
class PCClassLoader extends LstObjectFileLoader<PCClass> {
  @override
  PCClass? parseLine(
      LoadContext context, PCClass? target, String lstLine, SourceEntry source) {
    final fields = lstLine.split('\t');
    if (fields.isEmpty) return target;

    final firstToken = fields[0].trim();
    if (firstToken.isEmpty) return target;

    final restOfLine = fields.sublist(1).join('\t');

    // Sub-class definition
    if (firstToken.endsWith('.SUBCLASS')) {
      if (target == null) return null;
      final scName = firstToken.substring(0, firstToken.length - 9);
      SubClass? sc = target.getSubClassKeyed(scName);
      if (sc == null) {
        sc = SubClass();
        sc.setName(scName);
        sc.setSourceURI(source.getURI().toString());
        target.addSubClass(sc);
      }
      _parseLineIntoClass(context, sc, source, restOfLine);
      return null;
    }

    // SubstitutionClass definition
    if (firstToken.endsWith('.SUBSTITUTIONCLASS')) {
      if (target == null) return null;
      final scName = firstToken.substring(0, firstToken.length - 18);
      SubstitutionClass? sc = target.getSubstitutionClassKeyed(scName);
      if (sc == null) {
        sc = SubstitutionClass();
        sc.setName(scName);
        sc.setSourceURI(source.getURI().toString());
        target.addSubstitutionClass(sc);
      }
      _parseLineIntoClass(context, sc, source, restOfLine);
      return null;
    }

    // Class-level definition: "ClassName    <level>" (tab-separated)
    // The level is an integer; this line applies to a specific PCClassLevel.
    // In the full implementation this would check firstToken for a level number
    // and apply to the PCClassLevel. For now we apply to the class as a whole.

    // New class or .MOD handled by parent
    PCClass pcClass = target ?? PCClass();
    if (target == null) {
      pcClass.setName(firstToken);
      pcClass.setSourceURI(source.getURI().toString());
      context.getReferenceContext().register(pcClass);
    }

    _parseLineIntoClass(context, pcClass, source, restOfLine);
    return null;
  }

  void _parseLineIntoClass(
      LoadContext context, PCClass pcClass, SourceEntry source, String restOfLine) {
    if (restOfLine.isEmpty) return;
    final tokens = restOfLine.split('\t');
    for (final token in tokens) {
      final tok = token.trim();
      if (tok.isEmpty) continue;
      _parseToken(pcClass, tok);
    }
  }

  void _parseToken(PCClass pcClass, String token) {
    final (tag, value) = LstUtils.splitToken(token);
    if (value.isEmpty) return;
    switch (tag.toUpperCase()) {
      case 'HD':
        // HD:10 — hit die size (d10 for Fighter, d4 for Wizard, etc.)
        pcClass.putString(StringKey.hdFormula, value);
        break;
      case 'TYPE':
        for (final t in value.split('.')) {
          if (t.isNotEmpty) {
            try { pcClass.addToListFor(ListKey.getConstant<String>('TYPE'), t); } catch (_) {}
          }
        }
        break;
      case 'DESC':
        pcClass.putString(StringKey.description, value);
        break;
      case 'SOURCELONG':
        pcClass.putString(StringKey.sourceLong, value);
        break;
      case 'SOURCESHORT':
        pcClass.putString(StringKey.sourceShort, value);
        break;
      case 'SOURCEWEB':
        pcClass.putString(StringKey.sourceWeb, value);
        break;
      case 'STARTSKILLPTS':
        try { pcClass.putObject(ObjectKey.getConstant<int>('START_SKILL_PTS'), int.tryParse(value) ?? 2); } catch (_) {}
        break;
      case 'CSKILL':
        // Class skills: CSKILL:Acrobatics|Climb|TYPE=Knowledge|...
        // Store each skill name individually; TYPE=xxx entries are kept raw
        // for later matching by skill type.
        for (final s in value.split('|')) {
          final skill = s.trim();
          if (skill.isNotEmpty) {
            try {
              pcClass.addToListFor(
                ListKey.getConstant<String>('CLASS_SKILLS'), skill);
            } catch (_) {}
          }
        }
        // Also store raw for backward compat
        try { pcClass.putString(StringKey.listtype, value); } catch (_) {}
        break;
      case 'OUTPUTNAME':
        pcClass.putString(StringKey.outputName, value);
        break;
      case 'SORTKEY':
        pcClass.putString(StringKey.sortKey, value);
        break;
      case 'FACT':
        // FACT:FieldName|Value — e.g. FACT:ClassType|PC, FACT:Abb|Ftr
        final pipeIdx = value.indexOf('|');
        if (pipeIdx > 0) {
          final factName = value.substring(0, pipeIdx);
          final factVal  = value.substring(pipeIdx + 1);
          switch (factName.toUpperCase()) {
            case 'CLASSTYPE':
              pcClass.putString(StringKey.classType, factVal);
              break;
            case 'ABB':
              pcClass.putString(StringKey.abbKr, factVal);
              break;
            default:
              break;
          }
        }
        break;
      case 'ROLE':
        // ROLE:Combat|Divine etc — store as description if not set
        if (pcClass.getString(StringKey.description) == null) {
          pcClass.putString(StringKey.description, 'Role: $value');
        }
        break;
      case 'BONUS':
        // Store as ParsedBonus for the rules engine.
        final parsed = ParsedBonus.parse(value);
        if (parsed != null) {
          try {
            pcClass.addToListFor(
              ListKey.getConstant<ParsedBonus>('PARSED_BONUS'), parsed);
          } catch (_) {}
        }
        // Legacy BAB / save detection for backward compatibility.
        final parts = value.split('|');
        if (parts.length >= 3) {
          final bonusType = parts[0].toUpperCase();
          if (bonusType == 'COMBAT' && parts[1].toUpperCase() == 'BASEAB') {
            final formula = parts[2].toLowerCase();
            String babType;
            if (!formula.contains('*') && !formula.contains('/') &&
                !formula.contains('.') && formula.contains('cl')) {
              babType = 'Full';
            } else if (formula.contains('3/4') || formula.contains('.75')) {
              babType = 'ThreeQuarters';
            } else if (formula.contains('/2') || formula.contains('.5')) {
              babType = 'Half';
            } else {
              babType = 'ThreeQuarters';
            }
            if (pcClass.getString(StringKey.masterBabFormula) == null) {
              pcClass.putString(StringKey.masterBabFormula, babType);
            }
          } else if (bonusType == 'CHECKS' || bonusType == 'SAVE') {
            final saveName = parts[1].toUpperCase();
            final formula  = parts[2].toLowerCase();
            String saveKey = '';
            if (saveName.contains('FORT')) saveKey = 'Fortitude';
            else if (saveName.contains('REF'))  saveKey = 'Reflex';
            else if (saveName.contains('WILL') || saveName.contains('WIL')) saveKey = 'Will';
            if (saveKey.isNotEmpty) {
              final isGood = formula.contains('/2') || formula.contains('*.5') ||
                  formula.contains('*0.5') || formula.contains('+2');
              final type = isGood ? 'Good' : 'Poor';
              final existing = pcClass.getString(StringKey.masterCheckFormula) ?? '';
              if (!existing.contains(saveKey)) {
                pcClass.putString(StringKey.masterCheckFormula,
                    existing.isEmpty ? '$saveKey:$type' : '$existing,$saveKey:$type');
              }
            }
          }
        }
        break;
      case 'SPELLSTAT':
        // SPELLSTAT:WIS — spellcasting ability for this class
        try { pcClass.putString(StringKey.spellStat, value); } catch (_) {}
        break;
      case 'MEMORIZE':
        // MEMORIZE:YES/NO — prepared vs spontaneous caster
        try {
          pcClass.putObject(ObjectKey.getConstant<bool>('MEMORIZE'),
              value.toUpperCase() == 'YES');
        } catch (_) {}
        break;
      case 'SPELLBOOK':
        try {
          pcClass.putObject(ObjectKey.getConstant<bool>('SPELLBOOK'),
              value.toUpperCase() == 'YES');
        } catch (_) {}
        break;
      case 'LANGBONUS':
        // LANGBONUS:Abyssal,Celestial,Infernal — bonus language choices
        for (final lang in value.split(',')) {
          final l = lang.trim();
          if (l.isNotEmpty) {
            try {
              pcClass.addToListFor(
                ListKey.getConstant<String>('LANG_BONUS'), l);
            } catch (_) {}
          }
        }
        break;
      case 'CAST':
        // Per-level spell slots: stored on CLASSABILITIESLEVEL objects
        // At this point we're processing a level line, handled by parseLine
        break;
      case 'KNOWN':
        break;
      case 'KNOWNSPELLS':
        // KNOWNSPELLS:LEVEL=0|LEVEL=1|... — all spells of these levels are known
        try { pcClass.putString(StringKey.knownSpellFormula, value); } catch (_) {}
        break;
      case 'VISIBLE':
        break;
      case 'MAXLEVEL':
        try {
          pcClass.putObject(ObjectKey.getConstant<int>('MAX_LEVEL'),
              int.tryParse(value) ?? 20);
        } catch (_) {}
        break;
      case 'EXCLASS':
        // Ex-class name — ignore for now
        break;
      case 'CASTERLEVEL':
      case 'BONUS:CASTERLEVEL':
        break;
      case 'INTMOD':
        break;
      case 'DEFINE':
        // DEFINE:VarName|initialValue — initialise a variable
        // Store for later use in formula evaluation
        final pipeIdx = value.indexOf('|');
        if (pipeIdx > 0) {
          // Store defined variables as VAR_DEFINES list entries
          try {
            pcClass.addToListFor(
              ListKey.getConstant<String>('VAR_DEFINES'),
              '${value.substring(0, pipeIdx)}=${value.substring(pipeIdx + 1)}');
          } catch (_) {}
        }
        break;
      default:
        break;
    }
  }

  @override
  PCClass? getObjectKeyed(LoadContext context, String key) {
    return context.getReferenceContext()
        .getAllConstructed<PCClass>(PCClass)
        .cast<PCClass?>()
        .firstWhere((c) => c?.getKeyName() == key, orElse: () => null);
  }
}
