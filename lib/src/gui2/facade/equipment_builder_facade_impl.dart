//
// Copyright 2013 (C) James Dempsey <jdempsey@users.sourceforge.net>
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
// Translation of pcgen.gui2.facade.EquipmentBuilderFacadeImpl

import 'package:flutter/foundation.dart';
import '../../facade/core/equipment_builder_facade.dart';
import '../../facade/util/list_facade.dart';

/// Implementation of EquipmentBuilderFacade — builds custom equipment items.
class EquipmentBuilderFacadeImpl extends ChangeNotifier
    implements EquipmentBuilderFacade {
  final dynamic _baseItem;
  final List<Map<String, dynamic>> _availableHeads = [];
  final List<Map<String, dynamic>> _selectedHeadChoices = [];
  String _name;
  int _plusOne = 0;
  int _plusTwo = 0;

  EquipmentBuilderFacadeImpl(this._baseItem)
      : _name = (_baseItem is Map ? (_baseItem['name'] as String? ?? '') : '');

  @override
  String getBaseItemName() =>
      _baseItem is Map ? (_baseItem['name'] as String? ?? '') : '';

  @override
  String getName() => _name;

  @override
  void setName(String name) {
    _name = name;
    notifyListeners();
  }

  @override
  ListFacade<Object> getAvailableHeads() => _SimpleListFacade(_availableHeads);

  @override
  ListFacade<Object> getSelectedHeadChoices() =>
      _SimpleListFacade(_selectedHeadChoices);

  @override
  void addHeadChoice(Object head) {
    _selectedHeadChoices.add(head as Map<String, dynamic>);
    notifyListeners();
  }

  @override
  void removeHeadChoice(Object head) {
    _selectedHeadChoices.remove(head);
    notifyListeners();
  }

  @override
  int getPlusOne() => _plusOne;

  @override
  void setPlusOne(int value) {
    _plusOne = value;
    notifyListeners();
  }

  @override
  int getPlusTwo() => _plusTwo;

  @override
  void setPlusTwo(int value) {
    _plusTwo = value;
    notifyListeners();
  }

  @override
  Map<String, dynamic> build() {
    final result = Map<String, dynamic>.from(
        _baseItem is Map ? _baseItem as Map<String, dynamic> : {});
    result['name'] = _name;
    result['plusOne'] = _plusOne;
    result['plusTwo'] = _plusTwo;
    result['customChoices'] = List.of(_selectedHeadChoices);
    return result;
  }
}

class _SimpleListFacade<T> implements ListFacade<Object> {
  final List<T> _list;
  _SimpleListFacade(this._list);

  @override
  Object getElementAt(int index) => _list[index] as Object;

  @override
  int getSize() => _list.length;
}
