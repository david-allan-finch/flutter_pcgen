import '../../../rules/context/load_context.dart';
import 'cdom_token.dart';

/// A CDOMWriteToken can serialize an object of type [T] back to LST strings.
abstract interface class CDOMWriteToken<T> implements LstToken {
  List<String>? unparse(LoadContext context, T obj);
}
