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
// Translation of pcgen.gui2.facade.PartyFacadeImpl

import 'package:flutter/foundation.dart';
import '../../facade/core/party_facade.dart';
import '../../facade/core/character_facade.dart';
import '../../facade/util/list_facade.dart';

/// Implementation of PartyFacade managing the list of open characters.
class PartyFacadeImpl extends ChangeNotifier implements PartyFacade {
  final List<CharacterFacade> _characters = [];
  String? _filePath;

  @override
  ListFacade<CharacterFacade> getCharacters() => _ListFacadeImpl(_characters);

  @override
  String? getFileRef() => _filePath;

  void setFileRef(String? path) {
    _filePath = path;
    notifyListeners();
  }

  void addCharacter(CharacterFacade character) {
    _characters.add(character);
    notifyListeners();
  }

  void removeCharacter(CharacterFacade character) {
    _characters.remove(character);
    notifyListeners();
  }

  bool get isEmpty => _characters.isEmpty;
  bool get isNotEmpty => _characters.isNotEmpty;
}

class _ListFacadeImpl<E> implements ListFacade<E> {
  final List<E> _list;
  _ListFacadeImpl(this._list);

  @override
  E getElementAt(int index) => _list[index];

  @override
  int getSize() => _list.length;
}
