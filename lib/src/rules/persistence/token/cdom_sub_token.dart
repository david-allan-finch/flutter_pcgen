import 'cdom_token.dart';

/// A CDOMSubToken is a token that lives beneath a parent token.
abstract interface class CDOMSubToken<T> implements CDOMToken<T> {
  String getParentToken();
}
