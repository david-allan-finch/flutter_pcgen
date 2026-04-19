// Translation of pcgen.rules.persistence.token.AbstractNonEmptyToken

import '../../../rules/context/load_context.dart';
import 'abstract_token.dart';
import 'cdom_token.dart';
import 'parse_result.dart';

/// Abstract base for tokens that reject empty values.
///
/// Implements [CDOMToken.parseToken] to first check for null/empty values,
/// then delegates to [parseNonEmptyToken] which subclasses must implement.
abstract class AbstractNonEmptyToken<T> extends AbstractToken
    implements CDOMToken<T> {
  @override
  ParseResult parseToken(LoadContext context, T obj, String value) {
    if (value.isEmpty) {
      return ParseResultFail(
          '${getTokenName()} received an empty value, this is not allowed');
    }
    return parseNonEmptyToken(context, obj, value);
  }

  /// Called by [parseToken] after verifying [value] is not empty.
  ParseResult parseNonEmptyToken(LoadContext context, T obj, String value);
}
