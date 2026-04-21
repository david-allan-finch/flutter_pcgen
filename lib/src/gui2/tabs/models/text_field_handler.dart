//
// Copyright 2011 Connor Petty <cpmeister@users.sourceforge.net>
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
