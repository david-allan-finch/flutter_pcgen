import 'choose_driver.dart';
import 'persistent.dart';

// A Chooser can restore and remove choices for a PlayerCharacter, and is
// saved with the character's persistent state.
abstract interface class Chooser<T> implements Persistent<T> {
  void restoreChoice(dynamic pc, ChooseDriver owner, T item);
  void removeChoice(dynamic pc, ChooseDriver owner, T item);
  void applyChoice(ChooseDriver owner, T item, dynamic pc);
  bool allow(T item, dynamic pc, bool allowStack);
  List<T> getCurrentlySelected(ChooseDriver owner, dynamic pc);
}
