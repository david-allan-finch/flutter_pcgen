// Copyright 2010 Connor Petty <cpmeister@users.sourceforge.net>
//
// Translation of pcgen.facade.util.event.ReferenceListener

import 'package:flutter_pcgen/src/facade/util/event/reference_event.dart';

/// Listener for changes to a ReferenceFacade.
abstract interface class ReferenceListener<E> {
  void referenceChanged(ReferenceEvent<E> e);
}
