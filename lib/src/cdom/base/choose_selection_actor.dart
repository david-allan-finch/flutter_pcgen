import 'choose_driver.dart';

// A ChooseSelectionActor applies and removes selections (from the CHOOSE token)
// to a PlayerCharacter.
abstract interface class ChooseSelectionActor<T> {
  void applyChoice(ChooseDriver obj, T item, dynamic pc);
  void removeChoice(ChooseDriver obj, T item, dynamic pc);
  String getSource();
  String getLstFormat();
  Type getChoiceClass();
}
