// Copyright (c) Andrew Maitland, 2016.
//
// Translation of pcgen.core.chooser.NoChoiceManager

import 'package:flutter_pcgen/src/core/chooser/choice_manager_list.dart';
import 'package:flutter_pcgen/src/core/chooser/choose_controller.dart';

/// A [ChoiceManagerList] for CHOOSE tokens that take no user selection —
/// they simply add or remove a fixed empty-string slot.
class NoChoiceManager implements ChoiceManagerList<String> {
  final dynamic owner;
  final dynamic info; // ChooseInformation<String>
  @override
  final int choicesPerUnitCost;
  ChooseController<String> controller = ChooseController<String>();

  int _preChooserChoices = 0;

  NoChoiceManager(this.owner, this.info, this.choicesPerUnitCost);

  @override
  void getChoices(dynamic pc, List<String> availableList,
      List<String> selectedList) {
    availableList.addAll(info.getSet(pc) as Iterable<String>);
    selectedList.addAll(pc.getAssociationList(owner) as Iterable<String>);
    _preChooserChoices = selectedList.length;
  }

  @override
  bool conditionallyApply(dynamic pc, String item) =>
      throw UnsupportedError('NoChoiceManager.conditionallyApply');

  @override
  bool applyChoices(dynamic pc, List<String> selected) {
    final oldSelections = info.getChoiceActor().getCurrentlySelected(owner, pc)
        as List<String>? ?? [];
    final oldSize = oldSelections.length;
    final newSize = selected.length;
    for (int i = oldSize; i > newSize; i--) {
      info.getChoiceActor().removeChoice(pc, owner, '');
    }
    for (int i = oldSize; i < newSize; i++) {
      info.getChoiceActor().applyChoice(owner, '', pc);
    }
    controller.adjustPool(selected);
    return oldSize != newSize;
  }

  @override
  List<String> doChooser(dynamic pc, List<String> availableList,
      List<String> selectedList, List<String> reservedList) {
    selectedList.add('');
    return List<String>.from(selectedList);
  }

  @override
  List<String> doChooserRemove(dynamic pc, List<String> availableList,
      List<String> selectedList, List<String> reservedList) {
    if (selectedList.isNotEmpty) selectedList.removeAt(0);
    return selectedList;
  }

  @override
  int getNumEffectiveChoices(
      List<String> selectedList, List<String> reservedList, dynamic pc) => 0;

  @override
  void restoreChoice(dynamic pc, dynamic target, String choice) =>
      info.restoreChoice(pc, target, decodeChoice(choice));

  @override
  void setController(ChooseController<String> cc) => controller = cc;

  @override
  int getPreChooserChoices() => _preChooserChoices;

  @override
  void removeChoice(dynamic pc, dynamic obj, String selection) =>
      info.removeChoice(pc, obj, selection);

  @override
  void applyChoice(dynamic pc, dynamic cdo, String selection) =>
      info.getChoiceActor().applyChoice(cdo, '', pc);

  @override
  String decodeChoice(String choice) => info.decodeChoice(null, choice) as String;

  @override
  String encodeChoice(String obj) => info.encodeChoice(obj) as String;
}
