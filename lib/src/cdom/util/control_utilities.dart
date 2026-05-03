// Copyright (c) Tom Parker, 2016.
//
// Translation of pcgen.cdom.util.ControlUtilities

import 'package:flutter_pcgen/src/cdom/enumeration/object_key.dart';

/// Convenience methods for working with Code Controls.
class ControlUtilities {
  ControlUtilities._();

  /// Returns the value of a code control token in the given LoadContext.
  static String? getControlToken(dynamic context, dynamic command) {
    final commandName = command is String ? command : command.getName();
    final controller = context
        .getReferenceContext()
        .silentlyGetConstructedCDOMObject('CodeControl', 'Controller');
    if (controller != null) {
      return controller.get(
          CDOMObjectKey.getConstant<String>('*$commandName'));
    }
    return command is String ? null : command.defaultValue;
  }

  /// Returns true if a feature code control is enabled in the given LoadContext.
  static bool isFeatureEnabled(dynamic context, String feature) {
    final controller = context
        .getReferenceContext()
        .silentlyGetConstructedCDOMObject('CodeControl', 'Controller');
    if (controller != null) {
      final val = controller.getObject(CDOMObjectKey.getConstant<bool>('*$feature'));
      return val == true;
    }
    return false;
  }

  /// Returns true if the code control has a value in the given LoadContext.
  static bool hasControlToken(dynamic context, dynamic command) {
    final commandName = command is String ? command : command.getName();
    final controller = context
        .getReferenceContext()
        .silentlyGetConstructedCDOMObject('CodeControl', 'Controller');
    if (controller != null) {
      return controller.getObject(CDOMObjectKey.getConstant<String>('*$commandName')) != null;
    }
    return false;
  }
}
