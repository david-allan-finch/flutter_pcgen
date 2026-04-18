import 'choice_actor.dart';

// Associates a ChoiceActor with a choice operation.
abstract interface class BasicChoice<T> {
  void setChoiceActor(ChoiceActor<T> actor);
  ChoiceActor<T>? getChoiceActor();
}
