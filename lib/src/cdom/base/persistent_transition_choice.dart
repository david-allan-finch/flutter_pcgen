import 'cdom_object.dart';
import 'persistent_choice.dart';
import 'transition_choice.dart';

// A TransitionChoice that is saved/restored with a PlayerCharacter.
abstract interface class PersistentTransitionChoice<T>
    implements TransitionChoice<T>, PersistentChoice<T> {
  T castChoice(Object item);
  void remove(CDOMObject owner, dynamic pc);
  void restoreChoice(dynamic pc, CDOMObject owner, T item);
  Type getChoiceClass();
}
