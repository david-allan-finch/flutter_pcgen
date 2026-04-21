// Copyright PCGen authors.
//
// Translation of pcgen.rules.persistence.token.CDOMSecondaryToken

import 'package:flutter_pcgen/src/rules/context/load_context.dart';
import 'c_d_o_m_sub_token.dart';
import 'c_d_o_m_token.dart';

/// A sub-token (nested under a parent token name) that can also unparse.
abstract interface class CDOMSecondaryToken<T>
    implements CDOMToken<T>, CDOMSubToken<T> {
  /// Return the LST string fragments for this sub-token, or null if nothing
  /// to write.
  List<String>? unparse(LoadContext context, T obj);
}
