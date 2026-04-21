// Copyright 2013 James Dempsey <jdempsey@users.sourceforge.net>
//
// Translation of pcgen.persistence.lst.MigrationLstToken

import 'package:flutter_pcgen/src/core/system/migration_rule.dart';
import 'package:flutter_pcgen/src/persistence/lst/lst_token.dart';

/// Interface for tokens handled by the MigrationLoader.
abstract interface class MigrationLstToken implements LstToken {
  /// Parses [value] into [migrationRule] for the given [gameModeName].
  /// Returns true on success.
  bool parse(MigrationRule migrationRule, String value, String gameModeName);
}
