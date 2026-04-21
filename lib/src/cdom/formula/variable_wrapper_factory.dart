// Copyright (c) Tom Parker, 2016.
//
// Translation of pcgen.cdom.formula.VariableWrapperFactory

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/formula/variable_wrapper.dart';

/// Factory interface for creating VariableWrapper objects.
abstract interface class VariableWrapperFactory {
  VariableWrapper getGlobalWrapper(CharID id, String name);
  VariableWrapper getWrapper(CharID id, dynamic owner, String name);
  void disconnect(VariableWrapper variableWrapper);
}
