// Translation of pcgen.gui2.facade.EquipmentSetFacadeImpl

import 'package:flutter/foundation.dart';
import '../../facade/core/equipment_set_facade.dart';
import '../../facade/util/list_facade.dart';

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
  ListFacade<Object> getEquippedItems(String slot) {
    return _SimpleListFacade(_slotItems[slot] ?? []);
  }

  @override
  List<String> getEquippedSlots() => _slotItems.keys.toList();

  @override
  void addEquipment(String slot, Object item) {
    _slotItems.putIfAbsent(slot, () => []).add(item as Map<String, dynamic>);
    notifyListeners();
  }

  @override
  void removeEquipment(String slot, Object item) {
    _slotItems[slot]?.remove(item);
    if (_slotItems[slot]?.isEmpty ?? false) _slotItems.remove(slot);
    notifyListeners();
  }

  @override
  int getQuantity(Object item) {
    final m = item as Map<String, dynamic>;
    return (m['qty'] as num?)?.toInt() ?? 1;
  }

  @override
  void setQuantity(Object item, int qty) {
    final m = item as Map<String, dynamic>;
    m['qty'] = qty;
    notifyListeners();
  }

  @override
  String toString() => _name;
}

class _SimpleListFacade<T> implements ListFacade<Object> {
  final List<T> _list;
  _SimpleListFacade(this._list);

  @override
  Object getElementAt(int index) => _list[index] as Object;

  @override
  int getSize() => _list.length;
}
