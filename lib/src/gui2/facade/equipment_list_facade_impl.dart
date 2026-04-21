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
// Translation of pcgen.gui2.facade.EquipmentListFacadeImpl

import 'package:flutter/foundation.dart';
import '../../facade/core/equipment_list_facade.dart';
import '../../facade/util/list_facade.dart';

/// Implementation of EquipmentListFacade — the full list of equipment owned by a character.
class EquipmentListFacadeImpl extends ChangeNotifier implements EquipmentListFacade {
  final dynamic _character;
  final List<Map<String, dynamic>> _items = [];

  EquipmentListFacadeImpl(this._character) {
    _load();
  }

  void _load() {
    _items.clear();
    if (_character is Map) {
      final equip = _character['equipment'];
      if (equip is List) {
        for (final item in equip) {
          if (item is Map<String, dynamic>) _items.add(item);
        }
      }
    }
  }

  @override
  ListFacade<Object> getEquipmentList() => _SimpleListFacade(_items);

  @override
  void addEquipment(Object item) {
    _items.add(item as Map<String, dynamic>);
    _persist();
    notifyListeners();
  }

  @override
  void removeEquipment(Object item) {
    _items.remove(item);
    _persist();
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

  void _persist() {
    if (_character is Map) {
      _character['equipment'] = List.of(_items);
    }
  }

  void reload() {
    _load();
    notifyListeners();
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
