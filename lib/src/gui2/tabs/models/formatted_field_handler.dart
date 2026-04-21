// Translation of pcgen.gui2.tabs.models.FormattedFieldHandler

import 'package:flutter/material.dart';

/// Handles a formatted (e.g., numeric) text field, parsing and formatting
/// values between the UI and the character model.
abstract class FormattedFieldHandler<T> {
  final TextEditingController controller = TextEditingController();

  FormattedFieldHandler() {
    controller.addListener(_onChanged);
  }

  void _onChanged() {
    final parsed = parse(controller.text);
    if (parsed != null) setModelValue(parsed);
  }

  /// Parse a string from the text field into the model type.
  T? parse(String text);

  /// Format a model value into a display string.
  String format(T value);

  /// Update the model with the parsed value.
  void setModelValue(T value);

  /// Get the current value from the model and update the controller.
  void install(dynamic character) {
    final v = getModelValue(character);
    if (v != null) {
      final formatted = format(v);
      if (controller.text != formatted) {
        controller.text = formatted;
      }
    }
  }

  T? getModelValue(dynamic character);

  void dispose() {
    controller.removeListener(_onChanged);
    controller.dispose();
  }
}
