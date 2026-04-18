import 'cdom_token.dart';
import 'cdom_write_token.dart';

/// A CDOMInterfaceToken operates on an interface of an object rather than
/// its direct class hierarchy.
///
/// [R] = the read interface; [W] = the write interface (token class).
abstract interface class CDOMInterfaceToken<R, W>
    implements CDOMToken<W>, CDOMWriteToken<R> {
  /// Returns the read interface Type for this token.
  Type getReadInterface();
}
