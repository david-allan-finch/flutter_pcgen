// Translation of pcgen.gui2.util.event.PopupMouseAdapter

/// Adapter that triggers showPopup on right-click or popup trigger events.
/// In Flutter, handled via GestureDetector.onSecondaryTap or onLongPress.
abstract class PopupMouseAdapter {
  /// Called when a popup should be shown at the given position.
  void showPopup(dynamic event);

  /// Returns a GestureDetector callback for secondary tap (right-click).
  void Function()? get onSecondaryTap => () => showPopup(null);
  void Function()? get onLongPress => () => showPopup(null);
}
