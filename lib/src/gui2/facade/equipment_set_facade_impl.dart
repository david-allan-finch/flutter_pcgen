//
// Copyright James Dempsey, 2010
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
// Translation of pcgen.gui2.facade.EquipmentSetFacadeImpl

import 'package:flutter/foundation.dart';
import 'package:flutter_pcgen/src/facade/core/equipment_set_facade.dart';
import 'package:flutter_pcgen/src/facade/util/list_facade.dart';

/// Implementation of EquipmentSetFacade — a named equipment configuration/loadout.
class EquipmentSetFacadeImpl extends ChangeNotifier implements EquipmentSetFacade {
  String _name;
  final Map<String, List<Map<String, dynamic>>> _slotItems = {};

  EquipmentSetFacadeImpl(this._name);

  @override
  String getName() => _name;

  @override
  void setName(String name) {
    _name = name;
    notifyListeners();
  }

  @override
  dynamic getEquippedItems() => List.of(_slotItems.values.expand((l) => l));

  List<dynamic> getEquippedItemsForSlot(String slot) =>
      List.of(_slotItems[slot] ?? []);

  List<String> getEquippedSlots() => _slotItems.keys.toList();

  @override
  dynamic addEquipment(dynamic node, dynamic equipment, int quantity,
      [dynamic beforeNode]) {
    final slot = node?.toString() ?? 'Default';
    _slotItems.putIfAbsent(slot, () => []).add(equipment);
    notifyListeners();
    return null;
  }

  @override
  dynamic removeEquipment(dynamic node, int quantity) {
    final slot = node?.toString() ?? 'Default';
    final list = _slotItems[slot];
    if (list != null && list.isNotEmpty) list.removeLast();
    notifyListeners();
    return null;
  }

  @override
  int getQuantity(dynamic node) {
    if (node is Map<String, dynamic>) {
      return (node['qty'] as num?)?.toInt() ?? 1;
    }
    return 1;
  }

  void setQuantity(dynamic item, int qty) {
    if (item is Map<String, dynamic>) item['qty'] = qty;
    notifyListeners();
  }

  @override
  String toString() => _name;

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _SimpleListFacade<T> implements ListFacade<Object> {
  final List<T> _list;
  _SimpleListFacade(this._list);

  @override
  Object getElementAt(int index) => _list[index] as Object;

  @override
  int getSize() => _list.length;

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}
