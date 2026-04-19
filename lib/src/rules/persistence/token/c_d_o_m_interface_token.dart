// Copyright PCGen authors.
//
// Translation of pcgen.rules.persistence.token.CDOMInterfaceToken

import 'cdom_token.dart';
import 'cdom_write_token.dart';

/// A token that operates on an *interface* of an object rather than its direct
/// class hierarchy.
///
/// Unlike [CDOMToken]-based tokens (which match exact class ancestry),
/// a [CDOMInterfaceToken] separates the read interface [R] from the write
/// interface [W].  The write interface [W] is returned by [getTokenClass],
/// while the read interface [R] is returned by [getReadInterface].
///
/// Note: objects processed by this token are also expected to implement
/// `Loadable` (not enforced at the Dart type level here).
///
/// [R] – the read interface used for unparsing.
/// [W] – the write interface used for parsing.
///
/// Mirrors Java: CDOMInterfaceToken<R, W> extends CDOMToken<W>, CDOMWriteToken<R>
abstract interface class CDOMInterfaceToken<R, W>
    implements CDOMToken<W>, CDOMWriteToken<R> {
  /// Returns the read interface [Type] for this token.
  ///
  /// The write interface is returned by [getTokenClass] (from [CDOMToken]).
  Type getReadInterface();
}
