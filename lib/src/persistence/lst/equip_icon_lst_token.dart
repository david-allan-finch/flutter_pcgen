// Copyright James Dempsey, 2011
//
// Translation of pcgen.persistence.lst.EquipIconLstToken

import 'package:flutter_pcgen/src/persistence/lst/lst_token.dart';

/// Interface for tokens handled by the equipment-icon LST loader.
abstract interface class EquipIconLstToken implements LstToken {
  /// Parses [value] into [gameMode] from the file at [source].
  bool parse(dynamic gameMode, String value, Uri source);
}
