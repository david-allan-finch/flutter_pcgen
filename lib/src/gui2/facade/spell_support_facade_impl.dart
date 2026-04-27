// *
// Copyright James Dempsey, 2011
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
// Translation of pcgen.gui2.facade.SpellSupportFacadeImpl

import 'package:flutter/foundation.dart';
import 'package:flutter_pcgen/src/facade/core/spell_support_facade.dart';
import 'package:flutter_pcgen/src/facade/util/list_facade.dart';

/// Implementation of SpellSupportFacade managing a character's spell lists.
class SpellSupportFacadeImpl extends ChangeNotifier implements SpellSupportFacade {
  final dynamic _character;
  final Map<String, List<Map<String, dynamic>>> _spellBooks = {};
  final List<Map<String, dynamic>> _knownSpells = [];
  final List<Map<String, dynamic>> _preparedSpells = [];

  SpellSupportFacadeImpl(this._character) {
    _load();
  }

  void _load() {
    _spellBooks.clear();
    _knownSpells.clear();
    _preparedSpells.clear();
    if (_character is Map) {
      final books = _character['spellBooks'];
      if (books is Map) {
        for (final entry in books.entries) {
          final spells = entry.value;
          _spellBooks[entry.key as String] =
              spells is List ? spells.cast<Map<String, dynamic>>() : [];
        }
      }
      final known = _character['knownSpells'];
      if (known is List) {
        _knownSpells.addAll(known.cast<Map<String, dynamic>>());
      }
      final prepared = _character['preparedSpells'];
      if (prepared is List) {
        _preparedSpells.addAll(prepared.cast<Map<String, dynamic>>());
      }
    }
  }

  @override
  List<String> getSpellBooks() => _spellBooks.keys.toList();

  @override
  ListFacade<Object> getSpellsInBook(String bookName) =>
      _SimpleListFacade(_spellBooks[bookName] ?? []);

  @override
  ListFacade<Object> getKnownSpells() => _SimpleListFacade(_knownSpells);

  @override
  ListFacade<Object> getPreparedSpells() => _SimpleListFacade(_preparedSpells);

  @override
  void addSpellBook(String name) {
    _spellBooks.putIfAbsent(name, () => []);
    notifyListeners();
  }

  @override
  void removeSpellBook(String name) {
    _spellBooks.remove(name);
    notifyListeners();
  }

  @override
  void addSpellToBook(String bookName, Object spell) {
    _spellBooks.putIfAbsent(bookName, () => []).add(spell as Map<String, dynamic>);
    notifyListeners();
  }

  @override
  void removeSpellFromBook(String bookName, Object spell) {
    _spellBooks[bookName]?.remove(spell);
    notifyListeners();
  }

  @override
  void addPreparedSpell(dynamic spell, String spellList, bool useMetamagic) {
    if (spell is Map<String, dynamic>) _preparedSpells.add(spell);
    notifyListeners();
  }

  @override
  void removePreparedSpell(dynamic spell, String spellList) {
    _preparedSpells.remove(spell);
    notifyListeners();
  }

  void reload() {
    _load();
    notifyListeners();
  }

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
