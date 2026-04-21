// Copyright James Dempsey, 2012
//
// Translation of pcgen.facade.util.event.ChangeListener

import 'package:flutter_pcgen/src/facade/util/event/change_event.dart';

/// Listener notified when an object changes.
abstract interface class ChangeListener {
  void itemChanged(ChangeEvent event);
}
