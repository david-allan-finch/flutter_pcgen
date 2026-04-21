// Copyright 2006 Devon Jones <soulcatcher@evilsoft.org>
//
// Translation of pcgen.persistence.lst.EquipSlotLstToken

import 'package:flutter_pcgen/src/persistence/lst/lst_token.dart';

/// Interface for tokens handled by the equipment-slot LST loader.
abstract interface class EquipSlotLstToken implements LstToken {
  /// Parses [value] into [eqSlot] for the named [gameMode].
  bool parse(dynamic eqSlot, String value, String gameMode);
}
