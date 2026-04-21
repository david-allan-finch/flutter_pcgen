// Copyright (c) Thomas Parker, 2018.
//
// Translation of pcgen.cdom.facet.GrantedVarFacet

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/formula/pcgen_scoped.dart';
import 'package:flutter_pcgen/src/cdom/formula/variable_utilities.dart';
import 'package:flutter_pcgen/src/cdom/helper/bridge_listener.dart';
import 'base/abstract_sourced_list_facet.dart';
import 'event/data_facet_change_event.dart';
import 'event/data_facet_change_listener.dart';
import 'model/var_scoped_facet.dart';
import 'variable_store_facet.dart';

/// Tracks items that are granted via variables (the new formula system).
///
/// Listens to [VarScopedFacet] for added/removed [PCGenScoped] objects,
/// inspects their granted variable array, resolves variable values from
/// [VariableStoreFacet], and adds/removes the resolved objects from this facet.
class GrantedVarFacet extends AbstractSourcedListFacet<CharID, PCGenScoped>
    implements DataFacetChangeListener<CharID, PCGenScoped> {
  late VarScopedFacet varScopedFacet;
  late VariableStoreFacet variableStoreFacet;

  void init() {
    varScopedFacet.addDataFacetChangeListener(this);
  }

  @override
  void dataAdded(DataFacetChangeEvent<CharID, PCGenScoped> dfce) {
    final cdo = dfce.getCDOMObject();
    final grantedVariables = cdo.getGrantedVariableArray();
    if (grantedVariables.isEmpty) return;

    final source = dfce.getSource();
    final id = dfce.getCharID();
    for (final variableName in grantedVariables) {
      final varID = VariableUtilities.getGlobalVariableID(id, variableName);
      _processAdd(id, varID, source);
    }
  }

  void _processAdd<T>(CharID id, varID, Object source) {
    final value = variableStoreFacet.getValue(id, varID);
    variableStoreFacet.get(id)!
        .addVariableListener(varID, BridgeListener(id, this, source));
    if (value is List) {
      for (final obj in value) {
        add(id, obj as PCGenScoped, source);
      }
    } else if (value != null) {
      add(id, value as PCGenScoped, source);
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, PCGenScoped> dfce) {
    final cdo = dfce.getCDOMObject();
    final grantedVariables = cdo.getGrantedVariableArray();
    final source = dfce.getSource();
    final id = dfce.getCharID();
    for (final variableName in grantedVariables) {
      final varID = VariableUtilities.getGlobalVariableID(id, variableName);
      _processRemove(id, varID, source);
    }
  }

  void _processRemove<T>(CharID id, varID, Object source) {
    variableStoreFacet.get(id)!
        .removeVariableListener(varID, BridgeListener(id, this, source));
    final value = variableStoreFacet.getValue(id, varID);
    if (value is List) {
      for (final obj in value) {
        remove(id, obj as PCGenScoped, source);
      }
    } else if (value != null) {
      remove(id, value as PCGenScoped, source);
    }
  }
}
