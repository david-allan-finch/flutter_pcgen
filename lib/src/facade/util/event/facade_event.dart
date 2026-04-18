// Copyright 2012 Connor Petty <cpmeister@users.sourceforge.net>
//
// Translation of pcgen.facade.util.event.FacadeEvent

/// Marker base class for facade-based events.
class FacadeEvent {
  final Object source;

  const FacadeEvent(this.source);
}
