// Translation of pcgen.rules.persistence.token.AbstractStringStoringToken

import '../../../cdom/base/cdom_object.dart';
import '../../../rules/context/load_context.dart';
import 'abstract_token.dart';
import 'cdom_token.dart';
import 'cdom_write_token.dart';
import 'parse_result.dart';

/// Abstract base for tokens that store a free-form string in a CDOMObject's
/// fact map (not the structured StringKey map).
///
/// Used for tokens like SOURCEPAGE, SOURCELONG, etc., that write to the
/// FactKey-based storage rather than the typed StringKey map.
abstract class AbstractStringStoringToken<T extends CDOMObject>
    extends AbstractToken implements CDOMToken<T>, CDOMWriteToken<T> {
  @override
  ParseResult parseToken(LoadContext context, T obj, String value) {
    if (value.isEmpty) {
      return ParseResultFail(
          '${getTokenName()} may not have an empty value');
    }
    storeString(obj, value);
    return ParseResult.success;
  }

  /// Stores [value] into [obj] using the token-specific storage mechanism.
  void storeString(T obj, String value);

  @override
  List<String>? unparse(LoadContext context, T obj) {
    final val = retrieveString(obj);
    if (val == null || val.isEmpty) return null;
    return ['${getTokenName()}:$val'];
  }

  /// Retrieves the previously stored string from [obj], or null if absent.
  String? retrieveString(T obj);
}
