// Copyright (c) Andrew Maitland, 2016.
//
// Translation of pcgen.core.chooser.CDOMChoiceManager

import 'choice_manager_list.dart';
import 'choose_controller.dart';

/// Standard implementation of [ChoiceManagerList] backed by a [ChooseInformation].
class CDOMChoiceManager<T> implements ChoiceManagerList<T> {
  final dynamic owner;
  final int? numberOfChoices;
  @override
  final int choicesPerUnitCost;
  ChooseController<T> controller = ChooseController<T>();
  final dynamic info; // ChooseInformation<T>

  int _preChooserChoices = 0;

  CDOMChoiceManager(this.owner, this.info, this.numberOfChoices, this.choicesPerUnitCost);

  @override
  void getChoices(dynamic pc, List<T> availableList, List<T> selectedList) {
    availableList.addAll(info.getSet(pc) as Iterable<T>);
    final selected =
        info.getChoiceActor().getCurrentlySelected(owner, pc) as List<T>?;
    if (selected != null) selectedList.addAll(selected);
    _preChooserChoices = selectedList.length;
  }

  @override
  bool conditionallyApply(dynamic pc, T item) {
    final oldSelections =
        info.getChoiceActor().getCurrentlySelected(owner, pc) as List<T>?;
    bool applied = false;
    if (oldSelections == null || !oldSelections.contains(item)) {
      if ((info.getSet(pc) as Iterable<T>).contains(item)) {
        info.getChoiceActor().applyChoice(owner, item, pc);
        applied = true;
      }
    }
    _adjustPool(info.getChoiceActor().getCurrentlySelected(owner, pc) as List<T>? ?? []);
    return applied;
  }

  @override
  bool applyChoices(dynamic pc, List<T> selected) {
    final oldSelections =
        info.getChoiceActor().getCurrentlySelected(owner, pc) as List<T>? ??
            [];
    final toAdd = selected.where((s) => !oldSelections.contains(s)).toList();
    final toRemove = oldSelections.where((s) => !selected.contains(s)).toList();

    for (final s in toRemove) {
      info.getChoiceActor().removeChoice(pc, owner, s);
    }
    for (final s in toAdd) {
      info.getChoiceActor().applyChoice(owner, s, pc);
    }
    _adjustPool(selected);
    return toAdd.isNotEmpty || toRemove.isNotEmpty;
  }

  @override
  List<T> doChooser(dynamic pc, List<T> availableList, List<T> selectedList,
      List<String> reservedList) {
    // TODO: connect to chooser UI
    return List<T>.from(selectedList);
  }

  @override
  List<T> doChooserRemove(dynamic pc, List<T> availableList,
      List<T> selectedList, List<String> reservedList) {
    // TODO: connect to chooser UI
    if (selectedList.isNotEmpty) selectedList.removeLast();
    return List<T>.from(selectedList);
  }

  @override
  int getNumEffectiveChoices(
      List<T> selectedList, List<String> reservedList, dynamic pc) {
    int limit = numberOfChoices ?? controller.getTotalChoices();
    final available = (info.getSet(pc) as Iterable<T>)
        .where((t) => !reservedList.contains(encodeChoice(t)))
        .length;
    return (limit - selectedList.length).clamp(0, available);
  }

  @override
  void restoreChoice(dynamic pc, dynamic owner, String choice) {
    info.restoreChoice(pc, owner, decodeChoice(choice));
  }

  @override
  void setController(ChooseController<T> cc) => controller = cc;

  @override
  int getPreChooserChoices() => _preChooserChoices;

  @override
  void removeChoice(dynamic pc, dynamic owner, T selection) =>
      info.removeChoice(pc, owner, selection);

  @override
  void applyChoice(dynamic pc, dynamic owner, T selection) =>
      info.getChoiceActor().applyChoice(owner, selection, pc);

  @override
  T decodeChoice(String choice) => info.decodeChoice(null, choice) as T;

  @override
  String encodeChoice(T obj) => info.encodeChoice(obj) as String;

  void _adjustPool(List<T> selected) => controller.adjustPool(selected);
}
