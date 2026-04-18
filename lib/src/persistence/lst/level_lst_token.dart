// Copyright 2006 Devon Jones <soulcatcher@evilsoft.org>
//
// Translation of pcgen.persistence.lst.LevelLstToken

import 'lst_token.dart';

/// Interface for tokens handled by the level.lst loader.
abstract interface class LevelLstToken implements LstToken {
  /// Parses [value] into [levelInfo]. Returns true on success.
  bool parse(dynamic levelInfo, String value);
}
