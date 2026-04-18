import 'choice_actor.dart';
import 'cdom_object.dart';
import 'persistent.dart';

// A ChoiceActor that can also restore/remove choices after persistent load.
abstract interface class PersistentChoiceActor<T>
    implements ChoiceActor<T>, Persistent<T> {
  void restoreChoice(dynamic pc, CDOMObject owner, T item);
  void removeChoice(dynamic pc, CDOMObject owner, T item);
}
