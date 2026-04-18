import 'basic_choice.dart';
import 'cdom_object.dart';
import 'selectable_set.dart';

// Holds a set of choices and the count allowed for the legacy CHOOSE system.
abstract interface class TransitionChoice<T> implements BasicChoice<T> {
  void allowStack(bool allowStack);
  bool allowsStacking();
  List<T> driveChoice(dynamic pc);
  void setStackLimit(int limit);
  int? getStackLimit();
  dynamic getCount(); // Formula
  void act(List<T> choices, CDOMObject owner, dynamic pc);
  void setRequired(bool required);
  SelectableSet<T> getChoices();
}
