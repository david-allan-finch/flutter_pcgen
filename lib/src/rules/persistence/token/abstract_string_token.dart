// Translation of pcgen.rules.persistence.token.AbstractStringToken

import '../../../cdom/base/cdom_object.dart';
import '../../../cdom/enumeration/string_key.dart';
import '../../../rules/context/load_context.dart';
import 'abstract_non_empty_token.dart';
import 'cdom_write_token.dart';
import 'parse_result.dart';

/// Abstract base for tokens that store a single String value on a CDOMObject.
///
/// Subclasses implement [getTokenName] and [stringKey] to indicate which
/// StringKey holds the value.
abstract class AbstractStringToken<T extends CDOMObject>
    extends AbstractNonEmptyToken<T> implements CDOMWriteToken<T> {
  /// The StringKey used to store the parsed string.
  StringKey get stringKey;

  @override
  ParseResult parseNonEmptyToken(LoadContext context, T obj, String value) {
    obj.put(stringKey, value);
    return ParseResult.success;
  }

  @override
  List<String>? unparse(LoadContext context, T obj) {
    final val = obj.get(stringKey) as String?;
    if (val == null || val.isEmpty) return null;
    return ['${getTokenName()}:$val'];
  }
}
