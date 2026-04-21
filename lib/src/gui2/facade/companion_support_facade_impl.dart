//
// Copyright 2012 (C) Connor Petty <cpmeister@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.gui2.facade.CompanionSupportFacadeImpl

import 'package:flutter/foundation.dart';
import 'package:flutter_pcgen/src/facade/core/companion_support_facade.dart';
import 'package:flutter_pcgen/src/facade/util/list_facade.dart';

/// Implementation of CompanionSupportFacade — manages character companions.
class CompanionSupportFacadeImpl extends ChangeNotifier
    implements CompanionSupportFacade {
  final dynamic _character;
  final Map<String, List<dynamic>> _companionsByType = {};

  CompanionSupportFacadeImpl(this._character) {
    _load();
  }

  void _load() {
    _companionsByType.clear();
    if (_character is Map) {
      final companions = _character['companions'];
      if (companions is Map) {
        for (final entry in companions.entries) {
          final type = entry.key as String;
          final list = entry.value;
          _companionsByType[type] = list is List ? list : [];
        }
      }
    }
  }

  @override
  ListFacade<Object> getCompanions(String type) {
    return _SimpleListFacade(_companionsByType[type] ?? []);
  }

  @override
  List<String> getCompanionTypes() => _companionsByType.keys.toList();

  @override
  int getMaxCompanions(String type) {
    if (_character is Map) {
      final maxMap = _character['maxCompanions'];
      if (maxMap is Map) {
        return (maxMap[type] as num?)?.toInt() ?? 0;
      }
    }
    return 0;
  }

  @override
  void addCompanion(String type, Object companion) {
    _companionsByType.putIfAbsent(type, () => []).add(companion);
    _persist();
    notifyListeners();
  }

  @override
  void removeCompanion(String type, Object companion) {
    _companionsByType[type]?.remove(companion);
    _persist();
    notifyListeners();
  }

  void _persist() {
    if (_character is Map) {
      _character['companions'] = Map.fromEntries(
        _companionsByType.entries.map((e) => MapEntry(e.key, List.of(e.value))),
      );
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
