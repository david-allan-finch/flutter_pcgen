// Translation of pcgen.gui2.facade.GeneralChooserFacadeBase

import 'package:flutter/foundation.dart';
import '../../facade/core/chooser_facade.dart';
import '../../facade/util/list_facade.dart';

/// Base class for chooser facade implementations used in PCGen dialogs.
abstract class GeneralChooserFacadeBase<T> extends ChangeNotifier
    implements ChooserFacade {
  final String _name;
  final List<T> _availableList;
  final List<T> _selectedList;
  final int _maxSelections;
  bool _committed = false;

  GeneralChooserFacadeBase({
    required String name,
    required List<T> available,
    List<T>? selected,
    int maxSelections = -1,
  })  : _name = name,
        _availableList = List.of(available),
        _selectedList = List.of(selected ?? []),
        _maxSelections = maxSelections;

  @override
  String getName() => _name;

  @override
  ListFacade<Object> getAvailableList() =>
      _DelegatListFacade<T>(_availableList);

  @override
  ListFacade<Object> getSelectedList() =>
      _DelegatListFacade<T>(_selectedList);

  @override
  int getMaxSelections() => _maxSelections;

  @override
  int getRemainingSelections() {
    if (_maxSelections < 0) return -1;
    return _maxSelections - _selectedList.length;
  }

  @override
  bool isCommitted() => _committed;

  @override
  void addSelected(Object item) {
    if (_maxSelections >= 0 && _selectedList.length >= _maxSelections) return;
    if (!_selectedList.contains(item)) {
      _selectedList.add(item as T);
      _availableList.remove(item);
      notifyListeners();
    }
  }

  @override
  void removeSelected(Object item) {
    if (_selectedList.remove(item)) {
      _availableList.add(item as T);
      notifyListeners();
    }
  }

  @override
  void commit() {
    _committed = true;
    notifyListeners();
  }

  @override
  void cancel() {
    notifyListeners();
  }
}

class _DelegatListFacade<T> implements ListFacade<Object> {
  final List<T> _list;
  _DelegatListFacade(this._list);

  @override
  Object getElementAt(int index) => _list[index] as Object;

  @override
  int getSize() => _list.length;
}
