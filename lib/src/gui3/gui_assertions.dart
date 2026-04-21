//
// Copyright 2019 (C) Eitan Adler <lists@eitanadler.com>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
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
