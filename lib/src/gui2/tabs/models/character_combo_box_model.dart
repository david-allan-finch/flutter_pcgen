// Translation of pcgen.gui2.tabs.models.CharacterComboBoxModel

import 'package:flutter/foundation.dart';

/// ChangeNotifier model for a dropdown backed by character facade data.
class CharacterComboBoxModel<T> extends ChangeNotifier {
  final List<T> _items = [];
  T? _selected;
  final T? Function(dynamic character) _selectedReader;
  final List<T> Function(dynamic character) _itemsReader;
  final void Function(dynamic character, T value)? _writer;

  CharacterComboBoxModel({
    required T? Function(dynamic character) selectedReader,
    required List<T> Function(dynamic character) itemsReader,
    void Function(dynamic character, T value)? writer,
  })  : _selectedReader = selectedReader,
        _itemsReader = itemsReader,
        _writer = writer;

  List<T> get items => List.unmodifiable(_items);
  T? get selected => _selected;

  set selected(T? v) {
    if (_selected == v) return;
    _selected = v;
    notifyListeners();
  }

  void install(dynamic character) {
    _items
      ..clear()
      ..addAll(_itemsReader(character));
    _selected = _selectedReader(character);
    notifyListeners();
  }

  void commit(dynamic character) {
    if (_selected != null) _writer?.call(character, _selected as T);
  }
}
