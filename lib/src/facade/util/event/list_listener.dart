// Copyright 2010 Connor Petty <cpmeister@users.sourceforge.net>
//
// Translation of pcgen.facade.util.event.ListListener

import 'list_event.dart';

/// Listener for changes to a ListFacade.
abstract interface class ListListener<E> {
  void elementAdded(ListEvent<E> e);
  void elementRemoved(ListEvent<E> e);
  void elementsChanged(ListEvent<E> e);

  /// Signals that an element in the list was modified and needs to be refreshed.
  void elementModified(ListEvent<E> e);
}
