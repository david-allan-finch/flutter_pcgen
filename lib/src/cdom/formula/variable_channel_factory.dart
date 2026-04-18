// Copyright (c) Tom Parker, 2016.
//
// Translation of pcgen.cdom.formula.VariableChannelFactory

import '../../enumeration/char_id.dart';
import 'variable_channel.dart';

/// Factory interface for creating VariableChannel objects.
abstract interface class VariableChannelFactory {
  VariableChannel getGlobalChannel(CharID id, String name);
  VariableChannel getChannel(CharID id, dynamic owner, String name);
  void disconnect(VariableChannel variableChannel);
}
