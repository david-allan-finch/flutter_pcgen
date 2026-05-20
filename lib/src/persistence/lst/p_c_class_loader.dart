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
import 'package:flutter_pcgen/src/persistence/lst/generic_loader.dart';
import 'package:flutter_pcgen/src/rules/context/load_context.dart';
import 'package:flutter_pcgen/src/persistence/lst/source_entry.dart';
import 'package:flutter_pcgen/src/rules/parsed_bonus.dart';

/// Loads PCClass (and SubClass / SubstitutionClass) objects from LST files.
///
/// In Java, PCClassLoader extends LstObjectFileLoader<PCClass>. The first
/// column of each line is "ClassName" for a new class, "ClassName.SUBCLASS"
/// for a sub-class header, "ClassName  <level>" for a class level definition,
/// etc. This Dart version provides the outer parse loop and dispatches to
/// helpers for the complex class-level logic.
class PCClassLoader extends GenericLoader<PCClass> {
  PCClassLoader() : super(() => PCClass());

  // Tracks the class being built across multiple LST lines for the same class.
  // The loader calls parseLine sequentially; level lines (numbers) returned null
  // which lost track of the current class. We keep it here instead.
  PCClass? _currentClass;

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

    // Class level definition line: first field is a level number.
    // e.g.: "1\tCAST:0,1\tKNOWN:4,2\tABILITY:Class|AUTOMATIC|Barbarian"
    final levelNum = int.tryParse(firstToken);
    if (levelNum != null) {
      final cls = target ?? _currentClass;
      if (cls != null) {
        _parseLevelLine(cls, levelNum, fields.sublist(1));
      }
      return _currentClass; // keep current class as target for subsequent level lines
    }

    // New class (or .MOD of existing) — first field is class name.
    // The LST format uses "CLASS:Bard" as the first token; strip the prefix.
    final isMod = firstToken.toUpperCase().endsWith('.MOD');
    String className = isMod
        ? firstToken.substring(0, firstToken.length - 4)
        : firstToken;
    if (className.toUpperCase().startsWith('CLASS:')) {
      className = className.substring(6).trim();
    }

    // Find the already-registered class (handles CLASS:Bard continuation lines).
    // Never reuse the target object for a different class name — the loader
    // passes the previous parseLine return value as target, so without this
    // guard every class in a file would be merged into the first one.
    final existing = context.getReferenceContext().getConstructed<PCClass>(PCClass, className);
    PCClass pcClass;
    if (existing != null) {
      pcClass = existing;
    } else {
      // Only reuse target if it is the same class (or unnamed placeholder).
      final targetName = target?.getKeyName() ?? '';
      if (target != null && (targetName == className || targetName.isEmpty)) {
        pcClass = target;
        if (pcClass.getKeyName().isEmpty) {
          pcClass.setName(className);
          pcClass.setSourceURI(source.getURI().toString());
          context.getReferenceContext().register(pcClass);
        }
      } else {
        pcClass = PCClass();
        pcClass.setName(className);
        pcClass.setSourceURI(source.getURI().toString());
        context.getReferenceContext().register(pcClass);
      }
    }

    _currentClass = pcClass;
    _parseLineIntoClass(context, pcClass, source, restOfLine);
    return pcClass;
  }

  /// Parse a numbered class-level line (e.g. "1\tCAST:0,1\tKNOWN:4,2\tABILITY:...").
  void _parseLevelLine(PCClass pcClass, int level, List<String> fields) {
    for (final field in fields) {
      final tok = field.trim();
      if (tok.isEmpty) continue;
      final (tag, value) = LstUtils.splitToken(tok);
      switch (tag.toUpperCase()) {
        case 'CAST':
          // CAST:0,2,1 — slots per spell level (SL0, SL1, SL2…) at this class level
          final slots = value.split(',').map((s) => int.tryParse(s.trim()) ?? 0).toList();
          pcClass.setCastSlots(level, slots);
          break;
        case 'KNOWN':
          // KNOWN:4,2 — spells known per spell level at this class level
          final known = value.split(',').map((s) => int.tryParse(s.trim()) ?? 0).toList();
          pcClass.setKnownSlots(level, known);
          break;
        case 'ABILITY':
          // ABILITY:Category|AUTOMATIC|Name
          final parts = value.split('|');
          if (parts.length >= 3 && parts[1].trim().toUpperCase() == 'AUTOMATIC') {
            final name = parts[2].trim();
            if (name.isNotEmpty && !name.startsWith('!') && !name.startsWith('PRE')) {
              pcClass.addLevelAbility(level, name);
            }
          }
          break;
        case 'ADD': {
          final vUp = value.toUpperCase();
          if (vUp.startsWith('SPELLCASTER|') || vUp == 'SPELLCASTER') {
            final pipeIdx = value.indexOf('|');
            final type = pipeIdx >= 0 ? value.substring(pipeIdx + 1).trim() : 'ANY';
            pcClass.addSpellcasterAdvancement(level, type);
          } else if (vUp.startsWith('ABILITY|')) {
            // ADD:ABILITY|Category|Type|Name — grants an ability at this level
            // Store as a level ability so rebuildBonuses can pick it up
            final parts = value.split('|');
            if (parts.length >= 3) {
              final abilityType = parts[1].trim().toUpperCase();
              if (abilityType == 'FEAT') {
                // Virtual/automatic feat grants — store like ABILITY:FEAT|AUTOMATIC|Name
                final nameIdx = parts.indexWhere((p) => !p.toUpperCase().startsWith('TYPE=') && p.toUpperCase() != 'FEAT' && p.toUpperCase() != 'VIRTUAL' && p.toUpperCase() != 'AUTOMATIC');
                if (nameIdx >= 0) pcClass.addLevelAbility(level, parts[nameIdx].trim());
              } else {
                try { pcClass.addToListFor(ListKey.getConstant<String>('ADD_ABILITIES'), value); } catch (_) {}
              }
            }
          } else if (vUp.startsWith('CLASSSKILLS|') || vUp.startsWith('LANGUAGE|')) {
            // Skill point grants and language choices — no sheet impact
          } else {
            // ignore: avoid_print
            print('PCGen STUB: ClassLevel ADD: $value');
          }
          break;
        }
        case 'BONUS':
          final parsed = ParsedBonus.parse(value);
          if (parsed != null) {
            try { pcClass.addToListFor(ListKey.getConstant<ParsedBonus>('PARSED_BONUS'), parsed); } catch (_) {}
          }
          break;
        case 'DEFINE':
          final pipeIdx = value.indexOf('|');
          if (pipeIdx > 0) {
            try {
              pcClass.addToListFor(ListKey.getConstant<String>('VAR_DEFINES'),
                  '${value.substring(0, pipeIdx)}=${value.substring(pipeIdx + 1)}');
            } catch (_) {}
          }
          break;
        case 'AUTO': {
          // AUTO:ARMORPROF|... / AUTO:WEAPONPROF|... / AUTO:SHIELDPROF|... at level lines
          final pipeIdx = value.indexOf('|');
          final autoType = pipeIdx > 0 ? value.substring(0, pipeIdx).toUpperCase() : value.toUpperCase();
          final autoVal  = pipeIdx > 0 ? value.substring(pipeIdx + 1) : '';
          final listKeyName = switch (autoType) {
            'ARMORPROF'  => 'AUTO_ARMORPROF',
            'WEAPONPROF' => 'AUTO_WEAPONPROF',
            'SHIELDPROF' => 'AUTO_SHIELDPROF',
            'EQUIP'      => 'AUTO_EQUIP',
            'LANG'       => 'AUTO_LANG',
            _            => null,
          };
          if (listKeyName != null) {
            for (final item in autoVal.split('|')) {
              final i = item.trim();
              if (i.isNotEmpty && !i.startsWith('%')) {
                try { pcClass.addToListFor(ListKey.getConstant<String>(listKeyName), i); } catch (_) {}
              }
            }
          } else {
            // ignore: avoid_print
            print('PCGen STUB: ClassLevel AUTO type: $autoType');
          }
          break;
        }
        case 'DONOTADD':
          break; // monster classes that skip HD/skill points — no effect needed
        case 'SPELLLEVEL':
          // SPELLLEVEL:CLASS|ClassName=N|Spell1,Spell2|ClassName=M|...
          // Adds spells to a class's spell list at specific levels. Store raw
          // for future spell list consumption (CLASS.N.SPELLLEVEL tokens).
          try { pcClass.addToListFor(ListKey.getConstant<String>('SPELL_LEVEL_ADDS'), value); } catch (_) {}
          break;
        case 'SPELLKNOWN':
          // SPELLKNOWN:CLASS|ClassName=N|SpellName|...|PREDOMAIN:1,DomainName
          // Spontaneous domain spell knowledge for clerics/druids. Store raw.
          try { pcClass.addToListFor(ListKey.getConstant<String>('SPELL_KNOWN_ADDS'), value); } catch (_) {}
          break;
        case 'SPELLLIST':
          // SPELLLIST:N|ClassName|DOMAIN.X — composite spell list references.
          try { pcClass.addToListFor(ListKey.getConstant<String>('SPELL_LIST_REFS'), value); } catch (_) {}
          break;
        case 'SPECIALTYKNOWN':
          // SPECIALTYKNOWN:N,N,... — wizard specialty school extra spells known per level
          try { pcClass.putString(StringKey.knownSpellFormula, 'SPECIALTY:$value'); } catch (_) {}
          break;
        case 'DOMAIN':
          // DOMAIN:DomainName|PREABILITY:... — class grants this domain (paladin, etc.)
          try { pcClass.addToListFor(ListKey.getConstant<String>('DOMAIN_GRANTS'), value); } catch (_) {}
          break;
        case 'PREPCLEVEL':
          // PREPCLEVEL:MIN=N — class features at this level require minimum total level N.
          // Store as a level prerequisite so we can filter features for epic characters.
          try { pcClass.addToListFor(ListKey.getConstant<String>('LEVEL_PREREQS'), '$level:$value'); } catch (_) {}
          break;
        case 'VISION':
          // VISION:Blindsight (N') — class level grants special sight. Store for future display.
          try { pcClass.addToListFor(ListKey.getConstant<String>('LEVEL_VISION'), '$level:$value'); } catch (_) {}
          break;
        case 'TEMPLATE':
          // TEMPLATE:Name — class level applies a template to the character.
          try { pcClass.addToListFor(ListKey.getConstant<String>('LEVEL_TEMPLATES'), '$level:$value'); } catch (_) {}
          break;
        case 'UDAM':
          // UDAM:1d4,1d6,... — unarmed damage progression table by size category.
          try { pcClass.addToListFor(ListKey.getConstant<String>('UDAM_TABLE'), value); } catch (_) {}
          break;
        case 'PROHIBITSPELL':
          // PROHIBITSPELL:ALIGNMENT.X|PREALIGN:... — alignment-based spell prohibition.
          try { pcClass.addToListFor(ListKey.getConstant<String>('PROHIBIT_SPELLS'), value); } catch (_) {}
          break;
        case 'UMULT':
        case 'EXCHANGELEVEL':
        case 'PRECAMPAIGN':
          // Minor/epic gating tokens — store generically; no sheet impact for non-epic
          try { pcClass.addToListFor(ListKey.getConstant<String>('EXTRA_LEVEL_TOKENS'), '$tag:$value'); } catch (_) {}
          break;
        case 'ADDDOMAINS':
          // ADDDOMAINS=DomainName[PRETEMPLATE:1,TemplateName] — conditionally grant a domain at this level
          try { pcClass.addToListFor(ListKey.getConstant<String>('DOMAIN_GRANTS_CONDITIONAL'), '$level:$value'); } catch (_) {}
          break;
        default:
          // ignore: avoid_print
          print('PCGen STUB: ClassLevel token: $tag=$value');
          break;
      }
    }
  }

  void _parseLineIntoClass(
      LoadContext context, PCClass pcClass, SourceEntry source, String restOfLine) {
    if (restOfLine.isEmpty) return;
    final tokens = restOfLine.split('\t');
    for (final token in tokens) {
      final tok = token.trim();
      if (tok.isEmpty) continue;
      if (!_parseToken(context, pcClass, source, tok)) {
        // Delegate unhandled tokens to GenericLoader (BONUS, PRE, CHOOSE, AUTO, etc.)
        processToken(context, pcClass, source, tok);
      }
    }
  }

  /// Returns true if the token was handled by PCClassLoader, false to
  /// delegate to GenericLoader.processToken (PRE, CHOOSE, AUTO, etc.).
  bool _parseToken(LoadContext context, PCClass pcClass, SourceEntry source, String token) {
    final (tag, value) = LstUtils.splitToken(token);
    if (value.isEmpty) return true; // empty value — consume silently
    switch (tag.toUpperCase()) {
      case 'HD':
        pcClass.putString(StringKey.hdFormula, value);
        return true;
      case 'TYPE':
        for (final t in value.split('.')) {
          if (t.isNotEmpty) {
            try { pcClass.addToListFor(ListKey.getConstant<String>('TYPE'), t); } catch (_) {}
          }
        }
        return true;
      case 'DESC':
        pcClass.putString(StringKey.description, value);
        return true;
      case 'SOURCELONG':
        pcClass.putString(StringKey.sourceLong, value);
        return true;
      case 'SOURCESHORT':
        pcClass.putString(StringKey.sourceShort, value);
        return true;
      case 'SOURCEWEB':
        pcClass.putString(StringKey.sourceWeb, value);
        return true;
      case 'SOURCEPAGE':
        try { pcClass.putString(StringKey.sourcePage, value); } catch (_) {}
        return true;
      case 'STARTSKILLPTS':
        try { pcClass.putObject(CDOMObjectKey.getConstant<int>('START_SKILL_PTS'), int.tryParse(value) ?? 2); } catch (_) {}
        return true;
      case 'CSKILL':
        for (final s in value.split('|')) {
          final skill = s.trim();
          if (skill.isNotEmpty) {
            try { pcClass.addToListFor(ListKey.getConstant<String>('CLASS_SKILLS'), skill); } catch (_) {}
          }
        }
        try { pcClass.putString(StringKey.listtype, value); } catch (_) {}
        return true;
      case 'OUTPUTNAME':
        pcClass.putString(StringKey.outputName, value);
        return true;
      case 'SORTKEY':
        pcClass.putString(StringKey.sortKey, value);
        return true;
      case 'KEY':
        try { pcClass.setKeyName(value); } catch (_) {}
        return true;
      case 'FACT':
        final pipeIdx = value.indexOf('|');
        if (pipeIdx > 0) {
          final factName = value.substring(0, pipeIdx);
          final factVal  = value.substring(pipeIdx + 1);
          switch (factName.toUpperCase()) {
            case 'CLASSTYPE':
              pcClass.putString(StringKey.classType, factVal);
            case 'ABB':
              pcClass.putString(StringKey.abbKr, factVal);
            default:
              break;
          }
        }
        return true;
      case 'ROLE':
        if (pcClass.getString(StringKey.description) == null) {
          pcClass.putString(StringKey.description, 'Role: $value');
        }
        return true;
      case 'BONUS':
        final parsed = ParsedBonus.parse(value);
        if (parsed != null) {
          try { pcClass.addToListFor(ListKey.getConstant<ParsedBonus>('PARSED_BONUS'), parsed); } catch (_) {}
        }
        // Legacy BAB / save type detection.
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
        return true;
      case 'SPELLSTAT':
        try { pcClass.putString(StringKey.spellStat, value); } catch (_) {}
        return true;
      case 'MEMORIZE':
        try { pcClass.putObject(CDOMObjectKey.getConstant<bool>('MEMORIZE'), value.toUpperCase() == 'YES'); } catch (_) {}
        return true;
      case 'SPELLBOOK':
        try { pcClass.putObject(CDOMObjectKey.getConstant<bool>('SPELLBOOK'), value.toUpperCase() == 'YES'); } catch (_) {}
        return true;
      case 'LANGBONUS':
        for (final lang in value.split(',')) {
          final l = lang.trim();
          if (l.isNotEmpty) {
            try { pcClass.addToListFor(ListKey.getConstant<String>('LANG_BONUS'), l); } catch (_) {}
          }
        }
        return true;
      case 'CAST':
      case 'KNOWN':
        return true; // level-line tokens; handled by _parseLevelLine
      case 'KNOWNSPELLS':
        try { pcClass.putString(StringKey.knownSpellFormula, value); } catch (_) {}
        return true;
      case 'KNOWNSPELLSFROMSPECIALTY':
        return true; // wizard specialty — ignore
      case 'VISIBLE':
        try { pcClass.putObject(CDOMObjectKey.getConstant<String>('VISIBLE'), value.trim().toUpperCase()); } catch (_) {}
        return true;
      case 'MAXLEVEL':
        try { pcClass.putObject(CDOMObjectKey.getConstant<int>('MAX_LEVEL'), int.tryParse(value) ?? 20); } catch (_) {}
        return true;
      case 'ATTACKCYCLE':
        // ATTACKCYCLE:5|5|2 — non-standard attack progression (Monk).
        // Store as a pipe-joined string for the sheet to interpret.
        try { pcClass.putString(StringKey.attackCycle, value); } catch (_) {}
        return true;
      case 'BONUSSPELLSTAT':
        // Which stat governs bonus spell slots (default is primary spellcasting stat).
        try { pcClass.putString(StringKey.bonusSpellStat, value.toUpperCase()); } catch (_) {}
        return true;
      case 'MODTOSKILLS':
        // MODTOSKILLS:YES — monster classes apply stat mod to skill points.
        try { pcClass.putObject(CDOMObjectKey.getConstant<bool>('MOD_TO_SKILLS'),
            value.toUpperCase() == 'YES'); } catch (_) {}
        return true;
      case 'CASTERLEVEL':
        // CASTERLEVEL:ClassName — prestige class adds caster levels to another class.
        // Store as "CASTERLEVEL:ClassName" for use in getCasterLevel().
        try { pcClass.addToListFor(ListKey.getConstant<String>('CASTERLEVEL_GRANTS'), value); } catch (_) {}
        return true;
      case 'ADD':
        // ADD:SPELLCASTER|TYPE at the class header — marks this class as a spellcaster
        // of TYPE for prestige class qualification; store as class type annotation.
        if (value.toUpperCase().startsWith('SPELLCASTER')) {
          final pipeIdx = value.indexOf('|');
          final type = pipeIdx >= 0 ? value.substring(pipeIdx + 1).trim() : 'ANY';
          try { pcClass.addToListFor(ListKey.getConstant<String>('SPELLCASTER_TYPE'), type); } catch (_) {}
          return true;
        }
        return false; // other ADD types go to GenericLoader
      case 'EXCLASS':
      case 'INTMOD':
      case 'SUBCLASS':
      case 'SUBCLASSLEVEL':
      case 'SUBSTITUTIONLEVEL':
      case 'CHOICE':
      case 'ITEMCREATE':
      case 'UMULT':
      case 'UDAM':
      case 'PREALIGN': // handled via isPrereqToken but class-specific; fall to generic
        return false; // let GenericLoader handle PRE tokens including PREALIGN
      case 'DEFINE':
        final pipeIdx2 = value.indexOf('|');
        if (pipeIdx2 > 0) {
          try {
            pcClass.addToListFor(
              ListKey.getConstant<String>('VAR_DEFINES'),
              '${value.substring(0, pipeIdx2)}=${value.substring(pipeIdx2 + 1)}');
          } catch (_) {}
        }
        return true;
      case 'PROHIBITSPELL':
      case 'SPELLTYPE':
      case 'DR':
      case 'SR':
      case 'TEMPLATE':
      case 'WEAPONBONUS':
      case 'XTRASKILLPTSPERLVL':
        return false; // let GenericLoader handle these
      default:
        return false; // delegate to GenericLoader
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
