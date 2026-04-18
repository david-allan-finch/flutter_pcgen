import 'basic_choice.dart';
import 'persistent_choice_actor.dart';

// A BasicChoice that also supports encode/decode of choices for persistent storage.
abstract interface class PersistentChoice<T> implements BasicChoice<T> {
  @override
  PersistentChoiceActor<T>? getChoiceActor();
  T decodeChoice(dynamic context, String persistentFormat);
  String encodeChoice(T item);
}
