// Translation of pcgen.gui2.tabs.equip.EquipmentModel

import 'package:flutter/foundation.dart';

/// Model for a single equipment set (equipped items in a particular configuration).
class EquipmentModel extends ChangeNotifier {
  String _name;
  final List<Map<String, dynamic>> _items = [];

  EquipmentModel(this._name);

  String get name => _name;
  set name(String v) { _name = v; notifyListeners(); }

  List<Map<String, dynamic>> get items => List.unmodifiable(_items);

  void addItem(Map<String, dynamic> item) {
    _items.add(item);
    notifyListeners();
  }

  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
