// Copyright (c) Tom Parker, 2014.
//
// Translation of pcgen.core.display.BonusDisplay

/// Utilities for building user-facing display strings for bonus entries.
class BonusDisplay {
  BonusDisplay._();

  /// Returns a display name for a TempBonusInfo (source + target).
  static String getBonusDisplayNameFromInfo(dynamic ti) {
    return getBonusDisplayName(ti.source, ti.target);
  }

  /// Returns a display name for a bonus based on its [sourceObj] and [targetObj].
  ///
  /// The target is shown as "PC" for a PlayerCharacter, the equipment name for
  /// Equipment, or "NONE" for anything else.
  static String getBonusDisplayName(Object sourceObj, Object targetObj) {
    final buf = StringBuffer()..write(sourceObj)..write(' [');

    final typeName = targetObj.runtimeType.toString();
    if (typeName.contains('PlayerCharacter')) {
      buf.write('PC');
    } else if (typeName.contains('Equipment')) {
      buf.write((targetObj as dynamic).getName());
    } else {
      buf.write('NONE');
    }

    buf.write(']');
    return buf.toString();
  }
}
