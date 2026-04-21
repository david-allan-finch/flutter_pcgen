// Copyright (c) Tom Parker, 2016.
//
// Translation of pcgen.cdom.formula.VariableWrapperFactoryInst

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'variable_utilities.dart';
import 'variable_wrapper.dart';
import 'variable_wrapper_factory.dart';

/// Standard implementation of VariableWrapperFactory using facet lookups.
class VariableWrapperFactoryInst implements VariableWrapperFactory {
  final dynamic mgrFacet;
  final dynamic resultFacet;
  final Map<dynamic, VariableWrapper> _wrappers = {};

  VariableWrapperFactoryInst(this.mgrFacet, this.resultFacet);

  @override
  VariableWrapper getWrapper(CharID id, dynamic owner, String name) {
    final varID = VariableUtilities.getLocalVariableID(id, owner, name);
    return _getWrapper(id, varID);
  }

  @override
  VariableWrapper getGlobalWrapper(CharID id, String name) {
    final varID = VariableUtilities.getGlobalVariableID(id, name);
    return _getWrapper(id, varID);
  }

  @override
  void disconnect(VariableWrapper variableWrapper) {
    _wrappers.remove(variableWrapper.getVariableID());
    variableWrapper.disconnect();
  }

  VariableWrapper _getWrapper(CharID id, dynamic varID) {
    return _wrappers.putIfAbsent(varID, () {
      final varStore = resultFacet.get(id);
      final w = VariableWrapper.construct(mgrFacet.get(id), varStore, varID);
      varStore.addVariableListener(varID, w);
      return w;
    });
  }
}
