// Copyright PCGen authors.
//
// Translation of pcgen.rules.persistence.token.CDOMSubToken

import 'package:flutter_pcgen/src/rules/persistence/token/c_d_o_m_token.dart';

/// A secondary token that is nested under a parent token name.
abstract interface class CDOMSubToken<T> implements CDOMToken<T> {
  /// Returns the name of the parent token under which this sub-token lives.
  String getParentToken();
}
