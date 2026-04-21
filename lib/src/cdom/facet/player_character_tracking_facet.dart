// Copyright (c) Thomas Parker, 2009.
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.

// Translation of pcgen.cdom.facet.PlayerCharacterTrackingFacet

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'base/abstract_storage_facet.dart';

/// This is a transition class, designed to allow things to be taken out of
/// PlayerCharacter while a transition is made to the new facet system.
class PlayerCharacterTrackingFacet extends AbstractStorageFacet<CharID> {
  /// Associates the given [pc] (PlayerCharacter, typed dynamic) with [id].
  void associatePlayerCharacter(CharID id, dynamic pc) {
    setCache(id, pc);
  }

  /// Returns the PlayerCharacter associated with [id], or null if none.
  dynamic getPC(CharID id) {
    return getCache(id);
  }

  @override
  void copyContents(CharID source, CharID copy) {
    // We explicitly ignore this, since the CharID identifies the PlayerCharacter.
  }
}
