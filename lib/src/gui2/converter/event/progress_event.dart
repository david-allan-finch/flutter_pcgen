// Translation of pcgen.gui2.converter.event.ProgressEvent

/// Represents a progress event fired by a conversion sub-panel to signal
/// whether navigation to the next step is permitted.
class ProgressEvent {
  static const int allowed = 0;
  static const int notAllowed = 1;
  static const int autoAdvance = 2;

  /// The source object that fired this event.
  final Object source;

  /// The event identifier — one of [allowed], [notAllowed], or [autoAdvance].
  final int id;

  ProgressEvent(this.source, this.id);

  int getID() => id;
}
