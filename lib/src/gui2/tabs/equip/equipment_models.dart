// Translation of pcgen.gui2.tabs.equip.EquipmentModels

import 'package:flutter/foundation.dart';
import 'equipment_model.dart';

/// Manages multiple equipment sets (models) for a character.
class EquipmentModels extends ChangeNotifier {
  final List<EquipmentModel> _sets = [];
  int _activeIndex = -1;

  List<EquipmentModel> get sets => List.unmodifiable(_sets);

  EquipmentModel? get activeSet =>
      (_activeIndex >= 0 && _activeIndex < _sets.length) ? _sets[_activeIndex] : null;

  int get activeIndex => _activeIndex;

  void addSet(String name) {
    _sets.add(EquipmentModel(name));
    if (_activeIndex < 0) _activeIndex = 0;
    notifyListeners();
  }

  void removeSet(int index) {
    if (index < 0 || index >= _sets.length) return;
    _sets.removeAt(index);
    if (_activeIndex >= _sets.length) _activeIndex = _sets.length - 1;
    notifyListeners();
  }

  void setActive(int index) {
    if (index >= 0 && index < _sets.length) {
      _activeIndex = index;
      notifyListeners();
    }
  }

  void renameSet(int index, String newName) {
    if (index >= 0 && index < _sets.length) {
      _sets[index].name = newName;
      notifyListeners();
    }
  }
}
