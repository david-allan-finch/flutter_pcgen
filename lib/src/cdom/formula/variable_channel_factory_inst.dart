// Copyright (c) Tom Parker, 2016.
//
// Translation of pcgen.cdom.formula.VariableChannelFactoryInst

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'variable_channel.dart';
import 'variable_channel_factory.dart';
import 'variable_utilities.dart';

/// Standard implementation of VariableChannelFactory using facet lookups.
class VariableChannelFactoryInst implements VariableChannelFactory {
  final dynamic mgrFacet;
  final dynamic resultFacet;
  final Map<dynamic, VariableChannel> _channels = {};

  VariableChannelFactoryInst(this.mgrFacet, this.resultFacet);

  @override
  VariableChannel getChannel(CharID id, dynamic owner, String name) {
    final varName = _createVarName(name);
    final varID = VariableUtilities.getLocalVariableID(id, owner, varName);
    return _getChannel(id, varID);
  }

  @override
  VariableChannel getGlobalChannel(CharID id, String name) {
    final varName = _createVarName(name);
    final varID = VariableUtilities.getGlobalVariableID(id, varName);
    return _getChannel(id, varID);
  }

  @override
  void disconnect(VariableChannel variableChannel) {
    _channels.remove(variableChannel.getVariableID());
    variableChannel.disconnect();
  }

  VariableChannel _getChannel(CharID id, dynamic varID) {
    return _channels.putIfAbsent(varID, () {
      final varStore = resultFacet.get(id);
      return VariableChannel.construct(mgrFacet.get(id), varStore, varID);
    });
  }

  static String _createVarName(String name) => 'CHANNEL.$name';
}
