// Copyright (c) Thomas Parker, 2015.
//
// Translation of pcgen.cdom.facet.SolverManagerFacet

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_item_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/scope_facet.dart';

/// Stores the SolverManager for each Player Character (formula solver system).
class SolverManagerFacet extends AbstractItemFacet<CharID, dynamic> {
  late ScopeFacet scopeFacet;

  /// Adds a modifier to the solver and returns whether a solve was triggered.
  bool addModifier(CharID id, dynamic vm, dynamic thisValue, dynamic modifier,
      dynamic source) {
    final scope = scopeFacet.get(id, thisValue);
    // Variable ID resolution requires LoadContext — stub for now
    // TODO: wire through LoadContextFacet when available
    return get(id)?.addModifierAndSolve(null, modifier, source) ?? false;
  }

  /// Removes a modifier from the solver.
  void removeModifier(CharID id, dynamic vm, dynamic thisValue, dynamic modifier,
      dynamic source) {
    final scope = scopeFacet.get(id, thisValue);
    // TODO: wire through LoadContextFacet when available
    get(id)?.removeModifier(null, modifier, source);
  }
}
