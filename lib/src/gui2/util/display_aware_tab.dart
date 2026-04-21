// Translation of pcgen.gui2.util.DisplayAwareTab

/// Identifies a tab that wants to be notified when it is displayed.
abstract interface class DisplayAwareTab {
  /// Notify the tab that it has been displayed.
  void tabSelected();
}
