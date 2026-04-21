// Translation of pcgen.gui2.util.ManagedField

import 'package:flutter/material.dart';

import 'installable.dart';

/// A [ManagedField] manages a [TextEditingController] (Dart equivalent of
/// JTextField) and is [Installable] — i.e. it can be connected to / disconnected
/// from a PlayerCharacter.
abstract interface class ManagedField implements Installable {
  /// Returns the [TextEditingController] that this [ManagedField] manages.
  TextEditingController getTextField();
}
