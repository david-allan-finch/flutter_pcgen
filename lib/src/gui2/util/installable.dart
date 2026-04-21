// Translation of pcgen.gui2.util.Installable

/// An [Installable] is an object that relates to a specific PlayerCharacter and
/// is installed/uninstalled as that character becomes active or inactive.
abstract interface class Installable {
  /// Install this object (make it monitor appropriate items).
  void install();

  /// Uninstall this object (make it stop monitoring items).
  void uninstall();
}
