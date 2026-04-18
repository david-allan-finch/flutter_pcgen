// Copyright (c) Andrew Maitland, 2016.
//
// Translation of pcgen.core.chooser.UserInputManager

import 'cdom_choice_manager.dart';

/// A [CDOMChoiceManager] that prompts the user for free-text input rather
/// than selecting from a pre-defined list.
class UserInputManager extends CDOMChoiceManager<String> {
  UserInputManager(dynamic owner, dynamic chooseType, int cost)
      : super(owner, chooseType, null, cost);

  @override
  List<String> doChooser(dynamic pc, List<String> availableList,
      List<String> selectedList, List<String> reservedList) {
    // TODO: show a text-input chooser dialog
    return List<String>.from(selectedList);
  }
}
