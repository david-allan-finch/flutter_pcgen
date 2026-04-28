// Simple text-format character sheet export.
// Produces a readable plaintext summary suitable for printing or pasting.

import 'package:flutter_pcgen/src/gui2/facade/character_facade_impl.dart';

class CharacterTextExport {
  static String export(CharacterFacadeImpl character) {
    final buf = StringBuffer();
    final data = character.toJson();

    _line(buf, '=' * 60);
    _line(buf, 'CHARACTER SHEET');
    _line(buf, '=' * 60);
    _line(buf, '');

    // Identity
    _line(buf, 'Name:      ${character.getName()}');
    _line(buf, 'Player:    ${character.getPlayersName()}');
    final raceRef = character.getRaceRef();
    final race = raceRef.get();
    _line(buf, 'Race:      ${(race as dynamic)?.getDisplayName() ?? "(none)"}');
    _line(buf, 'Alignment: ${character.getAlignmentKey()}');
    _line(buf, 'Deity:     ${character.getDeityKey()}');
    _line(buf, 'Classes:   ${character.getClassLevelSummary()}');
    _line(buf, 'Total Level: ${character.getTotalCharacterLevel()}');
    _line(buf, 'XP:        ${character.getXP()}');
    _line(buf, 'HP:        ${character.getHP()} / ${character.getMaxHP()}');
    _line(buf, '');

    // Ability scores
    _line(buf, '-' * 30);
    _line(buf, 'ABILITY SCORES');
    _line(buf, '-' * 30);
    final statScores = data['statScores'] as Map? ?? {};
    const statOrder = ['STR', 'DEX', 'CON', 'INT', 'WIS', 'CHA'];
    for (final key in statOrder) {
      final score = (statScores[key] as num?)?.toInt() ?? 10;
      final mod = ((score - 10) / 2).floor();
      final modStr = mod >= 0 ? '+$mod' : '$mod';
      buf.writeln('  ${key.padRight(5)} $score ($modStr)');
    }
    _line(buf, '');

    // Saving throws
    _line(buf, '-' * 30);
    _line(buf, 'SAVING THROWS');
    _line(buf, '-' * 30);
    _line(buf, '  Fortitude: ${character.getFortSave()}');
    _line(buf, '  Reflex:    ${character.getRefSave()}');
    _line(buf, '  Will:      ${character.getWillSave()}');
    _line(buf, '');

    // Combat
    _line(buf, '-' * 30);
    _line(buf, 'COMBAT');
    _line(buf, '-' * 30);
    final dexScore = (statScores['DEX'] as num?)?.toInt() ?? 10;
    final dexMod = ((dexScore - 10) / 2).floor();
    final totalLevel = character.getTotalCharacterLevel();
    final bab = (totalLevel * 3 / 4).floor();
    _line(buf, '  AC:         ${10 + dexMod}');
    _line(buf, '  BAB:        +$bab (estimate)');
    _line(buf, '  Initiative: ${dexMod >= 0 ? "+$dexMod" : "$dexMod"}');
    _line(buf, '');

    // Skills
    final skillRanks = data['skillRanks'] as Map?;
    if (skillRanks != null && skillRanks.isNotEmpty) {
      _line(buf, '-' * 30);
      _line(buf, 'SKILLS (with ranks)');
      _line(buf, '-' * 30);
      final entries = skillRanks.entries
          .where((e) => (e.value as num? ?? 0) > 0)
          .toList()
        ..sort((a, b) => a.key.toString().compareTo(b.key.toString()));
      for (final e in entries) {
        buf.writeln('  ${e.key.toString().padRight(30)} ${e.value}');
      }
      _line(buf, '');
    }

    // Feats
    final selectedAbilities = data['selectedAbilities'] as Map?;
    if (selectedAbilities != null) {
      final feats = (selectedAbilities['FEAT'] as List?)?.cast<String>() ?? [];
      if (feats.isNotEmpty) {
        _line(buf, '-' * 30);
        _line(buf, 'FEATS');
        _line(buf, '-' * 30);
        for (final f in feats) {
          buf.writeln('  • $f');
        }
        _line(buf, '');
      }
    }

    // Domains
    final domains = character.getSelectedDomainKeys();
    if (domains.isNotEmpty) {
      _line(buf, 'DOMAINS: ${domains.join(", ")}');
      _line(buf, '');
    }

    // Templates
    final templates = character.getAppliedTemplateKeys();
    if (templates.isNotEmpty) {
      _line(buf, 'TEMPLATES: ${templates.join(", ")}');
      _line(buf, '');
    }

    // Gear
    final gear = (data['gear'] as List?)?.cast<Map>() ?? [];
    if (gear.isNotEmpty) {
      _line(buf, '-' * 30);
      _line(buf, 'GEAR');
      _line(buf, '-' * 30);
      for (final item in gear) {
        buf.writeln('  • ${item["name"]} ×${item["qty"] ?? 1}');
      }
      _line(buf, '');
    }

    // Biography
    final bio = character.getBiography();
    if (bio.isNotEmpty) {
      _line(buf, '-' * 30);
      _line(buf, 'BIOGRAPHY');
      _line(buf, '-' * 30);
      _line(buf, bio);
      _line(buf, '');
    }

    // Notes
    final notes = character.getNotes();
    if (notes.isNotEmpty) {
      _line(buf, '-' * 30);
      _line(buf, 'NOTES');
      _line(buf, '-' * 30);
      _line(buf, notes);
      _line(buf, '');
    }

    _line(buf, '=' * 60);
    return buf.toString();
  }

  static void _line(StringBuffer buf, String text) => buf.writeln(text);
}
