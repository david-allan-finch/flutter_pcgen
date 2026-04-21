//
// Copyright 2011 Connor Petty <cpmeister@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.gui2.tabs.equip.EquipmentModels

import 'package:flutter/foundation.dart';
import 'package:flutter_pcgen/src/gui2/tabs/equip/equipment_model.dart';

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
