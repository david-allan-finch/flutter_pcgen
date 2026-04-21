// Translation of pcgen.gui2.util.FacadeComboBoxModel

import 'package:flutter/foundation.dart';

import '../../facade/util/delegating_list_facade.dart';
import '../../facade/util/list_facade.dart';
import '../../facade/util/reference_facade.dart';
import '../../facade/util/event/list_event.dart';
import '../../facade/util/event/list_listener.dart';
import '../../facade/util/event/reference_event.dart';
import '../../facade/util/event/reference_listener.dart';

/// A combo-box model backed by a [ListFacade] and a [ReferenceFacade].
/// Notifies listeners when the underlying list or selected reference changes.
class FacadeComboBoxModel<E>
    with ChangeNotifier
    implements ListListener<E>, ReferenceListener<E> {
  final DelegatingListFacade<E> _delegate = DelegatingListFacade<E>();
  ReferenceFacade<E>? _reference;
  Object? _selectedItem;

  FacadeComboBoxModel() {
    _delegate.addListListener(this);
  }

  FacadeComboBoxModel.withList(ListFacade<E> list, ReferenceFacade<E> ref)
      : this() {
    setListFacade(list);
    setReference(ref);
  }

  void setListFacade(ListFacade<E> list) {
    _delegate.setDelegate(list);
  }

  void setReference(ReferenceFacade<E>? ref) {
    _reference?.removeReferenceListener(this);
    _reference = ref;
    if (_reference != null) {
      _reference!.addReferenceListener(this);
      setSelectedItem(_reference!.get());
    }
  }

  int getSize() => _delegate.getSize();

  E? getElementAt(int index) => _delegate.getElementAt(index);

  void setSelectedItem(Object? anItem) {
    _selectedItem = anItem;
    notifyListeners();
  }

  Object? getSelectedItem() => _selectedItem;

  @override
  void elementAdded(ListEvent<E> e) {
    notifyListeners();
  }

  @override
  void elementRemoved(ListEvent<E> e) {
    notifyListeners();
  }

  @override
  void elementsChanged(ListEvent<E> e) {
    notifyListeners();
  }

  @override
  void elementModified(ListEvent<E> e) {
    notifyListeners();
  }

  @override
  void referenceChanged(ReferenceEvent<E> e) {
    setSelectedItem(e.newReference);
  }
}
