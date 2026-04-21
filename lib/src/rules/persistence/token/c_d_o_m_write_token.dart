// Copyright PCGen authors.
//
// Translation of pcgen.rules.persistence.token.CDOMWriteToken

import 'package:flutter_pcgen/src/persistence/lst/lst_token.dart';
import 'package:flutter_pcgen/src/rules/context/load_context.dart';

/// A token that can serialize an object back to LST string fragments.
abstract interface class CDOMWriteToken<T> implements LstToken {
  /// Return the LST string fragments representing [obj], or null/empty if
  /// this token has nothing to write for this object.
  List<String>? unparse(LoadContext context, T obj);
}
