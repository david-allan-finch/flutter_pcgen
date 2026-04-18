import 'cdom_object.dart';

// Applies choices of type T to a PlayerCharacter.
abstract interface class ChoiceActor<T> {
  void applyChoice(CDOMObject owner, T item, dynamic pc);
  bool allow(T item, dynamic pc, bool allowStack);
  List<T> getCurrentlySelected(CDOMObject owner, dynamic pc);
}
