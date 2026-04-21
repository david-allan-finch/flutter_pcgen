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
