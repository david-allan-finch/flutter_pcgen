// Translation of pcgen.gui2.tabs.models.TextFieldHandler

import 'package:flutter/material.dart';

/// Binds a TextEditingController to a character facade property,
/// keeping the field and model in sync.
abstract class TextFieldHandler {
  final TextEditingController controller = TextEditingController();

  TextFieldHandler() {
    controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    setModelValue(controller.text);
  }

  /// Called when the text field changes — update the model.
  void setModelValue(String value);

  /// Called when the model changes — update the text field.
  void install(dynamic character) {
    final v = getModelValue(character);
    if (controller.text != v) {
      controller.text = v ?? '';
    }
  }

  String? getModelValue(dynamic character);

  void dispose() {
    controller.removeListener(_onControllerChanged);
    controller.dispose();
  }
}
