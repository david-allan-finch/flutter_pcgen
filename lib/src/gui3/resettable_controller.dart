// Translation of pcgen.gui3.ResettableController

/// Interface for controllers that support resetting their state
/// (e.g., when a new character is loaded or preferences are cancelled).
abstract class ResettableController {
  void reset();
}
