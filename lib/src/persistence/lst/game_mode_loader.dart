// Translation of pcgen.persistence.lst.GameModeLoader

import '../../core/game_mode.dart';

/// Utility class (no instances) that parses individual lines from game mode
/// configuration files (miscinfo.lst, statsandchecks.lst, etc.).
final class GameModeLoader {
  GameModeLoader._();

  // ---------------------------------------------------------------------------
  // miscinfo.lst line parsing
  // ---------------------------------------------------------------------------

  /// Parses one line from a miscinfo.lst file and applies it to [gameMode].
  ///
  /// Lines are in "KEY:value" (tab-delimited token) format.
  static void parseMiscGameInfoLine(
      GameMode gameMode, String aLine, Uri source, int lineNum) {
    if (aLine.isEmpty || aLine.startsWith('#')) return;

    final colonIdx = aLine.indexOf(':');
    if (colonIdx < 0) return;

    final key = aLine.substring(0, colonIdx).trim();
    final value = aLine.substring(colonIdx + 1).trim();
    if (value.isEmpty) return;

    _applyMiscToken(gameMode, key, value);
  }

  static void _applyMiscToken(GameMode gm, String key, String value) {
    switch (key) {
      case 'ACFORMULA':
        gm.setACFormula(value);
      case 'ALLOWEDMODES':
        for (final m in value.split('|')) {
          if (m.trim().isNotEmpty) gm.addAllowedMode(m.trim());
        }
      case 'ALTHPABBREV':
        gm.setALTHPAbbrev(value);
      case 'ALTHPNAME':
        gm.setALTHPName(value);
      case 'BABMAXATT':
        gm.setBabMaxAtt(int.tryParse(value) ?? gm.getBabMaxAtt());
      case 'BABMINVAL':
        gm.setBabMinVal(int.tryParse(value) ?? gm.getBabMinVal());
      case 'BABATTCYC':
        gm.setBabAttCyc(int.tryParse(value) ?? gm.getBabAttCyc());
      case 'BONUSFEATLEVEL':
        gm.setBonusFeatLevels(value);
      case 'BONUSSTATLEVEL':
        gm.setBonusStatLevels(value);
      case 'CRTHRESHOLD':
        gm.setCRThreshold(value);
      case 'CURRENCYUNIT':
        gm.setCurrencyUnit(value);
      case 'CURRENCYUNITABBREV':
        gm.setCurrencyUnitAbbrev(value);
      case 'DAMAGERES':
        gm.setDamageResistanceText(value);
      case 'DEFAULTSPELLBOOK':
        gm.setDefaultSpellBook(value);
      case 'DEFAULTUNITSET':
        gm.setDefaultUnitSet(value);
      case 'DEITY':
        gm.setDeityTerm(value);
      case 'DISPLAYNAME':
        gm.setDisplayName(value);
      case 'DISPLAYORDER':
        gm.setDisplayOrder(int.tryParse(value) ?? gm.getDisplayOrder());
      case 'DIESIZES':
        final sizes = value.split('|')
            .map((s) => int.tryParse(s.trim()))
            .whereType<int>()
            .toList();
        if (sizes.isNotEmpty) gm.setDieSizes(sizes);
      case 'HPABBREV':
        gm.setHPAbbrev(value);
      case 'HPNAME':
        gm.setHPName(value);
      case 'LEVELMSG':
        gm.setLevelUpMessage(value);
      case 'MENUENTRY':
        gm.setMenuEntry(value);
      case 'MOVEFORMULA':
        gm.setMoveFormula(value);
      case 'RANKMODFORMULA':
        gm.setRankModFormula(value);
      case 'ROLLHP':
        gm.setRollHP(int.tryParse(value) ?? gm.getRollHP());
      case 'ROLLMETHOD':
        gm.setRollMethod(int.tryParse(value) ?? gm.getRollMethod());
      case 'ROLLFORMULA':
        gm.setRollFormula(value);
      case 'SHORTRANGEDISTANCE':
        gm.setShortRangeDistance(int.tryParse(value) ?? gm.getShortRangeDistance());
      case 'SKILLMULT':
        gm.addSkillMultiplierLevel(value);
      case 'SPELLBASECONCENTRATION':
        gm.setSpellBaseConcentration(value);
      case 'SPELLBASEDC':
        gm.setSpellBaseDC(value);
      case 'SPELLRANGE':
        // format: NAME|FORMULA
        final pipe = value.indexOf('|');
        if (pipe > 0) {
          gm.addSpellRange(value.substring(0, pipe), value.substring(pipe + 1));
        }
      case 'STATMAX':
        gm.setStatMax(int.tryParse(value) ?? gm.getStatMax());
      case 'STATMIN':
        gm.setStatMin(int.tryParse(value) ?? gm.getStatMin());
      case 'TABNAME':
        gm.setTabName(value);
      case 'WEAPONREACHFORMULA':
        gm.setWeaponReachFormula(value);
      case 'XPENABLED':
        gm.setXPEnabled(value.toLowerCase() != 'no');
      default:
        // Unknown token — ignored; full implementation uses GameModeLstToken registry
        break;
    }
  }
}
