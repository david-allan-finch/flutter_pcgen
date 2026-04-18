import 'cdom_token.dart';
import 'cdom_write_token.dart';

/// A CDOMPrimaryToken both parses and unparses an object.
/// Combines CDOMToken (parse) and CDOMWriteToken (unparse).
abstract interface class CDOMPrimaryToken<T>
    implements CDOMToken<T>, CDOMWriteToken<T> {}
