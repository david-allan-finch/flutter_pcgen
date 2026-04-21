// Translation of pcgen.gui3.GuiAssertions

import 'package:flutter/foundation.dart';

/// Assertion helpers for GUI-layer invariants.
class GuiAssertions {
  GuiAssertions._();

  /// Assert that the current execution is on the UI (main) isolate.
  /// In Flutter there is only one isolate for UI work, so this is a no-op
  /// outside of debug mode.
  static void assertIsUIThread() {
    assert(() {
      // In Dart/Flutter all UI work happens on the main isolate.
      // This assertion exists to document intent.
      return true;
    }());
  }

  /// Assert that the current execution is NOT on the UI isolate.
  /// (Not enforceable in Dart the same way as JavaFX, so this is a no-op.)
  static void assertNotUIThread() {
    // No-op: Dart/Flutter does not have an equivalent lightweight check.
    // Use compute() or Isolate.spawn() for background work.
  }
}
