// Copyright PCGen authors.
//
// Translation of pcgen.rules.persistence.token.CDOMToken

import 'package:flutter_pcgen/src/persistence/lst/lst_token.dart';
import 'package:flutter_pcgen/src/rules/context/load_context.dart';

/// A token that can parse a single line of LST data into a CDOMObject.
abstract interface class CDOMToken<T> implements LstToken {
  /// Returns the Type of object this token can process.
  Type getTokenClass();

  /// Parse the given [value] into [obj] using [context].
  dynamic parseToken(LoadContext context, T obj, String value);
}
