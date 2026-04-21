// Copyright 2005 Greg Bingleman <byngl@hotmail.com>
//
// Translation of pcgen.persistence.lst.GameModeLstToken

import 'package:flutter_pcgen/src/persistence/lst/lst_token.dart';

/// Interface for tokens handled by the game-mode (miscinfo.lst) loader.
abstract interface class GameModeLstToken implements LstToken {
  /// Parses [value] into [gameMode] from the file at [source].
  bool parse(dynamic gameMode, String value, Uri source);
}
