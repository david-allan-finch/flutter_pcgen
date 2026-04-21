// Translation of pcgen.gui2.util.FacadeListModel

import 'package:flutter/foundation.dart';
import '../../facade/util/list_facade.dart';
import '../../facade/util/event/list_event.dart';
import '../../facade/util/event/list_listener.dart';

/// A ChangeNotifier list model backed by a ListFacade.
/// Notifies listeners whenever the underlying list changes.
class FacadeListModel<E> extends ChangeNotifier implements ListListener<E> {
  ListFacade<E>? _delegate;

  FacadeListModel([ListFacade<E>? list]) {
    if (list != null) setListFacade(list);
  }

  void setListFacade(ListFacade<E>? list) {
    _delegate?.removeListListener(this);
    _delegate = list;
    _delegate?.addListListener(this);
    notifyListeners();
  }

  int getSize() => _delegate?.getSize() ?? 0;

  E getElementAt(int index) => _delegate!.getElementAt(index);

  List<E> toList() {
    final result = <E>[];
    final d = _delegate;
    if (d == null) return result;
    for (int i = 0; i < d.getSize(); i++) {
      result.add(d.getElementAt(i));
    }
    return result;
  }

  @override
  void elementAdded(ListEvent<E> e) => notifyListeners();

  @override
  void elementRemoved(ListEvent<E> e) => notifyListeners();

  @override
  void elementsChanged(ListEvent<E> e) => notifyListeners();

  @override
  void elementModified(ListEvent<E> e) => notifyListeners();

  @override
  void dispose() {
    _delegate?.removeListListener(this);
    super.dispose();
  }
}
