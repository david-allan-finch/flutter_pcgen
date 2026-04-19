// Translation of pcgen.io.PCGVer2Parser

import '../core/player_character.dart';
import 'io_constants.dart';
import 'p_c_g_parse_exception.dart';
import 'p_c_g_parser.dart';

/// Parses PCGen PCG version 2 character files.
///
/// Reads a list of text lines (one per attribute) and populates a
/// [PlayerCharacter] from the recognised KEY:value tokens.
///
/// Translation of pcgen.io.PCGVer2Parser.
class PCGVer2Parser extends PCGParser {
  PCGVer2Parser(PlayerCharacter pc) : super(pc);

  // ---------------------------------------------------------------------------
  // PCGParser implementation
  // ---------------------------------------------------------------------------

  @override
  void parsePCG(List<String> lines) {
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty || line.startsWith('#')) continue;
      try {
        _parseLine(line);
      } on PCGParseException catch (e) {
        print('WARN: Parse error at line ${i + 1}: $e');
      }
    }
    _finalise();
  }

  // ---------------------------------------------------------------------------
  // Line dispatcher
  // ---------------------------------------------------------------------------

  void _parseLine(String line) {
    final colonLoc = line.indexOf(':');
    if (colonLoc == -1) return; // no key:value separator — skip.

    final key = line.substring(0, colonLoc).toUpperCase();
    final value = colonLoc < line.length - 1 ? line.substring(colonLoc + 1) : '';

    switch (key) {
      case 'VERSION':
        _parseVersion(value);
      case 'CAMPAIGN':
        _parseCampaign(value);
      case 'NAME':
      case 'CHARACTERNAME':
        _parseCharacterName(value);
      case 'PLAYERNAME':
        _parsePlayerName(value);
      case 'RACE':
        _parseRace(value);
      case 'CLASS':
        _parseClass(value);
      case 'CLASSABILITIESLEVEL':
        _parseClassAbilitiesLevel(value);
      case 'STAT':
        _parseStat(value);
      case 'ALIGNMENT':
        _parseAlignment(value);
      case 'DEITY':
        _parseDeity(value);
      case 'SKILL':
        _parseSkill(value);
      case 'FEAT':
        _parseFeat(value);
      case 'VFEAT':
        _parseVirtualFeat(value);
      case 'ABILITY':
        _parseAbility(value);
      case 'TEMPLATE':
        _parseTemplate(value);
      case 'EQUIPNAME':
        _parseEquipment(line); // multi-field, pass whole line
      case 'EQUIPSET':
        _parseEquipSet(value);
      case 'LANGUAGE':
        _parseLanguage(value);
      case 'LANGUAGEAUTO':
        _parseAutoLanguage(value);
      case 'SPELLNAME':
        _parseSpell(value);
      case 'NOTES':
        _parseNote(value);
      case 'TEMPBONUS':
        _parseTempBonus(value);
      case 'HEIGHT':
        _parseHeight(value);
      case 'WEIGHT':
        _parseWeight(value);
      case 'AGE':
        _parseAge(value);
      case 'GENDER':
        _parseGender(value);
      case 'HANDED':
        _parseHanded(value);
      default:
        // Unknown token — silently ignore (mirrors Java behaviour for forward
        // compatibility).
        break;
    }
  }

  // ---------------------------------------------------------------------------
  // Individual token parsers
  // ---------------------------------------------------------------------------

  void _parseVersion(String value) {
    // Format: major.minor.patch
    // TODO: validate version and potentially run migration code.
  }

  void _parseCampaign(String value) {
    // TODO: record campaign source entry for post-load source validation.
  }

  void _parseCharacterName(String value) {
    pc.setName(value);
  }

  void _parsePlayerName(String value) {
    // TODO: pc.setPlayersName(value)
  }

  void _parseRace(String value) {
    // TODO: look up Race in the data context and apply to pc.
  }

  void _parseClass(String value) {
    // Format: ClassName=level  (tab-separated fields may follow)
    // TODO: parse class name and level, apply to pc via class-level machinery.
  }

  void _parseClassAbilitiesLevel(String value) {
    // TODO: parse per-level stat gains and ability applications.
  }

  void _parseStat(String value) {
    // Format: STAT:StatName:score
    // TODO: locate PCStat by name and set base score on pc.
  }

  void _parseAlignment(String value) {
    // TODO: look up PCAlignment and set on pc.
  }

  void _parseDeity(String value) {
    // TODO: look up Deity and set on pc.
  }

  void _parseSkill(String value) {
    // Format: SKILL:SkillName:OUTPUTORDER=n:RANK:nnn ...
    // TODO: locate Skill and set rank on pc.
  }

  void _parseFeat(String value) {
    // TODO: add feat/ability by name to pc.
  }

  void _parseVirtualFeat(String value) {
    // TODO: add virtual feat to pc.
  }

  void _parseAbility(String value) {
    // TODO: parse ABILITY lines (category, nature, name, associations).
  }

  void _parseTemplate(String value) {
    // TODO: look up PCTemplate and apply to pc.
  }

  void _parseEquipment(String line) {
    // Equipment lines span multiple KEY:value fields separated by tabs.
    // TODO: parse equipment tabs (EQUIPNAME, QTY, COST, WT, etc.) and add
    //       Equipment object to pc's equipment list.
  }

  void _parseEquipSet(String value) {
    // TODO: parse equipment set lines and reconstruct EquipSet objects.
  }

  void _parseLanguage(String value) {
    // TODO: add Language to pc.
  }

  void _parseAutoLanguage(String value) {
    // TODO: record auto-granted language on pc.
  }

  void _parseSpell(String value) {
    // TODO: add spell to appropriate spell book on pc.
  }

  void _parseNote(String value) {
    // TODO: add NoteItem to pc.
  }

  void _parseTempBonus(String value) {
    // TODO: reconstruct TempBonusInfo and apply to pc.
  }

  void _parseHeight(String value) {
    // TODO: parse height value and unit, set on pc.
  }

  void _parseWeight(String value) {
    // TODO: parse weight value and unit, set on pc.
  }

  void _parseAge(String value) {
    // TODO: set age on pc.
  }

  void _parseGender(String value) {
    // TODO: look up Gender and set on pc.
  }

  void _parseHanded(String value) {
    // TODO: look up Handed and set on pc.
  }

  // ---------------------------------------------------------------------------
  // Post-parse finalisation
  // ---------------------------------------------------------------------------

  void _finalise() {
    // TODO: resolve deferred references, apply post-load calculations,
    //       trigger APPLIEDTEMPLATE processing, etc.
  }
}
