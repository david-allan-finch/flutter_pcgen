// Copyright 2010 Connor Petty <cpmeister@users.sourceforge.net>
//
// Translation of pcgen.persistence.GameModeFileLoader

import 'dart:io';

/// Loads game mode data files (stats, checks, sizes, levelling tables, etc.)
/// from the system/gameModes directory tree.
class GameModeFileLoader {
  String getMessage() => 'Loading game modes...';

  /// Scans the gameModes directory and loads each subdirectory as a GameMode.
  Future<void> run() async {
    // TODO: scan ConfigurationSettings.getSystemsDir()/gameModes for subdirectories,
    // load miscinfo.lst, statsandchecks.lst, sizeadjustment.lst, etc.
  }
}
