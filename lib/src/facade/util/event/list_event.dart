// Copyright 2010 Connor Petty <cpmeister@users.sourceforge.net>
//
// Translation of pcgen.facade.util.event.ListEvent

import 'facade_event.dart';

/// Event fired when a ListFacade changes.
class ListEvent<E> extends FacadeEvent {
  static const int elementAdded = 0;
  static const int elementRemoved = 1;
  static const int elementsChanged = 2;
  static const int elementModified = 3;

  final E? element;
  final int type;
  final int index;

  /// Shortcut constructor for an ELEMENTS_CHANGED event.
  ListEvent.changed(Object source)
      : this(source, elementsChanged, null, -1);

  const ListEvent(Object source, this.type, this.element, this.index)
      : super(source);

  E? getElement() => element;
  int getType() => type;
  int getIndex() => index;
}
