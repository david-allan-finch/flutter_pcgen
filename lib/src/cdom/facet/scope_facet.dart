// Copyright (c) Thomas Parker, 2015.
//
// Translation of pcgen.cdom.facet.ScopeFacet

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_item_facet.dart';

/// Stores the ScopeInstanceFactory for each Player Character, providing
/// ScopeInstance lookups for the formula solver system.
class ScopeFacet extends AbstractItemFacet<CharID, dynamic> {
  /// Returns the global ScopeInstance for this character.
  dynamic getGlobalScope(CharID id) {
    return get(id)?.getGlobalInstance('PC');
  }

  /// Returns the ScopeInstance for [vs] on the given character.
  dynamic get(CharID id, [dynamic vs]) {
    if (vs == null) return super.get(id);
    final factory = super.get(id);
    if (factory == null) return null;
    var localName = vs.getLocalScopeName();
    dynamic active = vs;
    while (localName == null) {
      final parent = active.getVariableParent();
      if (parent == null) {
        return factory.getGlobalInstance('PC');
      }
      active = parent;
      localName = active.getLocalScopeName();
    }
    return factory.get(localName, active);
  }
}
