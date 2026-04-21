// Copyright PCGen authors.
//
// Translation of pcgen.rules.persistence.token.AbstractTokenWithSeparator

import 'package:flutter_pcgen/src/rules/context/load_context.dart';
import 'package:flutter_pcgen/src/rules/persistence/token/abstract_non_empty_token.dart';
import 'package:flutter_pcgen/src/rules/persistence/token/parse_result.dart';

/// Abstract base for tokens that expect a specific separator character in
/// their value string.
///
/// Performs initial validation (rejects empty values via [AbstractNonEmptyToken],
/// then checks that the separator is used correctly), then delegates to
/// [parseTokenWithSeparator] which concrete subclasses must implement.
///
/// [T] is the type of object on which this token operates.
///
/// Mirrors Java: AbstractTokenWithSeparator<T>
abstract class AbstractTokenWithSeparator<T> extends AbstractNonEmptyToken<T> {
  /// The separator character expected in values handled by this token.
  ///
  /// Subclasses return the appropriate character (e.g. '|', ',').
  String separator();

  @override
  ParseResult parseNonEmptyToken(LoadContext context, T obj, String value) {
    final ParseResult pr = checkForIllegalSeparator(separator(), value);
    if (pr.passed()) {
      return parseTokenWithSeparator(context, obj, value);
    }
    return pr;
  }

  /// Parses the (already separator-validated) [value] for [obj].
  ///
  /// Called only when [value] passes the separator check.
  ParseResult parseTokenWithSeparator(LoadContext context, T obj, String value);
}
