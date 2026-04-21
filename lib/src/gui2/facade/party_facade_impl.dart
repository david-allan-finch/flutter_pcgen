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
