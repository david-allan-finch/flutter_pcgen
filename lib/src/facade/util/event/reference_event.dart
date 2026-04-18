// Copyright 2010 Connor Petty <cpmeister@users.sourceforge.net>
//
// Translation of pcgen.facade.util.event.ReferenceEvent

import 'facade_event.dart';

/// Event fired when a ReferenceFacade's value changes.
class ReferenceEvent<E> extends FacadeEvent {
  final E? oldObject;
  final E? newObject;

  const ReferenceEvent(Object source, this.oldObject, this.newObject)
      : super(source);

  E? getOldReference() => oldObject;
  E? getNewReference() => newObject;
}
