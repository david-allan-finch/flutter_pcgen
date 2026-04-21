//
// Copyright 2010 Connor Petty <cpmeister@users.sourceforge.net>
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
