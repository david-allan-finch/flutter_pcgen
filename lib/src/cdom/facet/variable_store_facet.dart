// Copyright (c) Thomas Parker, 2015.
//
// Translation of pcgen.cdom.facet.VariableStoreFacet

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/formula/monitorable_variable_store.dart';
import 'package:flutter_pcgen/src/formula/base/variable_id.dart';
import 'base/abstract_item_facet.dart';

/// Stores the [MonitorableVariableStore] (results of the new formula system
/// calculations) for each Player Character identified by a [CharID].
class VariableStoreFacet
    extends AbstractItemFacet<CharID, MonitorableVariableStore> {
  // TODO: wire LoadContextFacet for default value lookup when variable is absent.

  /// Returns the value of [varID] for the PC, or null if not yet calculated.
  T? getValue<T>(CharID id, VariableID<T> varID) {
    return get(id)?.get(varID);
  }

  @override
  void copyContents(CharID source, CharID copy) {
    final obj = get(source);
    if (obj != null) {
      final replacement = MonitorableVariableStore();
      replacement.importFrom(obj);
      setCache(copy, replacement);
    }
  }
}
