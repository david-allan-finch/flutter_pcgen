// Copyright (c) Thomas Parker, 2014.
//
// Translation of pcgen.cdom.facet.ModifierFacet

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/formula/pcgen_scoped.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_event.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_listener.dart';
import 'package:flutter_pcgen/src/cdom/facet/model/var_scoped_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/scope_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/solver_manager_facet.dart';

/// Processes MODIFY: entries on CDOMObjects and applies them to the solver system.
class ModifierFacet implements DataFacetChangeListener<CharID, PCGenScoped> {
  late ScopeFacet scopeFacet;
  late VarScopedFacet varScopedFacet;
  late SolverManagerFacet solverManagerFacet;

  @override
  void dataAdded(DataFacetChangeEvent<CharID, PCGenScoped> dfce) {
    final id = dfce.getCharID();
    final obj = dfce.getCDOMObject();
    final modifiers = obj.getModifierArray();
    if (modifiers.isNotEmpty) {
      final inst = scopeFacet.get(id, obj);
      for (final vm in modifiers) {
        solverManagerFacet.addModifier(id, vm, obj, vm.getModifier(), inst);
      }
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, PCGenScoped> dfce) {
    final id = dfce.getCharID();
    final obj = dfce.getCDOMObject();
    final modifiers = obj.getModifierArray();
    if (modifiers.isNotEmpty) {
      final inst = scopeFacet.get(id, obj);
      for (final vm in modifiers) {
        solverManagerFacet.removeModifier(id, vm, obj, vm.getModifier(), inst);
      }
    }
  }

  void init() {
    varScopedFacet.addDataFacetChangeListener(this);
  }
}
