// Translation of pcgen.gui2.facade.SpellBuilderFacadeImpl

import 'package:flutter/foundation.dart';
import '../../facade/core/spell_builder_facade.dart';
import '../../facade/util/list_facade.dart';

/// Implementation of SpellBuilderFacade — builds and adds spells to spell books/lists.
class SpellBuilderFacadeImpl extends ChangeNotifier implements SpellBuilderFacade {
  final dynamic _character;
  final List<Map<String, dynamic>> _availableSpells = [];
  Map<String, dynamic>? _selectedSpell;
  String? _selectedClass;
  String? _selectedSpellBook;
  int _selectedLevel = 0;
  final List<String> _metaMagicFeats = [];
  final List<String> _selectedMetaMagic = [];

  SpellBuilderFacadeImpl(this._character);

  @override
  ListFacade<Object> getAvailableSpells() => _SimpleListFacade(_availableSpells);

  @override
  Object? getSelectedSpell() => _selectedSpell;

  @override
  void setSelectedSpell(Object? spell) {
    _selectedSpell = spell as Map<String, dynamic>?;
    notifyListeners();
  }

  @override
  String? getSelectedClass() => _selectedClass;

  @override
  void setSelectedClass(String? charClass) {
    _selectedClass = charClass;
    notifyListeners();
  }

  @override
  String? getSelectedSpellBook() => _selectedSpellBook;

  @override
  void setSelectedSpellBook(String? spellBook) {
    _selectedSpellBook = spellBook;
    notifyListeners();
  }

  @override
  int getSelectedLevel() => _selectedLevel;

  @override
  void setSelectedLevel(int level) {
    _selectedLevel = level;
    notifyListeners();
  }

  @override
  ListFacade<Object> getMetaMagicFeats() => _SimpleListFacade(_metaMagicFeats);

  @override
  List<String> getSelectedMetaMagic() => List.unmodifiable(_selectedMetaMagic);

  @override
  void addMetaMagic(String feat) {
    if (!_selectedMetaMagic.contains(feat)) {
      _selectedMetaMagic.add(feat);
      notifyListeners();
    }
  }

  @override
  void removeMetaMagic(String feat) {
    if (_selectedMetaMagic.remove(feat)) notifyListeners();
  }

  @override
  bool canAddSpell() => _selectedSpell != null && _selectedClass != null;

  @override
  void addSpell() {
    if (!canAddSpell()) return;
    // In a real implementation, this would add the spell to the character's spell list
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
