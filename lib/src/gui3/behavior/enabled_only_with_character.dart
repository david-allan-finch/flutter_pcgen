// Translation of pcgen.gui3.behavior.EnabledOnlyWithCharacter

import 'package:flutter/foundation.dart';

/// A ValueNotifier<bool> that is true only when a character is loaded.
/// Used to control the enabled state of buttons/menu items that require
/// an open character.
class EnabledOnlyWithCharacter extends ValueNotifier<bool> {
  EnabledOnlyWithCharacter() : super(false);

  void onCharacterLoaded(dynamic character) {
    value = character != null;
  }

  void onCharacterClosed() {
    value = false;
  }
}
