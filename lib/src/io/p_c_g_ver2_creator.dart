// Translation of pcgen.io.PCGVer2Creator

import '../core/player_character.dart';
import 'io_constants.dart';

/// Serialises a [PlayerCharacter] to PCGen PCG v2 file format.
///
/// The output is a tab-delimited text file where each line represents one
/// aspect of the character (version, name, stats, class levels, feats, etc.).
/// Lines are of the form  KEY:value  or  KEY:value<TAB>SUBKEY:subvalue.
///
/// Translation of pcgen.io.PCGVer2Creator.
class PCGVer2Creator {
  final PlayerCharacter pc;

  PCGVer2Creator(this.pc);

  // ---------------------------------------------------------------------------
  // Top-level entry point
  // ---------------------------------------------------------------------------

  /// Returns the complete PCG v2 file content as a UTF-8 string.
  String createPCGString() {
    final buf = StringBuffer();

    _appendVersionLine(buf);
    _appendCampaignLines(buf);
    _appendCharacterBio(buf);
    _appendStats(buf);
    _appendAlignment(buf);
    _appendRace(buf);
    _appendDeity(buf);
    _appendClasses(buf);
    _appendFeats(buf);
    _appendSkills(buf);
    _appendEquipment(buf);
    _appendSpells(buf);
    _appendTemplates(buf);
    _appendLanguages(buf);
    _appendNotes(buf);
    _appendEquipmentSets(buf);
    _appendTempBonuses(buf);

    return buf.toString();
  }

  // ---------------------------------------------------------------------------
  // Section writers
  // ---------------------------------------------------------------------------

  void _appendVersionLine(StringBuffer buf) {
    // PCGen file format version.
    buf.writeln('${IOConstants.tagVersion}:6.0.1');
  }

  void _appendCampaignLines(StringBuffer buf) {
    // TODO: write CAMPAIGN: lines for each loaded source.
  }

  void _appendCharacterBio(StringBuffer buf) {
    buf.writeln('${IOConstants.tagName}:${pc.getName()}');
    // TODO: write PLAYERNAME, HEIGHT, WEIGHT, AGE, GENDER, HANDED, SKIN,
    //       EYECOLOR, HAIRCOLOR, HAIRSTYLE, REGION, BIRTHPLACE, PERSONALITYMATRIX,
    //       PHOBIAS, INTERESTS, PORTRAIT, SPEECHPATTERN, CATCHPHRASE, NOTES.
  }

  void _appendStats(StringBuffer buf) {
    // TODO: write STAT:<stat>:<score> lines for each PCStat.
  }

  void _appendAlignment(StringBuffer buf) {
    // TODO: write ALIGNMENT:<key> line.
  }

  void _appendRace(StringBuffer buf) {
    // TODO: write RACE:<name> line.
  }

  void _appendDeity(StringBuffer buf) {
    // TODO: write DEITY:<name> line.
  }

  void _appendClasses(StringBuffer buf) {
    // TODO: write CLASS:<name>:<level> lines and CLASSABILITIESLEVEL lines.
  }

  void _appendFeats(StringBuffer buf) {
    // TODO: write FEAT:<name>:<type>:<desc> lines.
  }

  void _appendSkills(StringBuffer buf) {
    // TODO: write SKILL:<name>:<rank> lines.
  }

  void _appendEquipment(StringBuffer buf) {
    // TODO: write EQUIPNAME: / QTY: / OUTPUTORDER: etc. lines.
  }

  void _appendSpells(StringBuffer buf) {
    // TODO: write SPELLNAME: lines for each prepared/known spell.
  }

  void _appendTemplates(StringBuffer buf) {
    // TODO: write TEMPLATE:<name> lines.
  }

  void _appendLanguages(StringBuffer buf) {
    // TODO: write LANGUAGEAUTO: and LANGUAGE: lines.
  }

  void _appendNotes(StringBuffer buf) {
    // TODO: write NOTES: lines.
  }

  void _appendEquipmentSets(StringBuffer buf) {
    // TODO: write EQUIPSET: lines.
  }

  void _appendTempBonuses(StringBuffer buf) {
    // TODO: write TEMPBONUS: lines.
  }
}
