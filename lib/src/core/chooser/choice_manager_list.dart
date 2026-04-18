// Copyright (c) Andrew Wilson, 2006.
//
// Translation of pcgen.core.chooser.ChoiceManagerList

import 'choose_controller.dart';

/// Manages the choices available, selected, and application logic for a
/// CHOOSE token on a CDOMObject.
abstract interface class ChoiceManagerList<T> {
  void getChoices(dynamic pc, List<T> availableList, List<T> selectedList);

  List<T> doChooser(dynamic pc, List<T> availableList, List<T> selectedList,
      List<String> reservedList);

  List<T> doChooserRemove(dynamic pc, List<T> availableList,
      List<T> selectedList, List<String> reservedList);

  bool applyChoices(dynamic pc, List<T> selected);

  int getNumEffectiveChoices(
      List<T> selectedList, List<String> reservedList, dynamic pc);

  bool conditionallyApply(dynamic pc, T item);

  void restoreChoice(dynamic pc, dynamic owner, String choice);

  void setController(ChooseController<T> cc);

  int getPreChooserChoices();

  int getChoicesPerUnitCost();

  void removeChoice(dynamic pc, dynamic owner, T selection);

  void applyChoice(dynamic pc, dynamic owner, T selection);

  T decodeChoice(String choice);

  String encodeChoice(T obj);
}
