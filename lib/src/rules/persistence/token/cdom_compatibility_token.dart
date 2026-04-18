import 'cdom_token.dart';
import 'compatibility_token.dart';

/// A CDOMCompatibilityToken implements a tag syntax from a previous version
/// of PCGen.
abstract interface class CDOMCompatibilityToken<T>
    implements CDOMToken<T>, CompatibilityToken {}
