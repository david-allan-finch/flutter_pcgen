// Translation of pcgen.persistence.lst.LevelLoader

import '../../core/game_mode.dart';
import '../../core/level_info.dart';

/// Parses lines from a level.lst game mode file.
///
/// Level files define XP table entries (one line per character level) and
/// optional XP table names for systems with multiple XP tracks.
final class LevelLoader {
  LevelLoader._();

  /// Parses [inputLine] from a level.lst file and updates [gameMode].
  ///
  /// Returns the current XP table name (which may change when an XPTABLE
  /// header line is encountered).
  static String parseLine(
      GameMode gameMode, String inputLine, int lineNum, Uri source,
      [String xpTable = '']) {
    if (gameMode == null) return xpTable; // ignore

    // A tab-separated line starting with XPTABLE: begins a new XP table
    if (inputLine.startsWith('XPTABLE:')) {
      var value = inputLine.substring(8);
      final tabIdx = value.indexOf('\t');
      if (tabIdx >= 0) value = value.substring(0, tabIdx);
      value = value.trim();
      if (value.isEmpty) {
        // errorPrint: empty XPTABLE value
        return xpTable;
      }
      gameMode.addXPTableName(value);
      return value;
    }

    // Fallback default table name for backwards compatibility
    if (xpTable.isEmpty) {
      xpTable = 'Default';
      gameMode.addXPTableName(xpTable);
    }

    final levelInfo = LevelInfo();
    final cols = inputLine.split('\t');

    for (final col in cols) {
      final s = col.trim();
      final colonIdx = s.indexOf(':');
      if (colonIdx < 0) continue;

      final key = s.substring(0, colonIdx).trim();
      final value = s.substring(colonIdx + 1).trim();

      _applyLevelToken(levelInfo, key, value);
    }

    gameMode.addLevelInfo(xpTable, levelInfo);
    return xpTable;
  }

  static void _applyLevelToken(LevelInfo info, String key, String value) {
    switch (key) {
      case 'LEVEL':
        info.levelString = value;
      case 'MAXCLASSSKILLRANK':
        info.maxClassSkillString = value;
      case 'MAXCROSSSKILLRANK':
        info.maxCrossClassSkillString = value;
      case 'MINXP':
        info.minXPString = value;
      default:
        // Unknown LevelLstToken — ignored
        break;
    }
  }
}
