// Translation of pcgen.gui2.tabs.spells.ClassInfoHandler

import 'package:flutter/foundation.dart';

/// Manages the selected spellcasting class and its associated spell list tabs.
class ClassInfoHandler extends ChangeNotifier {
  final List<String> _classes = [];
  int _selectedClassIndex = -1;

  List<String> get classes => List.unmodifiable(_classes);

  int get selectedClassIndex => _selectedClassIndex;

  String? get selectedClass =>
      (_selectedClassIndex >= 0 && _selectedClassIndex < _classes.length)
          ? _classes[_selectedClassIndex]
          : null;

  void setClasses(List<String> classes) {
    _classes
      ..clear()
      ..addAll(classes);
    _selectedClassIndex = _classes.isEmpty ? -1 : 0;
    notifyListeners();
  }

  void selectClass(int index) {
    if (index >= 0 && index < _classes.length) {
      _selectedClassIndex = index;
      notifyListeners();
    }
  }

  void install(dynamic character) {
    final classList = _extractClasses(character);
    setClasses(classList);
  }

  List<String> _extractClasses(dynamic character) {
    if (character == null) return [];
    if (character is Map) {
      final c = character['spellcastingClasses'];
      if (c is List) return c.cast<String>();
    }
    return [];
  }
}
