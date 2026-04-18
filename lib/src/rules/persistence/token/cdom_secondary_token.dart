import '../../../rules/context/load_context.dart';
import 'cdom_token.dart';
import 'cdom_sub_token.dart';

/// A CDOMSecondaryToken is both a CDOMToken and a CDOMSubToken, and can unparse.
abstract interface class CDOMSecondaryToken<T>
    implements CDOMToken<T>, CDOMSubToken<T> {
  List<String>? unparse(LoadContext context, T obj);
}
