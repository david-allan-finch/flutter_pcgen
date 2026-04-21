// Translation of pcgen.gui2.facade.CompanionSupportFacadeImpl

import 'package:flutter/foundation.dart';
import '../../facade/core/companion_support_facade.dart';
import '../../facade/util/list_facade.dart';

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
